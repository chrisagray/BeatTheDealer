//
//  ViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

class BlackjackViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet var dealerCards: [UIImageView]!
    @IBOutlet var gamblerCards: [UIImageView]!
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var correctPlayLabel: UILabel!
    @IBOutlet weak var dealerTitleLabel: UILabel!
    @IBOutlet weak var playerTitleLabel: UILabel!
    
    @IBOutlet weak var cardWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gamblerFirstCardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gamblerSecondCardTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var allLabels: [UILabel]!
    
    var correctActions = 0
    var incorrectActions = 0
    var percentCorrect: Int {
        if game.handsPlayed == 0 || (correctActions == 0 && incorrectActions == 0) {
            return 0
        }
        return Int(Double(correctActions)/(Double(correctActions + incorrectActions))*100)
    }
    
    let currentHandCircle = UIImageView(image: #imageLiteral(resourceName: "Current Hand Circle"))

    private var newCardImages = [UIImageView]()
    private var previousCard = UIImageView()
    private var topColorGradient = UIColor.clear.cgColor
    private var bottomColorGradient = UIColor.clear.cgColor
    
    private var gradientColors: [CGColor] {
        get {
            return [topColorGradient, bottomColorGradient]
        }
    }
    
    private var numberOfEdgeHits = 0
    private var numberOfCardsHitToPlayer = 0
    private var maxCardsToHitBeforeOverlap = 6
    private var previousHandWasSplit = false
    private var handIsOver = false
    private var aces = false
    private var dealerHitsOnSoft17 = false
    private var hitCardDistance: CGFloat = 0
    
    private var game = BlackjackGame()
    
    private var gamblerHas21OrBusts: Bool {
        return game.gambler.currentHand.total >= 21
    }
    
    @IBOutlet private weak var gamblerTotalLabel: UILabel!
    @IBOutlet weak var dealerTotalLabel: UILabel!
    @IBOutlet var actionButtons: [UIButton]!
    private var splitHandTotalLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showOrHideCount), name: NSNotification.Name("showOrHideCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeDealerHitsOnSoft17), name: NSNotification.Name("changeDealerHitsOnSoft17"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeNumberOfDecks(_:)), name: NSNotification.Name("changeNumberOfDecks"), object: nil)
        countLabel.isHidden = !UserDefaults.standard.bool(forKey: "showCountState")
        dealerHitsOnSoft17 = UserDefaults.standard.bool(forKey: "dealerHitsState")
        game.delegate = self as LastHandDelegate
        configureFonts()
        configureConstants()
        newGame()
    }
    
    override func viewDidLayoutSubviews() {
        configureUIDesign()
        hitCardDistance = dealerCards.last!.frame.minX - dealerCards.first!.frame.minX
    }
    
    private func configureConstants() {
        let screenSize = UIScreen.main.bounds
        cardWidthConstraint.constant = screenSize.width * 0.25
        cardHeightConstraint.constant = screenSize.height * 0.20
        cardSpacingConstraint.constant = -0.20*screenSize.width
    }
    
    private func configureFonts() {
        var titleLabelFont: CGFloat = 26
        var correctPlayLabelFont: CGFloat = 24
        var countLabelFont: CGFloat = 20
        var actionButtonsFont: CGFloat = 18
        let iPhoneHeight = UIScreen.main.bounds.height
        if iPhoneHeight == 667 { //iPhone 7
            titleLabelFont = 22
            correctPlayLabelFont = 20
            countLabelFont = 18
            actionButtonsFont = 16
        } else if iPhoneHeight == 568 { //iPhone SE
            titleLabelFont = 18
            correctPlayLabelFont = 16
            countLabelFont = 14
            actionButtonsFont = 12
        } else if iPhoneHeight == 480 { //iPhone 4s
            titleLabelFont = 13
            correctPlayLabelFont = 12
            countLabelFont = 12
            actionButtonsFont = 10
        }
        
        if iPhoneHeight != 736 {
            dealerTitleLabel.font = UIFont.systemFont(ofSize: titleLabelFont)
            dealerTotalLabel.font = UIFont.systemFont(ofSize: titleLabelFont)
            playerTitleLabel.font = UIFont.systemFont(ofSize: titleLabelFont)
            gamblerTotalLabel.font = UIFont.systemFont(ofSize: titleLabelFont)
            correctPlayLabel.font = UIFont.systemFont(ofSize: correctPlayLabelFont)
            countLabel.font = UIFont.systemFont(ofSize: countLabelFont)
            for button in actionButtons {
                if let title = button.titleLabel {
                    title.font = UIFont.systemFont(ofSize: actionButtonsFont)
                }
            }
            dealButton.titleLabel!.font = UIFont.systemFont(ofSize: actionButtonsFont)
        }
    }
    
    @objc func showOrHideCount() {
        countLabel.isHidden = !countLabel.isHidden
    }
    
    @objc func changeDealerHitsOnSoft17() {
        dealerHitsOnSoft17 = !dealerHitsOnSoft17
    }
    
    @objc func changeNumberOfDecks(_ notification: NSNotification) {
        if let number = notification.userInfo?["number"] as? Int {
            game.changeNumberOfDecks(number: number)
            newGame()
        }
    }
    
    @IBAction func chooseAction(_ action: UIButton) {
        let chosenAction = action.currentTitle!
        let correctAction = game.getCorrectPlay()
        
        if chosenAction == correctAction.rawValue {
            correctActions += 1
            correctPlayLabel.text = "Correct"
        } else {
            incorrectActions += 1
            correctPlayLabel.text = "Incorrect. Correct play is \(correctAction.rawValue)"
        }
        switch chosenAction {
        case game.hit.rawValue:
            gamblerHits()
        case game.stand.rawValue:
            gamblerStands()
        case game.double.rawValue:
            gamblerDoubles()
        case game.split.rawValue:
            gamblerSplits()
        default:
            break
        }
        updateLabelsAfterAction()
    }
    
    private func gamblerHits() {
        changeButtonState(button: actionButtons[2], enabled: false)
        changeButtonState(button: actionButtons[3], enabled: false)
        hitToPlayer()
        if !game.gambler.lastHand && gamblerHas21OrBusts {
            splitHandStandsOrBusts()
        } else if gamblerHas21OrBusts {
            switchPlayToDealer()
        }
    }
    
    private func gamblerStands() {
        if game.gambler.lastHand {
            switchPlayToDealer()
        } else {
            splitHandStandsOrBusts()
        }
    }
    
    private func gamblerDoubles() {
        hitToPlayer()
        if game.gambler.lastHand {
            switchPlayToDealer()
        } else {
            splitHandStandsOrBusts()
        }
    }
    
    private func gamblerSplits() {
        previousHandWasSplit = true
        if game.gambler.currentHand.cards.first!.rank == "ace" && game.gambler.currentHand.cards.last!.rank == "ace" {
            aces = true
        }
        splitCardsOnTable()
        updateGamblerTotalLabelsAfterSplit()
        game.splitHand()
        hitToPlayer()
        moveCircleToCurrentHand()
        if aces || gamblerHas21OrBusts {
            splitHandStandsOrBusts()
        }
    }
    
    private func moveCircleToCurrentHand() {
        if game.gambler.lastHand {
            currentHandCircle.removeFromSuperview()
        }
        currentHandCircle.frame = CGRect(x: previousCard.frame.minX, y: gamblerTotalLabel.center.y - 5, width: 10, height: 10)
        view.addSubview(currentHandCircle)
    }
    
    private func splitHandStandsOrBusts() {
        if !actionButtons[2].isEnabled {
            changeButtonState(button: actionButtons[2], enabled: true)
        }
        gamblerTotalLabel.isHidden = false
        numberOfCardsHitToPlayer = 0
        previousCard = gamblerCards.first!
        game.splitHandStandsOrBusts()
        hitToPlayer()
        moveCircleToCurrentHand()
        if aces || gamblerHas21OrBusts {
            switchPlayToDealer()
        }
    }
    
    private func updateGamblerTotalLabelsAfterSplit() {
        splitHandTotalLabel.frame = CGRect(x: gamblerCards.last!.frame.minX, y: gamblerTotalLabel.frame.minY, width: gamblerTotalLabel.frame.width, height: gamblerTotalLabel.frame.height)
        splitHandTotalLabel.textColor = UIColor.white
        splitHandTotalLabel.font = UIFont.systemFont(ofSize: gamblerTotalLabel.font.pointSize)
        splitHandTotalLabel.textAlignment = .center
        view.addSubview(splitHandTotalLabel)
        gamblerTotalLabel.isHidden = true
    }
    
    private func updateLabelsAfterAction() {
        if game.count > 0 {
            countLabel.text = "Count: +\(game.count)"
        } else {
            countLabel.text = "Count: \(game.count)"
        }
        
        gamblerTotalLabel.text = String(game.gambler.hands.first!.total)
        if game.gambler.alreadySplit {
            splitHandTotalLabel.text = String(game.gambler.hands.last!.total)
        }
    }
    
    private func updateDealerTotalLabel() {
        if game.currentPlayer === game.gambler {
            dealerTotalLabel.text = String(game.dealer.currentHand.cards.first!.integerRank)
        } else {
            dealerTotalLabel.text = String(game.dealer.currentHand.total)
        }
    }
    
    private func updateStatsLabel() {
        if handIsOver {
            let round = game.countHandsWon()
            var winOrLose = String()
            if round > 0 {
                winOrLose = "You win!"
            } else if round == 0 {
                winOrLose = "Push"
            } else {
                winOrLose = "Dealer wins"
            }
            if correctPlayLabel.text!.isEmpty {
                correctPlayLabel.text! = winOrLose
            } else {
                correctPlayLabel.text! += ". \(winOrLose)"
            }
            correctPlayLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func hitToPlayer() {
        let newCardFrame = getCorrectFrameForNewCard()
        game.dealTopCard(to: game.currentPlayer.currentHand, faceUp: true)
        let newCard = game.currentPlayer.currentHand.cards.last!
        putNewCardOnTable(card: newCard, cardFrame: newCardFrame)
    }
    
    private func getCorrectFrameForNewCard() -> CGRect {
        let previousXLocation = previousCard.frame.minX
        let previousYLocation = previousCard.frame.minY
        
        var newCardFrame = CGRect()
        newCardFrame = CGRect(x: previousXLocation + hitCardDistance, y: previousYLocation, width: cardWidthConstraint.constant, height: cardHeightConstraint.constant)
        
        if game.currentPlayer === game.gambler {
            if !game.gambler.lastHand {
                maxCardsToHitBeforeOverlap = 4
            }
            if numberOfCardsHitToPlayer % maxCardsToHitBeforeOverlap == 0 && numberOfCardsHitToPlayer > 0 {
                var cardToOverlap = UIImageView()
                if game.gambler.lastHand {
                    cardToOverlap = gamblerCards.first!
                } else {
                    cardToOverlap = gamblerCards.last!
                }
                newCardFrame = CGRect(x: cardToOverlap.frame.minX, y: previousYLocation, width: cardWidthConstraint.constant, height: cardHeightConstraint.constant)
            }
            numberOfCardsHitToPlayer += 1
        }
        return newCardFrame
    }
    
    private func putNewCardOnTable(card: Card, cardFrame: CGRect) {
        let newCardImage = UIImageView()
        updateCardImage(cardImageView: newCardImage, card: card)
        newCardImage.frame = cardFrame
        newCardImages.append(newCardImage)
        previousCard = newCardImage
        view.addSubview(newCardImage)
    }
    
    private func splitCardsOnTable() {
        gamblerFirstCardLeadingConstraint.constant -= cardWidthConstraint.constant
        gamblerSecondCardTrailingConstraint.constant += cardWidthConstraint.constant/1.5
        view.layoutIfNeeded()
        changeButtonState(button: actionButtons.last!, enabled: false) //player not able to re-split
    }
    
    private func switchPlayToDealer() {
        if game.gambler.alreadySplit {
            currentHandCircle.removeFromSuperview()
        }
        for actionButton in actionButtons {
            changeButtonState(button: actionButton, enabled: false)
        }
        game.currentPlayer = game.dealer
        previousCard = dealerCards.last!
        game.flipDealerCard()
        updateCardImage(cardImageView: dealerCards.last!, card: game.dealer.currentHand.cards.last!)
        if game.dealerNeedsToHit() {
            while game.dealer.currentHand.total <= 17 {
                if game.dealer.currentHand.total == 17 && game.dealer.currentHand.soft && dealerHitsOnSoft17 {
                    hitToPlayer()
                } else if game.dealer.currentHand.total == 17 {
                    break
                } else {
                    hitToPlayer()
                }
            }
        }
        updateDealerTotalLabel()
        endOfGameUpdates()
    }
    
    private func cleanUpTableUI() {
        if !newCardImages.isEmpty {
            for imageView in newCardImages {
                imageView.removeFromSuperview()
            }
        }
        if previousHandWasSplit {
            gamblerFirstCardLeadingConstraint.constant = 0
            gamblerSecondCardTrailingConstraint.constant = 0
            splitHandTotalLabel.removeFromSuperview()
            previousHandWasSplit = false
        }
        newCardImages.removeAll()
        correctPlayLabel.text = ""
        updateStatsLabel()
    }
    
    private func dealNewGameCards() {
        game.dealTopCard(to: game.gambler.currentHand, faceUp: true)
        game.dealTopCard(to: game.dealer.currentHand, faceUp: true)
        game.dealTopCard(to: game.gambler.currentHand, faceUp: true)
        game.dealTopCard(to: game.dealer.currentHand, faceUp: false)
        
        updateCardImage(cardImageView: gamblerCards.first!, card: game.gambler.currentHand.cards.first!)
        updateCardImage(cardImageView: dealerCards.first!, card: game.dealer.currentHand.cards.first!)
        updateCardImage(cardImageView: gamblerCards.last!, card: game.gambler.currentHand.cards.last!)
        dealerCards.last!.image = #imageLiteral(resourceName: "cardback")
    }
    
    private func updateCardImage(cardImageView: UIImageView, card: Card) {
        cardImageView.image = UIImage(named: "\(card.rank)_of_\(card.suit)")
    }
    
    private func changeButtonState(button: UIButton, enabled: Bool) {
        switch enabled {
        case true:
            button.isEnabled = true
            button.alpha = 1
        case false:
            button.isEnabled = false
            button.alpha = 0.5
        }        
    }
    
    private func configureUIDesign() {
        
        setColorsForGradients(topRed: 65/255, topGreen: 67/255, topBlue: 69/255, topAlpha: 1, bottomRed: 35/255, bottomGreen: 37/255, bottomBlue: 39/255, bottomAlpha: 1)
        
        for actionButton in actionButtons {
            actionButton.layer.cornerRadius = 5
            createGradient(button: actionButton, colors: gradientColors, radius: 5)
        }
        
        setColorsForGradients(topRed: 255/255, topGreen: 0, topBlue: 132/255, topAlpha: 1, bottomRed: 51/255, bottomGreen: 0, bottomBlue: 27/255, bottomAlpha: 1)
        
        createGradient(button: dealButton, colors: gradientColors, radius: 5)        
        createGradient(label: dealerTitleLabel, colors: gradientColors, radius: 5)
        createGradient(label: playerTitleLabel, colors: gradientColors, radius: 5)
    }
    
    private func setColorsForGradients(topRed: CGFloat, topGreen: CGFloat, topBlue: CGFloat, topAlpha: CGFloat, bottomRed: CGFloat, bottomGreen: CGFloat, bottomBlue: CGFloat, bottomAlpha: CGFloat) {
        topColorGradient = UIColor(red: topRed, green: topGreen, blue: topBlue, alpha: topAlpha).cgColor
        bottomColorGradient = UIColor(red: bottomRed, green: bottomGreen, blue: bottomBlue, alpha: bottomAlpha).cgColor
    }
    
    func createGradient(button: UIButton, colors: [CGColor], radius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = radius
        button.layer.masksToBounds = true
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createGradient(label: UILabel, colors: [CGColor], radius: CGFloat) {
        
        let gradientView = UIView()
        gradientView.frame = label.frame
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = radius
        
        gradientView.layer.addSublayer(gradientLayer)
        view.insertSubview(gradientView, at: 0)
    }
    
    @IBAction func dealNewGame(_ sender: UIButton) {
        newGame()
    }
    
    func endOfGameUpdates() {
        handIsOver = true
        updateStatsLabel()
        aces = false
        numberOfCardsHitToPlayer = 0
        maxCardsToHitBeforeOverlap = 6
        changeButtonState(button: dealButton, enabled: true)
    }
    
    func newGame() {
        handIsOver = false
        cleanUpTableUI()
        game.newGameUpdates()
        changeButtonState(button: dealButton, enabled: false)
        
        for actionButton in actionButtons {
            changeButtonState(button: actionButton, enabled: true)
        }
        
        dealNewGameCards()
        updateDealerTotalLabel()
        
        if !game.gamblerCanSplit() {
            changeButtonState(button: actionButtons.last!, enabled: false)
        }
        previousCard = gamblerCards.last!
        if game.checkForBlackjack() {
            switchPlayToDealer()
        }
        updateLabelsAfterAction()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.handsPlayed = game.handsPlayed
            settingsVC.handsWon = game.handsGamblerWon
            settingsVC.winPercentage = game.winPercentage
            
            settingsVC.correctActions = correctActions
            settingsVC.incorrectActions = incorrectActions
            settingsVC.percentCorrect = percentCorrect
            
            settingsVC.previousSliderValue = game.getNumberOfDecks()
        }
    }
}


extension BlackjackViewController: LastHandDelegate {
    func didReceiveHandUpdate() {
        correctPlayLabel.text = "Last hand! Shuffling decks next hand."
    }
}
