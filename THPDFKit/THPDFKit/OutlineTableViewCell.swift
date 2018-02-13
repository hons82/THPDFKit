//
//  OutlineTableViewCell.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 02/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit

class OutlineTableViewCell: UITableViewCell {
    
    lazy var openButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openButtonClick(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        
        return button
    }()
    
    lazy var outlineTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        
        return label
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.backgroundColor = .clear
        
        return label
    }()
    
    var openButtonClick:((_ sender: UIButton) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [self.openButton, self.outlineTextLabel, self.pageLabel].forEach({ self.contentView.addSubview($0) })
        
        NSLayoutConstraint.activate (
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[openButton(==44)]-[outlineTextLabel]-[pageLabel]-|", options: [], metrics: nil, views: ["openButton": self.openButton, "outlineTextLabel": self.outlineTextLabel, "pageLabel": self.pageLabel]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[openButton(==44)]|", options: [], metrics: nil, views: ["openButton": self.openButton])
        )
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.outlineTextLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 1, constant: 0) )
        self.contentView.addConstraint(NSLayoutConstraint(item: self.pageLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 1, constant: 0) )
        
        indentationWidth = 16.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if indentationLevel == 0 {
            outlineTextLabel.font = UIFont.systemFont(ofSize: 17)
            pageLabel.font = UIFont.systemFont(ofSize: 17)
        } else {
            outlineTextLabel.font = UIFont.systemFont(ofSize: 15)
            pageLabel.font = UIFont.systemFont(ofSize: 15)
        }
        
        self.contentView.layoutMargins.left = CGFloat(self.indentationLevel) * self.indentationWidth
        self.contentView.layoutIfNeeded()
    }
    
    @IBAction func openButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        openButtonClick?(sender)
    }
    
}
