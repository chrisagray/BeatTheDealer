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
    @IBOutlet weak var showTotalsSwitch: UISwitch!
    
    @IBOutlet weak var handsPlayedLabel: UILabel!
    @IBOutlet weak var handsWonLabel: UILabel!
    @IBOutlet weak var winPercentageLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var percentCorrectLabel: UILabel!
    
    
    @IBOutlet var allLabels: [UILabel]!
    
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet var switches: [UISwitch]!
    
    @IBOutlet weak var numberOfDecksSlider: UISlider!
    @IBOutlet weak var numberOfDecksLabel: UILabel!
    
    @IBOutlet weak var settingsStackView: UIStackView!
    
    var handsPlayed = 0
    var handsWon = 0
    var winPercentage = 0
    
    var correctActions = 0
    var incorrectActions = 0
    var percentCorrect = 0
    
    var previousSliderValue = 0
    var roundedValue: Int {
        return Int(round(numberOfDecksSlider.value))
    }
    var numberOfDecksWasChanged = false
    
    override func viewWillLayoutSubviews() {
        let iPhoneHeight = UIScreen.main.bounds.height
        if iPhoneHeight == 568 || iPhoneHeight == 480 {
            configureUI(iPhoneHeight: iPhoneHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCountSwitch.isOn = UserDefaults.standard.bool(forKey: "showCountState")
        dealerHitsSwitch.isOn = UserDefaults.standard.bool(forKey: "dealerHitsState")
        showTotalsSwitch.isOn = UserDefaults.standard.bool(forKey: "showTotalsState")
        setTextForLabels()
        numberOfDecksSlider.setValue(Float(previousSliderValue), animated: false)
        numberOfDecksLabel.text = String(previousSliderValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            if roundedValue != previousSliderValue {
                let numberDict = ["number": roundedValue]
                NotificationCenter.default.post(name: NSNotification.Name("changeNumberOfDecks"), object: nil, userInfo: numberDict)
                previousSliderValue = roundedValue
            }
        }
    }
    
    private func configureUI(iPhoneHeight: CGFloat) {
        var labelFont: CGFloat = 21
        var switchPercentage: CGFloat = 1
        
        if iPhoneHeight == 568 {
            labelFont = 16
            switchPercentage = 0.85
        } else if iPhoneHeight == 480 {
            labelFont = 15
            switchPercentage = 0.75
        }
        for label in allLabels {
            label.font = UIFont.systemFont(ofSize: labelFont)
        }
        for optionSwitch in switches {
            optionSwitch.transform = CGAffineTransform(scaleX: switchPercentage, y: switchPercentage)
        }
        settingsStackView.spacing = 50
    }
    
    private func setTextForLabels() {
        handsPlayedLabel.text = "Hands played: \(handsPlayed)"
        handsWonLabel.text = "Hands won: \(handsWon)"
        winPercentageLabel.text = "Win percentage: \(winPercentage)%"
        correctLabel.text = "Correct: \(correctActions)"
        incorrectLabel.text = "Incorrect: \(incorrectActions)"
        percentCorrectLabel.text = "Percent correct: \(percentCorrect)%"
    }
    
    @IBAction func changeNumberOfDecks(_ slider: UISlider) {
        numberOfDecksLabel.text = String(roundedValue)
    }
    
    //should probably make objects in .post be self
    
    @IBAction func changeCountState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("showOrHideCount"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "showCountState")
    }
    
    @IBAction func changeDealerHitsState(_ sender: UISwitch) {
        NotificationCenter.default.post(name: NSNotification.Name("changeDealerHitsOnSoft17"), object: nil)
        UserDefaults.standard.set(sender.isOn, forKey: "dealerHitsState")
    }
    
    @IBAction func changeShowTotalsState(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showTotalsState")
        NotificationCenter.default.post(name: NSNotification.Name("changeShowTotals"), object: nil)
    }
    
}
