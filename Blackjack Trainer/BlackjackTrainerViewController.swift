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
    
    private var newCardButtons = [UIButton]()
    private var cardViews = [UIView]()
    private var previousCardButton = UIButton()
    
    private var dealerTotal: Int {
        get {
            if game.currentPlayer === game.gambler {
                return game.getIntegerRank(rank: game.dealer.cards.last!.rank)
            } else {
                return game.dealer.total
            }
        }
    }
    
    private let hit = "Hit"
    private let stand = "Stand"
    private let double = "Double"
    private let split = "Split"
    
    private var previousHandWasSplit = false
    private var lastHand = true
    
    private let game = BlackjackGame()
    
    @IBOutlet private weak var gamblerTotalLabel: UILabel!
    @IBOutlet weak var dealerTotalLabel: UILabel!
    @IBOutlet var actionButtons: [UIButton]!
    
    override func viewDidLoad() {
        newGame()
    }
    
    override func viewDidLayoutSubviews() {
        configureUIDesign()
    }
    
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
            changeButtonState(button: actionButtons[2], enabled: false)
            changeButtonState(button: actionButtons[3], enabled: false)
            hitToPlayer()
            if game.gambler.splitHand == false {
                if game.gambler.total >= 21 {
                    switchPlayToDealer()
                }
            } else {
                if lastHand && game.gambler.total >= 21 {
                    switchPlayToDealer()
                } else if !lastHand && game.gambler.total >= 21 {
                    splitHandStandsOrBusts()
                }
            }
        case stand:
            if lastHand {
                switchPlayToDealer()
            } else {
                splitHandStandsOrBusts()
            }
        case double:
            hitToPlayer()
            if lastHand {
                switchPlayToDealer()
            } else {
                splitHandStandsOrBusts()
            }
            
        case split:
            previousHandWasSplit = true
            lastHand = false
            splitCardsOnTable()
            hitToPlayer()
            if game.gambler.total == 21 { //make this (and all others) game.currentPlayer?
                splitHandStandsOrBusts()
            }
        default:
            break
        }
        updateLabels()
    }
    
    private func splitHandStandsOrBusts() {
        lastHand = true
        previousCardButton = gamblerCardButtons.first!
//        game.gambler.cards.insert(game.gamblerFirstCard, at: 0)
        game.gambler.cards = [game.gamblerFirstCard]
        game.gambler.total = game.getIntegerRank(rank: game.gamblerFirstCard.rank)
        hitToPlayer()
        if game.gambler.total == 21 {
            switchPlayToDealer()
        }
    }
    
    private func updateLabels() {
        countLabel.text = "Count: \(game.count)"
        if !game.gambler.softHand || game.gambler.total == 21 {
            gamblerTotalLabel.text = String(game.gambler.total)
        } else {
            gamblerTotalLabel.text = "Soft \(game.gambler.total)"
        }
        
        if !game.dealer.softHand || game.currentPlayer === game.gambler {
            dealerTotalLabel.text = String(dealerTotal)
        } else {
            dealerTotalLabel.text = "Soft \(dealerTotal)"
        }
    }
    
    private func hitToPlayer() {
        let newCardButton = UIButton()
        
        let previousXLocation = previousCardButton.frame.minX
        let previousYLocation = previousCardButton.frame.minY
        
        let newCardFrame = CGRect(x: previousXLocation + 20, y: previousYLocation, width: 100, height: 150)
        
        game.dealTopCard(to: game.currentPlayer, faceUp: true)
        let newCard = game.cardsOnTable.last!
        updateCardButtonImage(cardButton: newCardButton, card: newCard)
        newCardButtons.append(newCardButton)
        previousCardButton = newCardButton
        
        let newCardView = UIView()
        cardViews.append(newCardView)

        newCardView.addSubview(newCardButton)
        newCardButton.frame = newCardFrame
        
//        animateCardDeal(cardButton: newCardButton, frame: newCardFrame)
        self.view.addSubview(newCardView)
    }
    
//    private func animateCardDeal(cardButton: UIButton, frame: CGRect) {
//        UIView.animate(withDuration: 0.5, animations: {
//            cardButton.frame = frame
//        })
//    }
    
    private func splitCardsOnTable() {
        let firstCard = gamblerCardButtons.first!
        let secondCard = gamblerCardButtons.last!
        let firstCardXLocation = firstCard.frame.minX
        let secondCardXLocation = secondCard.frame.minX
        
        firstCard.frame = CGRect(x: firstCardXLocation - 85, y: firstCard.frame.minY, width: 100, height: 150)
        secondCard.frame = CGRect(x: secondCardXLocation + 85, y: secondCard.frame.minY, width: 100, height: 150)
        
        changeButtonState(button: actionButtons.last!, enabled: false) //player not able to re-split
        
        game.splitCards()
    }
    
    private func switchPlayToDealer() {
        for actionButton in actionButtons {
            changeButtonState(button: actionButton, enabled: false)
        }
        previousCardButton = dealerCardButtons.last!
        game.currentPlayer = game.dealer
        newCardButtons.removeAll()
        let dealerDownCard = game.dealer.cards.first!
        updateCardButtonImage(cardButton: dealerCardButtons.first!, card: dealerDownCard)
        if (game.gambler.total <= 21 && dealerTotal < 21) {
            while dealerTotal < 17 {
                hitToPlayer()
            }
        }
        game.countGamesPlayedAndWon()
    }
    
//    private func updateLastCardButtonLocation(x: CGFloat, y: CGFloat) {
//        let test = UIButton()
//        test.frame.origin.x += 20
//    }
    
    private func dealNewGameCards() {
        
        if !cardViews.isEmpty {
            for cardView in cardViews {
                cardView.removeFromSuperview()
            }
        }
        
        if previousHandWasSplit {
            gamblerCardButtons.first!.center.x += 85
            gamblerCardButtons.last!.center.x -= 85
            previousHandWasSplit = false
            lastHand = true
        }
        
        
        game.currentPlayer = game.gambler
        
        newCardButtons.removeAll()
        
        game.newGameUpdates()
        
        //fix this too
        game.dealTopCard(to: game.gambler, faceUp: true)
        updateCardButtonImage(cardButton: gamblerCardButtons.first!, card: game.cardsOnTable.last!)
        game.dealTopCard(to: game.dealer, faceUp: false)
        dealerCardButtons.first!.setBackgroundImage(UIImage(named: "cardback"), for: .normal)
        game.dealTopCard(to: game.gambler, faceUp: true)
        updateCardButtonImage(cardButton: gamblerCardButtons.last!, card: game.cardsOnTable.last!)
        game.dealTopCard(to: game.dealer, faceUp: true)
        updateCardButtonImage(cardButton: dealerCardButtons.last!, card: game.cardsOnTable.last!)
        
        if !game.ableToSplit() {
            changeButtonState(button: actionButtons.last!, enabled: false)
        }
        
        previousCardButton = gamblerCardButtons.last!
        if (game.gambler.total == 21 || game.dealer.total == 21) {
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
//        let actionButtonTop = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1).cgColor
//        let actionButtonBottom = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1).cgColor
        let actionButtonTop = UIColor(red: 65/255, green: 67/255, blue: 68/255, alpha: 1).cgColor
        let actionButtonBottom = UIColor(red: 35/255, green: 37/255, blue: 39/255, alpha: 1).cgColor
        let actionButtonColors = [actionButtonTop, actionButtonBottom]
        
        for actionButton in actionButtons {
            actionButton.layer.cornerRadius = 5
            createGradient(for: actionButton, with: actionButtonColors)
        }
//        let dealButtonColors = [UIColor.red.cgColor, UIColor.black.cgColor]
        let dealButtonTop = UIColor(red: 255/255, green: 0/255, blue: 132/255, alpha: 1).cgColor
        let dealButtonBottom = UIColor(red: 51/255, green: 0/255, blue: 27/255, alpha: 1).cgColor
        let dealButtonColors = [dealButtonTop, dealButtonBottom]
        createGradient(for: dealButton, with: dealButtonColors)
        dealButton.layer.cornerRadius = 5
        
        dealerTitleLabel.layer.cornerRadius = 5
        playerTitleLabel.layer.cornerRadius = 5
//        let titleLabelColors = [UIColor.white.cgColor, UIColor.black.cgColor]
//        createGradient(for: dealerTitleLabel, with: titleLabelColors)
        
    }
    
    func createGradient(for button: UIButton, with colors: [CGColor]) { //objects must be UIButton or UILabel
        let newGradient = CAGradientLayer()
        newGradient.colors = colors
        newGradient.frame = button.bounds
        button.layer.insertSublayer(newGradient, at: 0)
    }
    
    
    @IBAction func dealNewGame(_ sender: UIButton) {
        newGame()
    }
    
    func newGame() {
        for actionButton in actionButtons { //is there a better way to do this?
            changeButtonState(button: actionButton, enabled: true)
        }
        
//        configureUIDesign()
        
        correctPlayLabel.text = ""
        dealNewGameCards()
        updateLabels()
    }
    
}

