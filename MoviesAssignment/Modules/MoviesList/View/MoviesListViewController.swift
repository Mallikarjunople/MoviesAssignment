//
//  MoviesListViewController.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import UIKit
import Combine

class MoviesListViewController: UIViewController {
    private let tableView = UITableView()
    private var movies: [Movie] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentTask: Task<Void, Never>? = nil
    private let refresh = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPopular()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Popular Movies"
        view.backgroundColor = .systemBackground
        setupTable()
        setupSearch()
    }

    private func setupTable() {
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 140
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

    @objc private func refreshPulled() {
        fetchPopular()
    }

    private func setupSearch() {
        searchController.searchBar.placeholder = "Search movies"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func fetchPopular() {
        currentTask?.cancel()
        currentTask = Task {
            DispatchQueue.main.async { self.refresh.beginRefreshing() }
            do {
                let result = try await TMDBClient.shared.fetchPopular()
                self.movies = result
                self.tableView.reloadData()
            } catch {
                self.showError(error)
            }
            DispatchQueue.main.async { self.refresh.endRefreshing() }
        }
    }

    private func search(query: String) {
        currentTask?.cancel()
        currentTask = Task {
            do {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let result = try await TMDBClient.shared.fetchPopular()
                    self.movies = result
                } else {
                    let result = try await TMDBClient.shared.search(query: query)
                    self.movies = result
                }
                self.tableView.reloadData()
            } catch {
                self.showError(error)
            }
        }
    }

    private func showError(_ error: Error) {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Retry", style: .default) { _ in self.fetchPopular() })
            ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            self.present(ac, animated: true)
        }
    }
}

extension MoviesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { movies.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseIdentifier, for: indexPath) as? MovieCell else { return UITableViewCell() }
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        cell.cellTapPublisher.sink(receiveValue: {[weak self] _ in
            guard let self else { return }
            let movie = self.movies[indexPath.row]
            let vc = MovieDetailsViewController(viewModel: MovieDetailsViewModel(movieID: movie.id))
            navigationController?.pushViewController(vc, animated: true)
        }).store(in: &cell.cancellables)

        cell.setFavorited(FavoritesManager.shared.isFavorite(movie.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentTask?.cancel()
        currentTask = Task {
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 300ms
            if Task.isCancelled { return }
            await MainActor.run { self.search(query: searchText) }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
