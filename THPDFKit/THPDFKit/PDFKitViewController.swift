//
//  PDFKitViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 31/01/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import PDFKit


public struct PDFViewControllerConfiguration {
    
    public enum ThumbnailDisplayMode: Int {
        case overlay
        case fixed
    }
    
    // These are the default properties for a new configuration
    public let thumbnailDisplayMode: ThumbnailDisplayMode
    public let thumbnailSize: CGSize
    public let thumbnailViewHeight: CGFloat

    public init(thumbnailDisplayMode: ThumbnailDisplayMode? = nil, thumbnailSize: CGSize? = nil, thumbnailViewHeight: CGFloat? = nil) {
        self.thumbnailDisplayMode = thumbnailDisplayMode ?? .overlay
        self.thumbnailSize = thumbnailSize ?? CGSize(width: 50.0, height: 75.0)
        self.thumbnailViewHeight = thumbnailViewHeight ?? 100.0
    }
    
}

@available(iOS 11.0, *)
open class PDFKitViewController: UIViewController, PDFViewController {
    
    open var url: URL? {
        didSet{
            if let url = url {
                pdfdocument = PDFDocument(url: url)
            }
        }
    }
    
    var pdfdocument: PDFDocument?
    
    fileprivate lazy var pdfView: PDFView = {
        let view = PDFView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.displayMode = .singlePage
        view.displaysAsBook = true
        view.displayDirection = .horizontal
        view.autoScales = true
        
        return view
    }()
    
    @objc open lazy var tintColor: UIColor = self.view.tintColor
    
    private lazy var toolViewBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.borderWidth = 1.0
        view.layer.borderColor = tintColor.cgColor
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    fileprivate lazy var toolView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 1.0
        view.pinBackground(toolViewBackgroundView)
        
        return view
    }()
    
    fileprivate lazy var thumbnailView: PDFThumbnailView = {
        let view = PDFThumbnailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMode = .horizontal
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.pdfView = self.pdfView
        view.thumbnailSize = configuration.thumbnailSize
        
        return view
    }()
    
    fileprivate lazy var thumbnailViewBottomContraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.thumbnailView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
    }()
    
    fileprivate lazy var thumbnailViewHeightContraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.thumbnailView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.configuration.thumbnailViewHeight)
    }()
    
    @objc open weak var delegate: PDFViewControllerDelegate?
    
    let configuration: PDFViewControllerConfiguration
    
    
    // MARK: - Initialization
    
    public init(configuration: PDFViewControllerConfiguration? = nil) {
        self.configuration = configuration ?? PDFViewControllerConfiguration()
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration = PDFViewControllerConfiguration()
        super.init(coder: aDecoder)
    }
    
    // MARK: - ViewController Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.document = pdfdocument
        
        addToolButtons(stackView: toolView)
        
        [self.pdfView, self.toolView, self.thumbnailView].forEach({ self.view.addSubview($0) })
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pdfView]-|", options: [], metrics: nil, views: ["pdfView": self.pdfView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[thumbnailView]|", options: [], metrics: nil, views: ["thumbnailView": self.thumbnailView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:[toolView]-32-[thumbnailView]", options: [], metrics: nil, views: ["toolView": self.toolView, "thumbnailView": self.thumbnailView])
        )
        
        self.view.addConstraint(NSLayoutConstraint(item: self.toolView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraints([thumbnailViewHeightContraint])
        
        if configuration.thumbnailDisplayMode == .overlay {
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pdfView]-|", options: [], metrics: nil, views: ["pdfView": self.pdfView]))
            
            self.view.addConstraints([thumbnailViewBottomContraint])
            
            toolView.bringSubview(toFront: self.view)
        }
        else if configuration.thumbnailDisplayMode == .fixed {
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|[thumbnailView]|", options: [], metrics: nil, views: ["thumbnailView": self.thumbnailView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pdfView]-[thumbnailView]|", options: [], metrics: nil, views: ["pdfView": self.pdfView, "thumbnailView": self.thumbnailView])
            )
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        ([.right, .down, .left, .up] as [UISwipeGestureRecognizerDirection]).forEach({
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
            swipeGesture.direction = $0
            swipeGesture.cancelsTouchesInView = false
            self.pdfView.addGestureRecognizer(swipeGesture)
        })
        updateOrientation(landscape: UIApplication.shared.statusBarOrientation.isLandscape)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleToolView()
        hideThumbnailView()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateOrientation(landscape: UIDevice.current.orientation.isLandscape)
    }
    
    func addToolButtons(stackView: UIStackView) {
        let buttons: [[String: Any]] = [["imagename": "btn-thumbnails", "selector": #selector(thumbButtonClick(_:))],
                                        ["imagename": "btn-outline", "selector": #selector(outlineButtonClick(_:))],
                                        ["imagename": "btn-bookmark", "selector": #selector(bookmarkButtonClick(_:))],
                                        ["imagename": "btn-search", "selector": #selector(searchButtonClick(_:))]]
        for buttonDic in buttons {
            guard let imagename = buttonDic["imagename"] as? String, let selector = buttonDic["selector"] as? Selector else {
                print("coding error, buttons are wrong")
                continue
            }
            if stackView.arrangedSubviews.count > 0 {
                let view = UIView()
                view.backgroundColor = tintColor
                view.heightAnchor.constraint(equalToConstant: 44).isActive = true
                view.widthAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(view)
            }
            
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: imagename, in: Bundle(for: PDFKitViewController.classForCoder()), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = tintColor
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.widthAnchor.constraint(equalToConstant: 88).isActive = true
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.backgroundColor = .clear
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Button Actions
    
    @objc open func thumbButtonClick(_ sender: UIButton!) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        
        let width = floor((min(view.frame.height, view.frame.width) - 10 * 4) / 3)
        let height = width * 1.3
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        let thumbnailCollectionViewController = ThumbnailCollectionViewController(collectionViewLayout: layout)
        thumbnailCollectionViewController.pdfDocument = pdfdocument
        thumbnailCollectionViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: thumbnailCollectionViewController)
        self.present(nav, animated: false, completion:nil)
    }
    
    @objc open func outlineButtonClick(_ sender: UIButton) {
        if let pdfoutline = pdfdocument?.outlineRoot {
            let oulineViewController = OutlineTableViewController(style: UITableViewStyle.plain)
            oulineViewController.pdfOutlineRoot = pdfoutline
            oulineViewController.delegate = self
            
            let nav = UINavigationController(rootViewController: oulineViewController)
            self.present(nav, animated: false, completion:nil)
        }
    }
    
    @objc open func bookmarkButtonClick(_ sender: UIButton) {
        guard let page = pdfView.currentPage, let index = pdfdocument?.index(for: page), let pdfUrl = pdfdocument?.documentURL else {
            print("could not Bookmark page \(pdfView.currentPage?.label ?? "<Not found>") of \(pdfdocument?.documentURL?.absoluteString ?? "<Not found>")")
            return
        }
        print("Bookmark page \(index) in \(pdfUrl.absoluteString)")
        delegate?.pdfViewController(self, didBookmarkPage: index, inPdf: pdfUrl)
    }
    
    @objc open func searchButtonClick(_ sender: UIButton) {
        let searchViewController = SearchTableViewController()
        searchViewController.pdfDocument = pdfdocument
        searchViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: searchViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion:nil)
    }
    
    // MARK: Gesture Actions
    
    @objc func swipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else {
            print("Swipe state is not yet recognized")
            return
        }
        
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        switch gestureRecognizer.direction {
        case .right:
            if thumbnailViewBottomContraint.constant > 0  || location.y < pdfView.frame.size.height - thumbnailViewHeightContraint.constant {
                gotoPreviousPage()
            }
        case .down:
            hideThumbnailView()
        case .left:
            if thumbnailViewBottomContraint.constant > 0  || location.y < pdfView.frame.size.height - thumbnailViewHeightContraint.constant {
                gotoNextPage()
            }
        case .up:
            showThumbnailView()
        default:
            print("Swiped into n-dimensional space... probably")
            break
        }
    }
    
    @objc func tapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else {
            print("Touch state is not yet recognized")
            return
        }
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let touchAreaWidth: CGFloat = 100
        if location.x < touchAreaWidth && (thumbnailViewBottomContraint.constant > 0  || location.y < pdfView.frame.size.height - thumbnailViewHeightContraint.constant){
            gotoPreviousPage()
        } else if location.x > pdfView.frame.size.width - touchAreaWidth && (thumbnailViewBottomContraint.constant > 0  || location.y < pdfView.frame.size.height - thumbnailViewHeightContraint.constant) {
            gotoNextPage()
        } else if location.y > pdfView.frame.size.height - 22 {
            showThumbnailView()
        } else {
            toggleToolView()
        }
    }
    
    func gotoPreviousPage() {
        if pdfView.canGoToPreviousPage() {
            UIView.animate(withDuration:CATransaction.animationDuration(), animations: { [weak self] in
                self?.pdfView.alpha = 0.0
                }, completion: { [weak self] (finished: Bool) in
                    self?.hideThumbnailView()
                    self?.pdfView.goToPreviousPage(self)
                    if let scaleFactorForSizeToFit = self?.pdfView.scaleFactorForSizeToFit {
                        self?.pdfView.scaleFactor = scaleFactorForSizeToFit
                    }
                    UIView.animate(withDuration:CATransaction.animationDuration(), animations: {
                        self?.pdfView.alpha = 1.0
                    })
            })
        } else {
            print("There is no previous page")
        }
    }
    
    func gotoNextPage() {
        if pdfView.canGoToNextPage() {
            UIView.animate(withDuration:CATransaction.animationDuration(), animations: { [weak self] in
                self?.pdfView.alpha = 0.0
                }, completion: { [weak self] (finished: Bool) in
                    self?.hideThumbnailView()
                    self?.pdfView.goToNextPage(self)
                    if let scaleFactorForSizeToFit = self?.pdfView.scaleFactorForSizeToFit {
                        self?.pdfView.scaleFactor = scaleFactorForSizeToFit
                    }
                    UIView.animate(withDuration:CATransaction.animationDuration(), animations: {
                        self?.pdfView.alpha = 1.0
                    })
            })
        } else {
            print("There is no next page")
        }
    }
    
    func toggleToolView() {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.toolView.alpha = 1 - (self?.toolView.alpha)!
        }
    }
    
    func hideThumbnailView() {
        guard thumbnailViewBottomContraint.constant == 0 else {
            return
        }
        thumbnailViewBottomContraint.constant = thumbnailView.frame.size.height
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func showThumbnailView() {
        guard thumbnailViewBottomContraint.constant > 0 else {
            return
        }
        thumbnailViewBottomContraint.constant = 0
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func updateOrientation(landscape isLandscape: Bool = true) {
        UIView.animate(withDuration:CATransaction.animationDuration(), animations: { [weak self] in
            self?.pdfView.alpha = 0.0
            }, completion: { [weak self] (finished: Bool) in
                self?.pdfView.displayMode = isLandscape ? .twoUp : .singlePage
                if let scaleFactorForSizeToFit = self?.pdfView.scaleFactorForSizeToFit {
                    self?.pdfView.scaleFactor = scaleFactorForSizeToFit
                }
                UIView.animate(withDuration:CATransaction.animationDuration(), animations: {
                    self?.pdfView.alpha = 1.0
                })
        })
    }
    
    // MARK: - PDFViewController
    
    public func go(to page: Int) {
        guard let pageCount = pdfdocument?.pageCount, pageCount > page else {
            print("Page is out of bounds")
            return
        }
        guard let pdfPage = pdfdocument?.page(at: page) else {
            print("Could not get page for index")
            return
        }
        pdfView.go(to: pdfPage)
    }
    
}

@available(iOS 11.0, *)
extension PDFKitViewController: PDFViewDelegate {
    
    public func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        if let delegate = delegate {
            delegate.pdfViewController(self, willClickOnLink: url)
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}

@available(iOS 11.0, *)
extension PDFKitViewController: OutlineTableViewControllerDelegate {
    
    func outlineTableViewController(_ outlineTableViewController: OutlineTableViewController, didSelectOutline outline: PDFOutline) {
        if let actiongoto = outline.action as? PDFActionGoTo {
            pdfView.go(to: actiongoto.destination)
        }
    }
    
}

@available(iOS 11.0, *)
extension PDFKitViewController: ThumbnailCollectionViewControllerDelegate {
    
    func thumbnailCollectionViewController(_ thumbnailCollectionViewController: ThumbnailCollectionViewController, didSelectPage page: PDFPage) {
        pdfView.go(to: page)
    }
    
}

@available(iOS 11.0, *)
extension PDFKitViewController: SearchTableViewControllerDelegate {
    
    func searchTableViewController(_ searchTableViewController: SearchTableViewController, didSelectSerchResult selection: PDFSelection) {
        selection.color = UIColor.yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
    }
    
}
