//
//  ViewController.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import UIKit

//Core Animation
//SpriteKit

class BlackjackTrainerViewController: UIViewController {
    
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private var dealerCardButtons: [UIButton]!
    @IBOutlet private var playerCardButtons: [UIButton]!
    
    private var newCardButtons = [UIButton]()
    private var newCardView = UIView()
    
    private var dealerTotal: Int {
        get {
            if game.currentPlayer == "gambler" {
                return game.getIntegerRank(rank: game.dealer.cards.last!.rank)
            } else {
                return game.dealer.total
            }
        }
    }
    
    private var newGame = Bool()
    private let game = BlackjackGame()
    
    @IBOutlet private weak var playerTotalLabel: UILabel!
    @IBOutlet weak var dealerTotalLabel: UILabel!
    
    
    @IBOutlet var actionButtons: [UIButton]!
    
    @IBAction func chooseAction(_ action: UIButton) {
        let chosenAction = action.currentTitle!
        let correctAction = game.getCorrectPlay()
        
        if chosenAction == correctAction {
            print("Correct")
        } else {
            print("Incorrect, correct play is \(correctAction)")
        }
        switch chosenAction {
        case "Hit":
            actionButtons[2].isEnabled = false
            actionButtons[3].isEnabled = false
            hit()
            if game.gambler.total >= 21 {
                switchPlayToDealer()
            }
        case "Stay":
            switchPlayToDealer()
        case "Double":
            hit()
            switchPlayToDealer()
        case "Split":
            break
        default:
            break
        }
        
        updateLabels()
    }
    
    private func updateLabels() {
        countLabel.text = "Count: \(game.count)"
        playerTotalLabel.text = String(game.gambler.total)
        dealerTotalLabel.text = String(dealerTotal)
    }
    
    private func hit() {
        let newCardButton = UIButton()
        var previousCardButton = UIButton()
        
        if newCardButtons.isEmpty {
            if game.currentPlayer == "gambler" {
                previousCardButton = playerCardButtons.last!
            } else {
                previousCardButton = dealerCardButtons.last!
            }
        } else {
            previousCardButton = newCardButtons.last!
        }
        
        let prevCardButtonCenterX = previousCardButton.frame.minX
        let prevCardButtonCenterY = previousCardButton.frame.minY
        newCardButton.frame = CGRect(x: prevCardButtonCenterX + 20, y: prevCardButtonCenterY, width: 100, height: 150)
        
        game.dealTopCard(to: game.currentPlayer, faceUp: true)
        let newCard = game.cardsOnTable.last!
        updateCardButtonImage(cardButton: newCardButton, card: newCard)
        newCardButtons.append(newCardButton)
        
        newCardView.addSubview(newCardButton)
//        animateCardDeal(cardButton: newCardButton, x: prevCardButtonCenterX, y: prevCardButtonCenterY)
        self.view.addSubview(newCardView)
    }
    
//    private func animateCardDeal(cardButton: UIButton, x: CGFloat, y: CGFloat) {
//        
//        if game.currentPlayer == "dealer" {
//            UIView.animate(withDuration: 0.5,
//                       animations: {cardButton.frame = CGRect(x: x + 20, y: y, width: 100, height: 150)},
//                       completion: {(finished: Bool) in
//                        if self.dealerTotal < 17 {
//                            self.hit()
//                        }
//        })
//        } else {
//            UIView.animate(withDuration: 0.5,
//                           animations: {cardButton.frame = CGRect(x: x + 20, y: y, width: 100, height: 150)})
//        }
//    }
    
    private func switchPlayToDealer() {
        
        for actionButton in actionButtons {
            actionButton.isEnabled = false
        }
        
        game.currentPlayer = "dealer"
        newCardButtons.removeAll()
        let dealerDownCard = game.dealer.cards.first!
        updateCardButtonImage(cardButton: dealerCardButtons.first!, card: dealerDownCard)
        if (game.gambler.total <= 21 && dealerTotal < 21) {
            while dealerTotal < 17 {
                hit()
            }
        }
        
        countGamesPlayedAndWon()
        
    }
    
    private func countGamesPlayedAndWon() { //fix this to add if you get blackjack and dealer doesn't have blackjack, you win
        game.gamesPlayed += 1
        if game.gambler.total <= 21 {
            switch dealerTotal {
            case 17...21:
                if game.gambler.total > dealerTotal {
                    game.gamesWon += 1
                }
            default: // >21
                game.gamesWon += 1
            }
        }
        
        print("Games played: \(game.gamesPlayed)")
        print("Games won: \(game.gamesWon)")
    }
    
    
    
    private func dealNewGameCards() {
        
        if !newCardView.subviews.isEmpty {
            for view in newCardView.subviews {
                view.removeFromSuperview()
            }
        }
        
        game.currentPlayer = "gambler"
        
        newCardButtons.removeAll()
        
        game.newGameUpdates()
        
        //fix this too
        game.dealTopCard(to: "gambler", faceUp: true)
        updateCardButtonImage(cardButton: playerCardButtons.first!, card: game.cardsOnTable.last!)
        game.dealTopCard(to: "dealer", faceUp: false)
        dealerCardButtons.first!.setBackgroundImage(UIImage(named: "cardback"), for: .normal)
        game.dealTopCard(to: "gambler", faceUp: true)
        updateCardButtonImage(cardButton: playerCardButtons.last!, card: game.cardsOnTable.last!)
        game.dealTopCard(to: "dealer", faceUp: true)
        updateCardButtonImage(cardButton: dealerCardButtons.last!, card: game.cardsOnTable.last!)
        
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
    
    
    @IBAction func dealNewGame(_ sender: UIButton) {
        
        newGame = true
        for actionButton in actionButtons { //is there a better way to do this?
            actionButton.isEnabled = true
        }
        dealNewGameCards()
        updateLabels()
    }
    
}

