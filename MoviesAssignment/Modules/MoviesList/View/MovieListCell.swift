//
//  MovieListCell.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 24/10/25.
//

import UIKit
import Combine

class MovieCell: UITableViewCell {
    static let reuseIdentifier = "MovieCell"

    private let textStackView = UIStackView()
    private let mainStackView = UIStackView()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        return button
    }()
    private let ratingLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    private var imageTask: Task<Void, Never>?
    var favoriteAction: (() -> Void)?
    let cellTapPublisher: PassthroughSubject<Void, Never> = .init()
    var cancellables = Set<AnyCancellable>()
    var cellTapAction: (() -> Void)?
    private var movie: Movie?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        imageTask?.cancel()
        cancellables.removeAll()
        movie = nil
    }

    private func setupViews() {
        // Text vertical stack
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .fill
        textStackView.distribution = .fill
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(overviewLabel)

        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(posterImageView)
        mainStackView.addArrangedSubview(textStackView)
        mainStackView.addArrangedSubview(favoriteButton)

        contentView.addSubview(mainStackView)
        contentView.backgroundColor = .systemBackground
        mainStackView.isUserInteractionEnabled = true
        mainStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with movie: Movie) {
        self.movie = movie
        titleLabel.text = movie.title
        ratingLabel.text = movie.voteAverage != nil ? String(format: "⭐︎ %.1f", movie.voteAverage!) : ""
        overviewLabel.text = movie.overview ?? ""
        if let path = movie.posterPath, let url = URL(string: Config.imageBase + path) {
            imageTask = Task {
                if let img = await ImageLoader.shared.load(url: url) {
                    await MainActor.run { self.posterImageView.image = img }
                } else {
                    await MainActor.run { self.posterImageView.backgroundColor = .systemGray5 }
                }
            }
        } else {
            posterImageView.backgroundColor = .systemGray5
        }
    }

    func setFavorited(_ fav: Bool) {
        let name = fav ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func favTapped() {
        guard let movie else { return }
        FavoritesManager.shared.toggle(movie.id)
        setFavorited(FavoritesManager.shared.isFavorite(movie.id))
    }

    @objc private func cellTapped() {
        cellTapPublisher.send()
    }
}
