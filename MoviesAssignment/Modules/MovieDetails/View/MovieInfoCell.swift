//
//  MovieInfoCell.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 25/10/25.
//

import UIKit

final class MovieInfoCell: UICollectionViewCell {
    static let reuseId = "MovieInfoCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemYellow
        return label
    }()

    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }()

    private let headerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let genresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(favoriteButton)

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(ratingLabel)
        contentStack.addArrangedSubview(durationLabel)
        contentStack.addArrangedSubview(genresStackView)
        contentStack.addArrangedSubview(overviewLabel)

        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }

    // MARK: - Configure

    func configure(with movie: MovieDetails, isFavorite: Bool) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        durationLabel.text = "Duration: \(movie.formattedDuration)"
        if let rating = movie.voteAverage {
            ratingLabel.text = "⭐️ \(String(format: "%.1f", rating))"

        }

        setupGenres(movie.genres ?? [])
        updateFavoriteButton(isFavorite: isFavorite)
    }

    private func setupGenres(_ genres: [Genre]) {
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Genres : "
        genresStackView.addArrangedSubview(label)

        for genre in genres {
            let badge = BadgeView(text: genre.name ?? "")
            genresStackView.addArrangedSubview(badge)
        }

        genresStackView.addArrangedSubview(UIView())
    }

    func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}


