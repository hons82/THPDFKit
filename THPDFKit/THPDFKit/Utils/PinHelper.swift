//
//  PinHelper.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 07/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit

extension UIStackView {
    
    func pinBackground(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, at: 0)
        view.pin(to: self)
    }
    
}

extension UIView {
    
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
}
