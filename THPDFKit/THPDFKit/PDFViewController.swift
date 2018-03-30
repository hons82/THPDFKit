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
    
    let configuration: PDFViewControllerConfiguration?
    
    open var url: URL? {
        didSet{
            if let url = url {
                activeViewController.url = url
            }
        }
    }
    
    static func factory(with configuration: PDFViewControllerConfiguration? = nil) -> PDFViewController {
        if #available(iOS 11.0, *) {
            return PDFKitViewController(configuration: configuration)
        } else {
            // Fallback on earlier versions
            return QLViewController()
        }
    }
    
    private var activeViewController: PDFViewController {
        didSet {
            removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController()
        }
    }
    
    init(configuration: PDFViewControllerConfiguration? = nil) {
        self.configuration = configuration
        self.activeViewController = PDFViewControllerWrapper.factory(with: configuration)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration = PDFViewControllerConfiguration()
        self.activeViewController = PDFViewControllerWrapper.factory(with: self.configuration)
        
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
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
