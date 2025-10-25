//
//  MovieDetailsViewController.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//
import UIKit
import WebKit

enum MovieDetailSection: Hashable, CaseIterable {
    case trailer
    case info
}

final class MovieDetailsViewController: UIViewController {

    // MARK: - Properties
    private let movieID: Int
    private var trailerURL: URL?
    private var viewModel: MovieDetailsViewModel?

    private var dataSource: UICollectionViewDiffableDataSource<MovieDetailSection, UUID>!
    private var collectionView: UICollectionView!
    private let favoritesManager = FavoritesManager.shared

    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        self.movieID = viewModel.movieID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movie Details"
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupDataSource()

        Task {
            await viewModel?.fetchMovieDetailsData()
        }
        setupSubscribers()
    }
}

// MARK: - UI Setup
extension MovieDetailsViewController {

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.register(MovieTrailerCell.self, forCellWithReuseIdentifier: MovieTrailerCell.reuseId)
        collectionView.register(MovieInfoCell.self, forCellWithReuseIdentifier: MovieInfoCell.reuseId)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = MovieDetailSection.allCases[sectionIndex]
            switch section {
            case .trailer:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(220))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)

            case .info:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)
            }
        }
    }
}

// MARK: - Data Source
extension MovieDetailsViewController {
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MovieDetailSection, UUID>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, _ in
            guard let self = self else { return UICollectionViewCell() }
            let section = MovieDetailSection.allCases[indexPath.section]

            switch section {
            case .trailer:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MovieTrailerCell.reuseId,
                    for: indexPath
                ) as! MovieTrailerCell
                cell.configure(with: self.viewModel?.trailerURL)
                return cell

            case .info:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MovieInfoCell.reuseId,
                    for: indexPath
                ) as! MovieInfoCell

                if let movie = self.viewModel?.movieDetail {
                    let isFav = self.favoritesManager.isFavorite(movie.id ?? 0)
                    cell.configure(with: movie, isFavorite: isFav)
                    cell.favoriteButton.addTarget(self, action: #selector(self.favoriteTapped), for: .touchUpInside)
                }
                return cell
            }
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MovieDetailSection, UUID>()
        snapshot.appendSections([.trailer, .info])
        snapshot.appendItems([UUID()], toSection: .trailer)
        snapshot.appendItems([UUID()], toSection: .info)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension MovieDetailsViewController {

    func setupSubscribers() {
        guard let viewModel else { return }
        viewModel.dataFetchedPublisher.sink {[weak self] in
            guard let self else { return }
            self.applySnapshot()
        }.store(in: &viewModel.cancellables)

        viewModel.errorPublisher.sink {[weak self] error in
            guard let self else { return }
            showErrorAlert(message: error.localizedDescription)
        }.store(in: &viewModel.cancellables)
    }

    private func showErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                Task { await self.viewModel?.fetchMovieDetailsData() }
            })
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Favorites Handling
extension MovieDetailsViewController {
    @objc private func favoriteTapped() {
        guard let movie = viewModel?.movieDetail else { return }
        favoritesManager.toggle(movie.id ?? 0)
        applySnapshot() // refresh heart icon
    }
}
