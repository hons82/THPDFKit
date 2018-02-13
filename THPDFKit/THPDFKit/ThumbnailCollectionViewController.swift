//
//  ThumbnailCollectionViewController.swift
//  THPDFKit
//
//  Created by Hannes Tribus on 01/02/2018.
//  Copyright © 2018 3Bus. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
protocol ThumbnailCollectionViewControllerDelegate: class {
    func thumbnailCollectionViewController(_ thumbnailCollectionViewController: ThumbnailCollectionViewController, didSelectPage page: PDFPage)
}

@available(iOS 11.0, *)
class ThumbnailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let thumbnailCollectionViewCellReuseIdentifier = "ThumbnailCollectionViewCell"
    
    open var pdfDocument: PDFDocument?
    weak var delegate: ThumbnailCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Thumbnails", comment: "To be translated")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeBtnClick))
        
        collectionView?.register(ThumbnailCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: thumbnailCollectionViewCellReuseIdentifier)
        
        collectionView?.backgroundColor = UIColor.gray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func closeBtnClick(sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbnailCollectionViewCellReuseIdentifier, for: indexPath) as! ThumbnailCollectionViewCell
        
        if let page = pdfDocument?.page(at: indexPath.item) {
            cell.imageView.image = page.thumbnail(of: cell.bounds.size, for: PDFDisplayBox.cropBox)
            cell.pageLabel.text = page.label
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let page = pdfDocument?.page(at: indexPath.item) {
            dismiss(animated: false, completion: nil)
            delegate?.thumbnailCollectionViewController(self, didSelectPage: page)
        }
    }
}

