//
//  ViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

class BlackjackTrainerViewController: UIViewController {
    
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private var dealerCardButtons: [UIButton]!
    @IBOutlet private var gamblerCardButtons: [UIButton]!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var correctPlayLabel: UILabel!
    @IBOutlet weak var dealerTitleLabel: UILabel!
    @IBOutlet weak var playerTitleLabel: UILabel!
    @IBOutlet weak var hideCountButton: UIButton!
    @IBOutlet weak var matchStatsLabel: UILabel!
    
    private var newCardButtons = [UIButton]()
    private var cardViews = [UIView]()
    private var previousCardButton = UIButton()
    private var topColorGradient = UIColor.clear.cgColor
    private var bottomColorGradient = UIColor.clear.cgColor
    
    private var gradientColors: [CGColor] {
        get {
            return [topColorGradient, bottomColorGradient]
        }
    }
    
    private let hit = "Hit"
    private let stand = "Stand"
    private let double = "Double"
    private let split = "Split"
    private let rightCardSplitDistance: CGFloat = 65
    private let leftCardSplitDistance: CGFloat = 110
    private let labelSplitRightDistance: CGFloat = 85
    private let labelSplitLeftDistance: CGFloat = 110
    private let cardWidth: CGFloat = 100
    private let cardHeight: CGFloat = 150
    private let twentyOne = 21
    private var numberOfEdgeHits = 0
    private var numberOfCardsHitToPlayer = 0
    private var maxCardsToHitBeforeOverlap = 6
    private var previousHandWasSplit = false
    private var handIsOver = false
    private var aces = false
    
    private let game = BlackjackGame()
    
    private var gamblerTotal: Int { //might get rid of this
        get {
            if !game.lastHand {
                return game.gambler.splitHandTotal
            } else {
                return game.gambler.total
            }
        }
    }
    
    private var gamblerHas21OrBusts: Bool {
        get {
            return gamblerTotal >= 21
        }
    }
    
    @IBOutlet private weak var gamblerTotalLabel: UILabel!
    @IBOutlet weak var dealerTotalLabel: UILabel!
    @IBOutlet var actionButtons: [UIButton]!
    private var splitHandTotalLabel = UILabel()
    
    override func viewDidLoad() {
        newGame()
    }
    
    override func viewDidLayoutSubviews() {
        configureUIDesign()
    }
    
    @IBAction func showOrHideCount(_ sender: UIButton) {
        if !countLabel.isHidden {
            hideCountButton.setTitle("Show Count", for: .normal)
            countLabel.isHidden = true
        } else {
            hideCountButton.setTitle("Hide Count", for: .normal)
            countLabel.isHidden = false
        }
    }
    
//    private enum GamblerAction {
//        case hit, stand, double, split
//    }
    
    
    @IBAction func chooseAction(_ action: UIButton) {
        let chosenAction = action.currentTitle!
        let correctAction = game.getCorrectPlay()
        
        if chosenAction == correctAction {
            correctPlayLabel.text = "Correct"
        } else {
            correctPlayLabel.text = "Incorrect, correct play is \(correctAction)"
        }
        switch chosenAction {
        case hit:
            gamblerHits()
        case stand:
            gamblerStands()
        case double:
            gamblerDoubles()
        case split:
            gamblerSplits()
        default:
            break
        }
        updateLabels()
    }
    
    private func gamblerHits() {
        changeButtonState(button: actionButtons[2], enabled: false)
        changeButtonState(button: actionButtons[3], enabled: false)
        hitToPlayer()
        if !game.lastHand && gamblerHas21OrBusts {
            splitHandStandsOrBusts()
        } else if gamblerHas21OrBusts {
            switchPlayToDealer()
        }
    }
    
    private func gamblerStands() {
        if game.lastHand {
            switchPlayToDealer()
        } else {
            splitHandStandsOrBusts()
        }
    }
    
    private func gamblerDoubles() {
        hitToPlayer()
        if game.lastHand {
            switchPlayToDealer()
        } else {
            splitHandStandsOrBusts()
        }
    }
    
    private func gamblerSplits() {
        previousHandWasSplit = true
        if game.gambler.cards.first!.rank == "ace" && game.gambler.cards.last!.rank == "ace" {
            aces = true
        }
        splitCardsOnTable()
        addSplitHandTotalLabelToView()
        gamblerTotalLabel.center.x -= labelSplitLeftDistance
        gamblerTotalLabel.isHidden = true
        game.splitCards()
        hitToPlayer()
        if aces || gamblerHas21OrBusts {
            splitHandStandsOrBusts()
        }
    }
    
    private func splitHandStandsOrBusts() {
        if !actionButtons[2].isEnabled {
            changeButtonState(button: actionButtons[2], enabled: true)
        }
        gamblerTotalLabel.isHidden = false
        numberOfCardsHitToPlayer = 0
        previousCardButton = gamblerCardButtons.first!
        game.splitHandStandsOrBusts()
        hitToPlayer()
        actionButtons[2].isEnabled = true
        if gamblerTotal == twentyOne || aces {
            switchPlayToDealer()
        }
    }
    
    private func addSplitHandTotalLabelToView() {
        splitHandTotalLabel.frame = gamblerTotalLabel.frame
        splitHandTotalLabel.center.x += labelSplitRightDistance
        splitHandTotalLabel.textColor = UIColor.white
        splitHandTotalLabel.font = UIFont(name: splitHandTotalLabel.font.fontName, size: 26)
        splitHandTotalLabel.textAlignment = .center
        self.view.addSubview(splitHandTotalLabel)
    }
    
    private func updateLabels() {
        if game.count > 0 {
            countLabel.text = "Count: +\(game.count)"
        } else {
            countLabel.text = "Count: \(game.count)"
        }
        
        if !game.gambler.softHand {
            //I don't like how I'm not using gamblerTotal here, but I think it makes sense not to
            gamblerTotalLabel.text = String(game.gambler.total)
            splitHandTotalLabel.text = String(game.gambler.splitHandTotal)
        } else {
            gamblerTotalLabel.text = "Soft \(game.gambler.total)"
            splitHandTotalLabel.text = "Soft \(game.gambler.splitHandTotal)"
        }
        if game.currentPlayer === game.dealer {
            dealerTotalLabel.text = String(game.dealer.total)
        }
        
        if handIsOver {
            var winOrLose = String()
            if game.gambler.winsHand {
                winOrLose = "You win!"
            } else if game.push {
                winOrLose = "Push."
            } else {
                winOrLose = "Dealer wins."
            }
            matchStatsLabel.text = "\(winOrLose)    Games played: \(game.gamesPlayed)   Games won: \(game.gamesWon)"
        } else {
            matchStatsLabel.text = "Games played: \(game.gamesPlayed)   Games won: \(game.gamesWon)"
        }
    }
    
    private func hitToPlayer() {
        let newCardButton = UIButton()
        
        let previousXLocation = previousCardButton.frame.minX
        let previousYLocation = previousCardButton.frame.minY
        
        var newCardFrame = CGRect()
        newCardFrame = CGRect(x: previousXLocation + 20, y: previousYLocation, width: cardWidth, height: cardHeight)
        
        if game.currentPlayer === game.gambler {
            if !game.lastHand {
                maxCardsToHitBeforeOverlap = 4
            }
            if numberOfCardsHitToPlayer % maxCardsToHitBeforeOverlap == 0 && numberOfCardsHitToPlayer > 0 {
                var cardToOverlap = UIButton()
                if game.lastHand {
                    cardToOverlap = gamblerCardButtons.first!
                } else {
                    cardToOverlap = gamblerCardButtons.last!
                }
                newCardFrame = CGRect(x: cardToOverlap.frame.minX, y: previousYLocation, width: cardWidth, height: cardHeight)
            }
            numberOfCardsHitToPlayer += 1
        }
        
        game.dealTopCard(to: game.currentPlayer, faceUp: true)
        let newCard = game.cardsOnTable.last!
        putNewCardOnTable(card: newCard, cardButton: newCardButton, cardFrame: newCardFrame)
    }
    
    private func putNewCardOnTable(card: Card, cardButton: UIButton, cardFrame: CGRect) {
        updateCardButtonImage(cardButton: cardButton, card: card)
        newCardButtons.append(cardButton)
        previousCardButton = cardButton
        
        let newCardView = UIView()
        cardViews.append(newCardView)
        
        newCardView.addSubview(cardButton)
        cardButton.frame = cardFrame
        self.view.addSubview(newCardView)
    }
    
    private func splitCardsOnTable() {
        let firstCardButton = gamblerCardButtons.first!
        let secondCardButton = gamblerCardButtons.last!
        let firstCardXLocation = firstCardButton.frame.minX
        let secondCardXLocation = secondCardButton.frame.minX
        
        firstCardButton.frame = CGRect(x: firstCardXLocation - leftCardSplitDistance, y: firstCardButton.frame.minY, width: cardWidth, height: cardHeight)
        secondCardButton.frame = CGRect(x: secondCardXLocation + rightCardSplitDistance, y: secondCardButton.frame.minY, width: cardWidth, height: cardHeight)
        
        changeButtonState(button: actionButtons.last!, enabled: false) //player not able to re-split
    }
    
    private func switchPlayToDealer() {
        for actionButton in actionButtons {
            changeButtonState(button: actionButton, enabled: false)
        }
        previousCardButton = dealerCardButtons.last!
        game.currentPlayer = game.dealer
        newCardButtons.removeAll()
        game.flipDealerCard()
        updateCardButtonImage(cardButton: dealerCardButtons.last!, card: game.dealer.cards.last!)
        if gamblerTotal <= 21 || (game.gambler.splitHand && game.gambler.splitHandTotal <= 21) {
            while game.dealer.total < 17 {
                hitToPlayer()
            }
        }
        endOfGameUpdates()
    }
    
    private func cleanUpTableUI() {
        if !cardViews.isEmpty {
            for cardView in cardViews {
                cardView.removeFromSuperview()
            }
        }
        if previousHandWasSplit {
            gamblerCardButtons.first!.center.x += leftCardSplitDistance
            gamblerCardButtons.last!.center.x -= rightCardSplitDistance
            gamblerTotalLabel.center.x += labelSplitLeftDistance
            splitHandTotalLabel.removeFromSuperview()
            previousHandWasSplit = false
        }
        newCardButtons.removeAll()
        correctPlayLabel.text = ""
        dealerTotalLabel.text = ""
    }
    
    private func dealNewGameCards() {
        game.dealTopCard(to: game.gambler, faceUp: true)
        game.dealTopCard(to: game.dealer, faceUp: true)
        game.dealTopCard(to: game.gambler, faceUp: true)
        game.dealTopCard(to: game.dealer, faceUp: false)
        
        updateCardButtonImage(cardButton: gamblerCardButtons.first!, card: game.gambler.cards.first!)
        updateCardButtonImage(cardButton: dealerCardButtons.first!, card: game.dealer.cards.first!)
        updateCardButtonImage(cardButton: gamblerCardButtons.last!, card: game.gambler.cards.last!)
        dealerCardButtons.last!.setBackgroundImage(UIImage(named: "cardback"), for: .normal)
    }
    
    private func checkForBlackjack() {
        let dealerDownCardRank = game.getIntegerRank(rank: game.dealer.cards.last!.rank)
        if gamblerTotal == twentyOne || game.dealer.total + dealerDownCardRank == twentyOne {
            print("BLACKJACK")
            switchPlayToDealer()
        }
    }
    
    private func updateCardButtonImage(cardButton: UIButton, card: Card) {
        let cardName = "\(card.rank)_of_\(card.suit)"
        let cardImage = UIImage(named: cardName)
        cardButton.setBackgroundImage(cardImage, for: .normal)
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
        setColorsForGradients(topRed: 65/255, topGreen: 67/255, topBlue: 68/255, topAlpha: 1, bottomRed: 35/255, bottomGreen: 37/255, bottomBlue: 39/255, bottomAlpha: 1)
        
        for actionButton in actionButtons {
            actionButton.layer.cornerRadius = 5
            createGradient(button: actionButton, colors: gradientColors, radius: 5)
        }
        setColorsForGradients(topRed: 255/255, topGreen: 0, topBlue: 132/255, topAlpha: 1, bottomRed: 51/255, bottomGreen: 0, bottomBlue: 27/255, bottomAlpha: 1)
        createGradient(button: dealButton, colors: gradientColors, radius: 5)
        
//        setColorsForGradients(topRed: 255/255, topGreen: 237/255, topBlue: 188/255, topAlpha: 1, bottomRed: 237/255, bottomGreen: 66/255, bottomBlue: 100/255, bottomAlpha: 1)
        
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
        self.view.insertSubview(gradientView, at: 0)
    }
    
    
    @IBAction func dealNewGame(_ sender: UIButton) {
        newGame()
    }
    
    func endOfGameUpdates() {
        game.countGamesPlayedAndWon()
        handIsOver = true
        aces = false
        numberOfCardsHitToPlayer = 0
        maxCardsToHitBeforeOverlap = 6
        changeButtonState(button: dealButton, enabled: true)
    }
    
    func newGame() {
        handIsOver = false
        cleanUpTableUI()
        game.newGameUpdates()
//        changeButtonState(button: dealButton, enabled: false)
        
        for actionButton in actionButtons { //is there a better way to do this?
            changeButtonState(button: actionButton, enabled: true)
        }
        
        dealNewGameCards()
        if !game.gamblerCanSplit() {
            changeButtonState(button: actionButtons.last!, enabled: false)
        }
        previousCardButton = gamblerCardButtons.last!
        checkForBlackjack()
        updateLabels()
    }
    
}

