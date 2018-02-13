//
//  QLViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 07/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import QuickLook

class QLViewController: QLPreviewController, PDFViewController  {
    
    open var url: URL? {
        didSet{
            if let url = url {
                urls = [url]
            }
        }
    }
    
    lazy var urls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource  = self
    }
    
    // MARK: - PDFViewController
    
    public func go(to page: Int) {
        print("Quicklook does not support this feature")
    }

}

extension QLViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print("Show item at \(index) which will be \(urls[index].absoluteString)")
        return NSURL(string: (urls[index].absoluteString))!
    }
    
}
