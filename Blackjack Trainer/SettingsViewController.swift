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
    //show/hide count
    //dealer hits on soft 17
    @IBOutlet weak var showCountLabel: UILabel!
    @IBOutlet weak var showCountSwitch: UISwitch!
    @IBOutlet weak var dealerHitsSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //instead, try setting default user values for each switch when the app loads. then, the first time the app runs, it will just set them to the default values that you already set.
//        if UserDefaults.standard.bool(forKey: "showCountSwitchHasBeenSet") {
//            print("showCountSwitchHasBeenSet")
        showCountSwitch.isOn = UserDefaults.standard.bool(forKey: "showCountState")
//        }
//        if UserDefaults.standard.bool(forKey: "dealerHitsSwitchHasBeenSet") {
//            print("dealerHitsSwitchHasBeenSet")
        dealerHitsSwitch.isOn = UserDefaults.standard.bool(forKey: "dealerHitsState")
//        }
    }
    
    @IBAction func changeCountState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("showOrHideCount"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "showCountState")
//        if !UserDefaults.standard.bool(forKey: "showCountSwitchHasBeenSet") {
//            UserDefaults.standard.set(true, forKey: "showCountSwitchHasBeenSet")
//        }
    }
    
    @IBAction func changeDealerHitsState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("changeDealerHitsOnSoft17"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "dealerHitsState")
        //do I need multiple user default values for each switch?
//        if !UserDefaults.standard.bool(forKey: "dealerHitsSwitchHasBeenSet") {
//            UserDefaults.standard.set(true, forKey: "dealerHitsSwitchHasBeenSet")
//        }
    }
}
