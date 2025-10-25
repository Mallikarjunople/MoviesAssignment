//
//  MovieTrailersCell.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 25/10/25.
//

import UIKit
import WebKit

final class MovieTrailerCell: UICollectionViewCell {
    static let reuseId = "MovieTrailerCell"
    private let webView = WKWebView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with url: URL?) {
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }
}
