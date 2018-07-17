//
//  UIDesign.swift
//  Beat the Dealer
//
//  Created by Chris Gray on 12/29/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation
import UIKit

class UIDesign {
    
    private static let cornerRadius: CGFloat = 5
    private static let blackGradientColors = setColorsForGradients(topRed: 65/255, topGreen: 67/255, topBlue: 69/255, topAlpha: 1, bottomRed: 35/255, bottomGreen: 37/255, bottomBlue: 39/255, bottomAlpha: 1)
    private static let pinkGradientColors = setColorsForGradients(topRed: 255/255, topGreen: 0, topBlue: 132/255, topAlpha: 1, bottomRed: 51/255, bottomGreen: 0, bottomBlue: 27/255, bottomAlpha: 1)

    class func configureDesign(actionButtons: [UIButton], titleLabels: [UILabel], dealButton: UIButton, view: UIView) {
        actionButtons.forEach {
            $0.layer.cornerRadius = cornerRadius
        }
        
        setGradient(for: actionButtons, colors: blackGradientColors, cornerRadius: cornerRadius, view: view)
        setGradient(for: titleLabels, colors: pinkGradientColors, cornerRadius: cornerRadius, view: view)
        setGradient(for: [dealButton], colors: pinkGradientColors, cornerRadius: cornerRadius, view: view)
    }
    
    private class func setColorsForGradients(topRed: CGFloat, topGreen: CGFloat, topBlue: CGFloat, topAlpha: CGFloat, bottomRed: CGFloat, bottomGreen: CGFloat, bottomBlue: CGFloat, bottomAlpha: CGFloat) -> [CGColor] {
        let topColor = UIColor(red: topRed, green: topGreen, blue: topBlue, alpha: topAlpha).cgColor
        let bottomColor = UIColor(red: bottomRed, green: bottomGreen, blue: bottomBlue, alpha: bottomAlpha).cgColor
        return [topColor, bottomColor]
    }
    
    class func setGradient(for objects: [Any], colors: [CGColor], cornerRadius: CGFloat, view: UIView) {
        
        if let buttons = objects as? [UIButton] {
            buttons.forEach { button in
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = colors
                gradientLayer.cornerRadius = cornerRadius
                gradientLayer.frame = button.bounds
                button.layer.masksToBounds = true
                button.layer.insertSublayer(gradientLayer, at: 0)
            }
        } else if let labels = objects as? [UILabel] {
            labels.forEach({ label in
                let gradientView = UIView()
                gradientView.frame = label.frame
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = gradientView.bounds
                gradientLayer.colors = colors
                gradientLayer.cornerRadius = cornerRadius
                gradientView.layer.addSublayer(gradientLayer)
                view.insertSubview(gradientView, at: 0)
            })
        }
    }
}
