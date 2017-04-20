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
    
    private let hit = "Hit"
    private let stand = "Stand"
    private let double = "Double"
    private let split = "Split"
    private let rightCardSplitDistance: CGFloat = 65
    private let leftCardSplitDistance: CGFloat = 110
    private let cardWidth: CGFloat = 100
    private let cardHeight: CGFloat = 150
    private var numberOfEdgeHits = 0
    private var numberOfCardsHitToPlayer = 0
    private var maxCardsToHitBeforeOverlap = 6
    
    private var previousHandWasSplit = false
    private var lastHand = true
    private var handIsOver = false
    
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
    
    @IBAction func showOrHideCount(_ sender: UIButton) {
        if !countLabel.isHidden {
            hideCountButton.setTitle("Show Count", for: .normal)
            countLabel.isHidden = true
        } else {
            hideCountButton.setTitle("Hide Count", for: .normal)
            countLabel.isHidden = false
        }
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
            var aces = false
            if game.gambler.cards.first!.rank == "ace" && game.gambler.cards.last!.rank == "ace" {
                aces = true
            }
            splitCardsOnTable()
            if aces {
                hitToPlayer()
                splitHandStandsOrBusts()
                hitToPlayer()
                switchPlayToDealer()
            } else {
                hitToPlayer()
                if game.gambler.total == 21 { //make this (and all others) game.currentPlayer?
                    splitHandStandsOrBusts()
                }
            }
            
        default:
            break
        }
        updateLabels()
    }
    
    private func splitHandStandsOrBusts() {
        lastHand = true //might want to do splitHand: true/false instead of lastHand
        numberOfCardsHitToPlayer = 0
        previousCardButton = gamblerCardButtons.first!
        game.gambler.cards = [game.gamblerFirstCard]
        game.gambler.total = 0
        game.gambler.softHand = false
        game.updatePlayerTotal(cardRank: game.getIntegerRank(rank: game.gamblerFirstCard.rank), player: game.gambler)
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
        
        if !game.dealer.softHand {
            dealerTotalLabel.text = String(game.dealer.total)
        } else {
            dealerTotalLabel.text = "Soft \(game.dealer.total)"
        }
        
        if handIsOver {
            var winOrLose = String()
            if game.gamblerWins {
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
            if !lastHand {
                maxCardsToHitBeforeOverlap = 4
            }
            if numberOfCardsHitToPlayer % maxCardsToHitBeforeOverlap == 0 && numberOfCardsHitToPlayer > 0 {
                var cardToOverlap = UIButton()
                if lastHand {
                    cardToOverlap = gamblerCardButtons.first!
                } else {
                    cardToOverlap = gamblerCardButtons.last!
                }
                newCardFrame = CGRect(x: cardToOverlap.frame.minX, y: previousYLocation, width: cardWidth, height: cardHeight)
            }
            numberOfCardsHitToPlayer += 1
            print(numberOfCardsHitToPlayer)
        }
        
        game.dealTopCard(to: game.currentPlayer, faceUp: true)
        let newCard = game.cardsOnTable.last!
        updateCardButtonImage(cardButton: newCardButton, card: newCard)
        newCardButtons.append(newCardButton)
        previousCardButton = newCardButton
        
        let newCardView = UIView()
        cardViews.append(newCardView)

        newCardView.addSubview(newCardButton)
        newCardButton.frame = newCardFrame
        self.view.addSubview(newCardView)
    }
    
    private func splitCardsOnTable() {
        let firstCard = gamblerCardButtons.first!
        let secondCard = gamblerCardButtons.last!
        let firstCardXLocation = firstCard.frame.minX
        let secondCardXLocation = secondCard.frame.minX
        
        firstCard.frame = CGRect(x: firstCardXLocation - leftCardSplitDistance, y: firstCard.frame.minY, width: cardWidth, height: cardHeight)
        secondCard.frame = CGRect(x: secondCardXLocation + rightCardSplitDistance, y: secondCard.frame.minY, width: cardWidth, height: cardHeight)
        
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
        game.flipDealerCard()
        updateCardButtonImage(cardButton: dealerCardButtons.first!, card: game.dealer.cards.first!)
        if (game.gambler.total <= 21 && game.dealer.total < 21) {
            while game.dealer.total < 17 {
                hitToPlayer()
            }
        }
        endOfGameUpdates()
    }
    
    private func clearUIElementsOnTable() {
        if !cardViews.isEmpty {
            for cardView in cardViews {
                cardView.removeFromSuperview()
            }
        }
        if previousHandWasSplit {
            gamblerCardButtons.first!.center.x += leftCardSplitDistance
            gamblerCardButtons.last!.center.x -= rightCardSplitDistance
            previousHandWasSplit = false
            lastHand = true
        }
        newCardButtons.removeAll()
    }
    
    private func dealNewGameCards() {
        handIsOver = false
        clearUIElementsOnTable()
        game.currentPlayer = game.gambler
        game.newGameUpdates()
        
        game.dealTopCard(to: game.gambler, faceUp: true)
        game.dealTopCard(to: game.dealer, faceUp: false)
        game.dealTopCard(to: game.gambler, faceUp: true)
        game.dealTopCard(to: game.dealer, faceUp: true)
        
        updateCardButtonImage(cardButton: gamblerCardButtons.first!, card: game.gambler.cards.first!)
        dealerCardButtons.first!.setBackgroundImage(UIImage(named: "cardback"), for: .normal)
        updateCardButtonImage(cardButton: gamblerCardButtons.last!, card: game.gambler.cards.last!)
        updateCardButtonImage(cardButton: dealerCardButtons.last!, card: game.dealer.cards.last!)
        
        if !game.ableToSplit() {
            changeButtonState(button: actionButtons.last!, enabled: false)
        }
        
        previousCardButton = gamblerCardButtons.last!
        let dealerDownCardRank = game.getIntegerRank(rank: game.dealer.cards.first!.rank)
        if game.gambler.total == 21 || game.dealer.total + dealerDownCardRank == 21 {
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
        let actionButtonTop = UIColor(red: 65/255, green: 67/255, blue: 68/255, alpha: 1).cgColor
        let actionButtonBottom = UIColor(red: 35/255, green: 37/255, blue: 39/255, alpha: 1).cgColor
        let actionButtonColors = [actionButtonTop, actionButtonBottom]
        
        for actionButton in actionButtons {
            actionButton.layer.cornerRadius = 5
            createGradient(for: actionButton, with: actionButtonColors)
        }
        let dealButtonTop = UIColor(red: 255/255, green: 0/255, blue: 132/255, alpha: 1).cgColor
        let dealButtonBottom = UIColor(red: 51/255, green: 0/255, blue: 27/255, alpha: 1).cgColor
        let dealButtonColors = [dealButtonTop, dealButtonBottom]
        createGradient(for: dealButton, with: dealButtonColors)
        dealButton.layer.cornerRadius = 5
        
        dealerTitleLabel.layer.cornerRadius = 5
        playerTitleLabel.layer.cornerRadius = 5
    }
    
    func createGradient(for button: UIButton, with colors: [CGColor]) {
        let newGradient = CAGradientLayer()
        newGradient.colors = colors
        newGradient.frame = button.bounds
        button.layer.insertSublayer(newGradient, at: 0)
    }
    
    
    @IBAction func dealNewGame(_ sender: UIButton) {
        newGame()
    }
    
    func endOfGameUpdates() {
        game.countGamesPlayedAndWon()
        handIsOver = true
        numberOfCardsHitToPlayer = 0
        maxCardsToHitBeforeOverlap = 6
        changeButtonState(button: dealButton, enabled: true)
    }
    
    func newGame() {
        for actionButton in actionButtons { //is there a better way to do this?
            changeButtonState(button: actionButton, enabled: true)
        }
        changeButtonState(button: dealButton, enabled: false)
        correctPlayLabel.text = ""
        dealNewGameCards()
        updateLabels()
    }
    
}

