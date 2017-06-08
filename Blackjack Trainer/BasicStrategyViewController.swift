//
//  BasicStrategyViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 5/12/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

class BasicStrategyViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height*1.75)
        let basicStrategyImage = #imageLiteral(resourceName: "Basic Strategy")
        let basicStrategyImageView = UIImageView(image: basicStrategyImage)
        basicStrategyImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: scrollView.contentSize.height)
        basicStrategyImageView.center.x = view.center.x
        scrollView.addSubview(basicStrategyImageView)
        basicStrategyImageView.contentMode = .scaleAspectFit
    }
}
