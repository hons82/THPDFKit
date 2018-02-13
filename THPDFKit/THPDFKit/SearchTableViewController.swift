//
//  SearchTableViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 01/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
protocol SearchTableViewControllerDelegate: class {
    func searchTableViewController(_ searchTableViewController: SearchTableViewController, didSelectSerchResult selection: PDFSelection)
}

@available(iOS 11.0, *)
class SearchTableViewController: UITableViewController {
    
    let searchTableViewCellReuseIdentifier = "SearchTableViewCell"
    
    fileprivate lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        
        return searchBar
        }()
    
    var searchResults = [PDFSelection]()
    
    open var pdfDocument: PDFDocument?
    weak var delegate: SearchTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
        
        tableView.register(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: searchTableViewCellReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cancelButtonClicked(sender: UIBarButtonItem) {
        cancelPressed()
    }
    
    fileprivate func cancelPressed() {
        pdfDocument?.cancelFindString()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchTableViewCellReuseIdentifier, for: indexPath) as! SearchTableViewCell
        
        let selection = searchResults[indexPath.row]
        let page = selection.pages[0]
        let outline = pdfDocument?.outlineItem(for: selection)
        
        let outlintstr = outline?.label ?? ""
        let pagestr = page.label ?? ""
        let txt = outlintstr + " \(NSLocalizedString("Page", comment: "To be translated")):  " + pagestr
        cell.destinationLabel.text = txt
        
        let extendSelection = selection.copy() as! PDFSelection
        extendSelection.extend(atStart: 10)
        extendSelection.extend(atEnd: 90)
        extendSelection.extendForLineBoundaries()
        
        let range = (extendSelection.string! as NSString).range(of: selection.string!, options: .caseInsensitive)
        let attrstr = NSMutableAttributedString(string: extendSelection.string!)
        attrstr.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
        
        cell.resultTextLabel.attributedText = attrstr
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = searchResults[indexPath.row]
        
        delegate?.searchTableViewController(self, didSelectSerchResult: selection)
        dismiss(animated: false, completion: nil)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

@available(iOS 11.0, *)
extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelPressed()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 2 {
            return
        }
        
        searchResults.removeAll()
        tableView.reloadData()
        if let pdfDocument = pdfDocument {
            pdfDocument.cancelFindString()
            pdfDocument.delegate = self
            pdfDocument.beginFindString(searchText, withOptions: .caseInsensitive)
        }
    }
    
}

@available(iOS 11.0, *)
extension SearchTableViewController: PDFDocumentDelegate {
    
    func didMatchString(_ instance: PDFSelection) {
        searchResults.append(instance)
        tableView.reloadData()
    }
    
}
