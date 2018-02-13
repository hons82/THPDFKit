//
//  ThumbnailCollectionViewCell.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 01/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 6.0
        label.layer.masksToBounds = true
        
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        [self.imageView, self.pageLabel].forEach({ self.contentView.addSubview($0) })
        
        NSLayoutConstraint.activate (
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-|", options: [], metrics: nil, views: ["imageView": self.imageView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageView]-|", options: [], metrics: nil, views: ["imageView": self.imageView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:[pageLabel(>=44)]", options: [], metrics: nil, views: ["pageLabel": self.pageLabel]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:[pageLabel(==22)]-16-|", options: [], metrics: nil, views: ["pageLabel": self.pageLabel])
        )
        
        self.addConstraint(NSLayoutConstraint(item: self.pageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0) )

    }
    
}
