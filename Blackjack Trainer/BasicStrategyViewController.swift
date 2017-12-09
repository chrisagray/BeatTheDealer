//
//  BasicStrategyViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 5/12/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

class BasicStrategyViewController: UIViewController {
    
    fileprivate var imageView = UIImageView(image: #imageLiteral(resourceName: "Basic Strategy"))
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 1.5
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height*1.75)
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
}

extension BasicStrategyViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}







