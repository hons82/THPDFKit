//
//  PDFSelectionTableViewController.swift
//  THPDFKitDemo
//
//  Created by Hannes Tribus on 06/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import THPDFKit
import CocoaLumberjack

class PDFSelectionTableViewController: UITableViewController {
    
    let samplePDFs: [URL?] = [Bundle.main.url(forResource: "book-of-vaadin", withExtension: "pdf")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samplePDFs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "samplePDF", for: indexPath)
        
        cell.textLabel?.text = samplePDFs[indexPath.row]?.lastPathComponent
        cell.detailTextLabel?.text = samplePDFs[indexPath.row]?.absoluteString
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let selectedRow = indexPath.row
            
            let detailVC = segue.destination as! PDFViewControllerWrapper
            detailVC.url = self.samplePDFs[selectedRow]
            
        }
    }
    
    
}

