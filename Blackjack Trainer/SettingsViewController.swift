//
//  SettingsViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 4/26/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var showCountLabel: UILabel!
    @IBOutlet weak var showCountSwitch: UISwitch!
    @IBOutlet weak var dealerHitsSwitch: UISwitch!
    
    @IBOutlet weak var handsPlayedLabel: UILabel!
    @IBOutlet weak var handsWonLabel: UILabel!
    @IBOutlet weak var winPercentageLabel: UILabel!
    
    var handsPlayed = 0
    var handsWon = 0
    var winPercentage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCountSwitch.isOn = UserDefaults.standard.bool(forKey: "showCountState")
        dealerHitsSwitch.isOn = UserDefaults.standard.bool(forKey: "dealerHitsState")
        handsPlayedLabel.text = "Hands played: \(handsPlayed)"
        handsWonLabel.text = "Hands won: \(handsWon)"
        winPercentageLabel.text = "Win percentage: \(winPercentage)%"
    }
    
    @IBAction func changeCountState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("showOrHideCount"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "showCountState")
    }
    
    @IBAction func changeDealerHitsState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("changeDealerHitsOnSoft17"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "dealerHitsState")
    }
}
