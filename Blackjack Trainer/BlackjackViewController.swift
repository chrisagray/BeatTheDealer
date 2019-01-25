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
    private var designConfigured = false
    
    private let game = BlackjackGame()
    
    private var gamblerHas21OrBusts: Bool {
        return game.gambler.currentHand.bust || game.gambler.currentHand.total == 21
    }
    
    private var lastCard: UIImageView {
        return game.gamblersTurn ? gamblerCards.last! : dealerCards.last!
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
        NotificationCenter.default.addObserver(self, selector: #selector(changeShowTotals), name: NSNotification.Name("changeShowTotals"), object: nil)
        countLabel.isHidden = !UserDefaults.standard.bool(forKey: "showCountState")
        dealerHitsOnSoft17 = UserDefaults.standard.bool(forKey: "dealerHitsState")
        dealerTotalLabel.isHidden = !UserDefaults.standard.bool(forKey: "showTotalsState")
        gamblerTotalLabel.isHidden = !UserDefaults.standard.bool(forKey: "showTotalsState")
        game.delegate = self as LastHandDelegate
        configureFonts()
        configureConstants()
        newGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !designConfigured {
            UIDesign.configureDesign(actionButtons: actionButtons, titleLabels: [dealerTitleLabel, playerTitleLabel], dealButton: dealButton, view: view)
            designConfigured = true
        }
        hitCardDistance = dealerCards.last!.frame.minX - dealerCards.first!.frame.minX
    }
    
    private func animate(_ cardImageView: UIImageView) {
        
        let xPosition = cardImageView.frame.origin.x
        let yPosition = cardImageView.frame.origin.y
        cardImageView.frame.origin = view.frame.origin
        
        UIView.transition(with: cardImageView, duration: 1, options: [],
                          animations: {
                            cardImageView.frame.origin.x = xPosition
                            cardImageView.frame.origin.y = yPosition
                            cardImageView.transform = CGAffineTransform(rotationAngle: .pi)
        })
//                          completion: { finished in
//                            UIView.transition(with: lastCardImageView, duration: 2, options: [],
//                                              animations: {
//                                                self.gamblerCards.last!.frame.origin.x = lastCardXPosition
//                                                lastCardImageView.frame.origin.y = lastCardYPosition })
//        })
        
    }

    private func configureConstants() {
        let screenSize = UIScreen.main.bounds
        cardWidthConstraint.constant = screenSize.width * 0.25
        cardHeightConstraint.constant = screenSize.height * 0.2
        cardSpacingConstraint.constant = -0.20*screenSize.width
    }
    
    private func configureFonts() {
        var titleLabelFont: CGFloat = 26
        var correctPlayLabelFont: CGFloat = 24
        var countLabelFont: CGFloat = 20
        var actionButtonsFont: CGFloat = 18
        
        let iPhoneHeight = UIScreen.main.bounds.height
        if iPhoneHeight == 667 { //iPhone 8
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
    
    @objc func changeShowTotals() {
        dealerTotalLabel.isHidden = !UserDefaults.standard.bool(forKey: "showTotalsState")
        gamblerTotalLabel.isHidden = !UserDefaults.standard.bool(forKey: "showTotalsState")
        if view.subviews.contains(splitHandTotalLabel) {
            splitHandTotalLabel.isHidden = !UserDefaults.standard.bool(forKey: "showTotalsState")
        }
    }
    
    @objc func changeNumberOfDecks(_ notification: NSNotification) {
        if let number = notification.userInfo?["number"] as? Int {
            game.changeNumberOfDecks(number: number)
            newGame()
        }
    }
    
    @IBAction func chooseAction(_ action: UIButton) {
        let chosenAction = GamblerAction(rawValue: action.currentTitle!)!
        checkIfChosenActionIsCorrect(chosenAction: chosenAction)
        //        CATransaction.begin()
        //        CATransaction.setCompletionBlock({
        //        })
        switch chosenAction {
        case .hit:
            gamblerHits()
            if gamblerHas21OrBusts {
                noMoreActions()
            }
        case .stand:
            noMoreActions()
        case .double:
            game.gambler.currentHand.bet *= 2
            hitToPlayer()
            noMoreActions()
        case .split:
            gamblerSplits()
        }
//        CATransaction.setCompletionBlock({
        updateLabelsAfterAction()
//        })
    }
    
    private func checkIfChosenActionIsCorrect(chosenAction: GamblerAction) {
        let correctAction = game.getCorrectPlay()
        if chosenAction == correctAction {
            correctActions += 1
            correctPlayLabel.text = "Correct"
        } else {
            incorrectActions += 1
            correctPlayLabel.text = "Incorrect. Correct play is \(correctAction.rawValue)"
        }
    }
    
    private func gamblerHits() {
        changeButtonState(button: actionButtons[2], enabled: false)
        changeButtonState(button: actionButtons[3], enabled: false)
        hitToPlayer()

        
    }
    
    private func noMoreActions() {
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
        if aces || game.gambler.currentHand.total == 21 { //don't want to use gamblerHas21OrBusts here
            noMoreActions()
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
        if UserDefaults.standard.bool(forKey: "showTotalsState") {
            gamblerTotalLabel.isHidden = false
        }
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
        if !UserDefaults.standard.bool(forKey: "showTotalsState") {
            splitHandTotalLabel.isHidden = true
        }
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
            print("your chips = \(game.chips)")
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
//        CATransaction.commit()
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
        let newCardImageView = UIImageView()
        newCardImageView.contentMode = .scaleAspectFit
        updateCardImage(cardImageView: newCardImageView, card: card)
        newCardImageView.frame.origin = CGPoint(x: view.frame.width, y: view.frame.origin.y)
        view.addSubview(newCardImageView)
        throwCard(cardImageView: newCardImageView, cardFrame: cardFrame)
        
        
//        newCardImageView.frame = cardFrame
        newCardImages.append(newCardImageView)
        previousCard = newCardImageView
    }
    
    private func throwCard(cardImageView: UIImageView, cardFrame: CGRect) {
        let fullRotation = 2*CGFloat.pi
        UIView.transition(with: cardImageView, duration: 0.25, options: [],
                          animations: {
                            cardImageView.frame = cardFrame
                            UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: .calculationModeLinear, animations: {
                                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                                    cardImageView.transform = CGAffineTransform(rotationAngle: 1/3*fullRotation)
                                })
                                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                                    cardImageView.transform = CGAffineTransform(rotationAngle: 2/3*fullRotation)
                                })
                                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                                    cardImageView.transform = CGAffineTransform(rotationAngle: fullRotation)
                                })
                            })
        })
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
        game.gamblersTurn = false
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
        
        let first = gamblerCards[0].frame
        let second = dealerCards[0].frame
        let third = gamblerCards[1].frame
        let fourth = dealerCards[1].frame
        
        for index in 0...1 {
            gamblerCards[index].frame.origin = view.frame.origin
            dealerCards[index].frame.origin = view.frame.origin
        }
        
        game.dealTopCard(to: game.gambler.currentHand, faceUp: true)
        game.dealTopCard(to: game.dealer.currentHand, faceUp: true)
        game.dealTopCard(to: game.gambler.currentHand, faceUp: true)
        game.dealTopCard(to: game.dealer.currentHand, faceUp: false)
        
        updateCardImage(cardImageView: gamblerCards.first!, card: game.gambler.currentHand.cards.first!)
        updateCardImage(cardImageView: dealerCards.first!, card: game.dealer.currentHand.cards.first!)
        updateCardImage(cardImageView: gamblerCards.last!, card: game.gambler.currentHand.cards.last!)
        dealerCards.last!.image = #imageLiteral(resourceName: "cardback")
        
        throwCard(cardImageView: gamblerCards.first!, cardFrame: first)
        throwCard(cardImageView: dealerCards.first!, cardFrame: second)
        throwCard(cardImageView: gamblerCards.last!, cardFrame: third)
        throwCard(cardImageView: dealerCards.last!, cardFrame: fourth)

        
        
//        gamblerCards.first!.isHidden = true
//        print(gamblerCards.first!.frame)
//        print(gamblerCards.last!.frame)
//        putNewCardOnTable(card: game.gambler.currentHand.cards.first!, cardFrame: gamblerCards.first!.frame)
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
        
        print("count = \(game.count)")
        if game.count > 0 {
            game.gambler.currentHand.bet *= game.count
        }
        print("current bet = \(game.gambler.currentHand.bet)")
        
        dealNewGameCards()
        updateDealerTotalLabel()
        
        if !game.gamblerCanSplit {
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
        print("didReceiveHandUpdate")
        correctPlayLabel.text = "Last hand! Shuffling decks next hand."
    }
}
