//
//  UIView+Utility.swift
//  Rapido-Assignment-1
//
//  Created by Pranjal Agarwal on 11/09/24.
//

import UIKit

extension UIView {

    func setTranslatesMask() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    func pinToEdges(in view: UIView) {
        [
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ].forEach { constraint in
            constraint.isActive = true
        }
    }

    func pinToSafeEdges(in view: UIView) {

        [
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { constraint in
            constraint.isActive = true
        }

    }
}
