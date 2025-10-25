//
//  BadgeView.swift
//  MoviesAssignment
//
//  Created by Mallikarjun Ople on 25/10/25.
//

import UIKit

final class BadgeView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(text: String) {
        super.init(frame: .zero)
        setupUI(text: text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(text: String) {
        label.text = text
        self.backgroundColor = .systemBlue
        self.layer.cornerRadius = 8
        self.clipsToBounds = true

        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
