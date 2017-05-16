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
        //doesn't look like standard constraints are added after setting the frame
        //want the frame to be 20 points away from the bottom of the scroll view
        basicStrategyImageView.center.x = view.center.x
        scrollView.addSubview(basicStrategyImageView)
        basicStrategyImageView.contentMode = .scaleAspectFit
    }
}
