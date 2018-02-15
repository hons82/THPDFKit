//
//  PDFViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 31/01/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit

@objc public protocol PDFViewControllerDelegate: class {
    func pdfViewController(_ pdfViewController: PDFViewController, didBookmarkPage page: Int, inPdf url: URL)
    func pdfViewController(_ pdfViewController: PDFViewController, willClickOnLink url: URL)
}

@objc public protocol PDFViewController: class {
    var url: URL? { get set }
    func go(to page:Int)
}

open class PDFViewControllerWrapper: UIViewController, PDFViewController {
    
    open var url: URL? {
        didSet{
            if let url = url {
                activeViewController.url = url
            }
        }
    }
    
    static func factory() -> PDFViewController {
        if #available(iOS 11.0, *) {
            return PDFKitViewController()
        } else {
            // Fallback on earlier versions
            return QLViewController()
        }
    }
    
    private var activeViewController: PDFViewController = PDFViewControllerWrapper.factory() {
        didSet {
            removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController()
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
        if let aVC = activeViewController as? PDFKitViewController {
            aVC.thumbnailSize = CGSize(width: 30.0, height: 45.0)
        }
        }
        updateActiveViewController()
    }
    
    open func go(to page:Int) {
        activeViewController.go(to: page)
    }
    
    private func removeInactiveViewController(inactiveViewController: PDFViewController?) {
        if let inActiveVC = inactiveViewController as? UIViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParentViewController: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController as? UIViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = view.bounds
            view.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMove(toParentViewController: self)
        }
    }
    
}
