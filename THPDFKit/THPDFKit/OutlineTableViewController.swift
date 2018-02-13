//
//  OutlineTableViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 02/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
protocol OutlineTableViewControllerDelegate: class{
    func outlineTableViewController(_ outlineTableViewController: OutlineTableViewController, didSelectOutline outline: PDFOutline)
}

@available(iOS 11.0, *)
class OutlineTableViewController: UITableViewController {
    
    private struct WrappedBundleImage: _ExpressibleByImageLiteral {
        let image: UIImage
        
        init(imageLiteralResourceName name: String) {
            let bundle = Bundle(for: OutlineTableViewController.classForCoder())
            image = UIImage(named: name, in: bundle, compatibleWith: nil)!
        }
    }
    
    let outlineTableViewCellReuseIdentifier = "OutlineTableViewCell"
    
    open var pdfOutlineRoot: PDFOutline? {
        didSet{
            for index in 0...(pdfOutlineRoot?.numberOfChildren)!-1 {
                let pdfOutline = pdfOutlineRoot?.child(at: index)
                pdfOutline?.isOpen = false
                data.append(pdfOutline!)
            }
            tableView.reloadData()
        }
    }
    
    var data = [PDFOutline]()
    
    weak var delegate: OutlineTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeBtnClick))
        
        tableView.register(OutlineTableViewCell.classForCoder(), forCellReuseIdentifier: outlineTableViewCellReuseIdentifier)
    }
    
    @objc func closeBtnClick(sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: outlineTableViewCellReuseIdentifier, for: indexPath) as! OutlineTableViewCell
        
        let outline = data[indexPath.row];
        
        cell.outlineTextLabel.text = outline.label
        cell.pageLabel.text = outline.destination?.page?.label
        
        if outline.numberOfChildren > 0 {
            cell.openButton.setImage(((outline.isOpen ? #imageLiteral(resourceName: "arrow_down") : #imageLiteral(resourceName: "arrow_right")) as WrappedBundleImage).image, for: .normal)
            cell.openButton.isEnabled = true
        } else {
            cell.openButton.setImage(nil, for: .normal)
            cell.openButton.isEnabled = false
        }
        
        cell.openButtonClick = {[weak self] (sender)-> Void in
            if outline.numberOfChildren > 0 {
                if sender.isSelected {
                    outline.isOpen = true
                    self?.insertChildren(parent: outline)
                } else {
                    outline.isOpen = false
                    self?.removeChildren(parent: outline)
                }
                tableView.reloadData()
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let outline = data[indexPath.row];
        let depth = findDepth(outline: outline)
        return depth;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let outline = data[indexPath.row]
        delegate?.outlineTableViewController(self, didSelectOutline: outline)
        dismiss(animated: false, completion: nil)
    }
    
    func findDepth(outline: PDFOutline) -> Int {
        var depth: Int = -1
        var tmp = outline
        while (tmp.parent != nil) {
            depth = depth + 1
            tmp = tmp.parent!
        }
        return depth
    }
    
    func insertChildren(parent: PDFOutline) {
        var tmpData: [PDFOutline] = []
        let baseIndex = self.data.index(of: parent)
        for index in 0..<parent.numberOfChildren {
            if let pdfOutline = parent.child(at: index) {
                pdfOutline.isOpen = false
                tmpData.append(pdfOutline)
            }
        }
        self.data.insert(contentsOf: tmpData, at:baseIndex! + 1)
    }
    
    func removeChildren(parent: PDFOutline) {
        if parent.numberOfChildren <= 0 {
            return
        }
        
        for index in 0..<parent.numberOfChildren {
            if let node = parent.child(at: index) {
                
                if node.numberOfChildren > 0 {
                    removeChildren(parent: node)
                    
                    // remove self
                    if let i = data.index(of: node) {
                        data.remove(at: i)
                    }
                } else {
                    if self.data.contains(node) {
                        if let i = data.index(of: node) {
                            data.remove(at: i)
                        }
                    }
                }
            }
        }
    }
    
}

