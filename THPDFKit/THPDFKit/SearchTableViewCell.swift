//
//  SearchTableViewCell.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 01/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    lazy var destinationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.backgroundColor = UIColor.clear
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return label
    }()
    
    lazy var resultTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 17.0)
        
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [self.destinationLabel, self.resultTextLabel].forEach({ self.contentView.addSubview($0) })
        
        NSLayoutConstraint.activate (
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[destinationLabel]-|", options: [], metrics: nil, views: ["destinationLabel": self.destinationLabel]) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-[resultTextLabel]-|", options: [], metrics: nil, views: ["resultTextLabel": self.resultTextLabel]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[destinationLabel]-[resultTextLabel]-|", options: [], metrics: nil, views: ["destinationLabel": self.destinationLabel, "resultTextLabel": self.resultTextLabel])
        )

    }

}
