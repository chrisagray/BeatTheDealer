//
//  BlackjackTrainerModel.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

protocol LastHandDelegate: class {
    func didReceiveHandUpdate()
}

class BlackjackGame
{
    private var twentyFivePercentOfShoe: Int {
        if numberOfDecks > 1 {
            return Int(Double(numberOfDecks) * 52 * 0.25)
        } else {
            return 25 //arbitrary number, but reshuffling shoe below if this gets to 0
        }
    }
    private var numberOfDecks = 6
    
    let hit = GamblerAction.hit
    let stand = GamblerAction.stand
    let double = GamblerAction.double
    let split = GamblerAction.split
    
    let standAction = GamblerAction.stand
    
    var gambler = Player()
    var dealer = Player()
    
    private var shoe = Shoe(numberOfDecks: 6) //6 is the default value
    
    var currentPlayer = Player()
    var count = 0
    var handsPlayed = 0
    var handsGamblerWon = 0
    var lastHandBeforeShuffle = false
    
    var winPercentage: Int {
        if handsPlayed == 0 {
            return 0
        } else {
            return Int((Double(handsGamblerWon)/Double(handsPlayed))*100)
        }
    }
    
    private var basicStrategy = BasicStrategy()
    
    weak var delegate: LastHandDelegate?
    
//    enum GamblerAction: String {
//        case hit = "Hit"
//        case stand = "Stand"
//        case double = "Double"
//        case split = "Split"
//    }
    
    func changeNumberOfDecks(number: Int) {
        numberOfDecks = number
        reshuffleShoe()
    }
    
    func getNumberOfDecks() -> Int {
        return numberOfDecks
    }
    
    func newGameUpdates() {
        gambler = Player()
        dealer = Player()
        if lastHandBeforeShuffle {
            reshuffleShoe()
        }
        if shoe.cards.count <= twentyFivePercentOfShoe { //reshuffle shoe once it runs low
            lastHandBeforeShuffle = true
            delegate?.didReceiveHandUpdate()
        }
        currentPlayer = gambler
    }
    
    func countHandsWon() -> Int {
        var winCount = 0
        var loseCount = 0
        
        for hand in gambler.hands {
            handsPlayed += 1
            if hand.total <= 21 {
                switch dealer.currentHand.total {
                case 17...20:
                    if hand.total > dealer.currentHand.total {
                        winCount += 1
                    } else if hand.total < dealer.currentHand.total {
                        loseCount += 1
                    }
                case 21:
                    if hand.total != 21 {
                        loseCount += 1
                    } else {
                        if hand.blackjack && !dealer.currentHand.blackjack {
                            winCount += 1
                        } else if !hand.blackjack && dealer.currentHand.blackjack {
                            loseCount += 1
                        } else {
                            break
                        }
                    }
                default: // >21
                    winCount += 1
                }
            } else {
                loseCount += 1
            }
        }
        handsGamblerWon += winCount
        return winCount - loseCount
    }
    
    func dealTopCard(to hand: Hand, faceUp: Bool) {
        if shoe.cards.first == nil { //although this shouldn't happen
            reshuffleShoe()
        }
        
        let topCard = shoe.dealTopCard()
        let topCardRank = topCard.integerRank
        
        hand.cards.append(topCard)
        hand.updateTotal(cardRank: topCardRank)
        if faceUp {
            updateCount(rank: topCardRank)
        }
    }
    
    func gamblerCanSplit() -> Bool {
        return gambler.currentHand.cards.first!.integerRank == gambler.currentHand.cards.last!.integerRank
    }
    
    func checkForBlackjack() -> Bool {
        if gambler.currentHand.blackjack || dealer.currentHand.blackjack {
            return true
        } else {
            return false
        }
    }
    
    func splitHand() {
        gambler.splitHand()
        gambler.currentHand.updateTotal(cardRank: gambler.currentHand.cards.first!.integerRank)
    }
    
    func splitHandStandsOrBusts() {
        gambler.switchBackToFirstHand()
        gambler.currentHand.updateTotal(cardRank: gambler.currentHand.cards.first!.integerRank)
    }
    
    func flipDealerCard() {
        let dealerSecondCardRank = dealer.currentHand.cards.last!.integerRank
        updateCount(rank: dealerSecondCardRank)
    }
    
    func dealerNeedsToHit() -> Bool {
        for hand in gambler.hands {
            if hand.total <= 21 && !hand.blackjack {
                return true
            }
        }
        return false
    }
    
    func reshuffleShoe() {
        shoe = Shoe(numberOfDecks: numberOfDecks) //initialize new shoe
        count = 0
        lastHandBeforeShuffle = false
    }
    
    func updateCount(rank: Int) {
        switch rank {
        case 10, 11:
            count -= 1
        case 2...6:
            count += 1
        default: break
        }
    }
    
    func getCorrectPlay() -> GamblerAction {
        //TODO: make this clearer
        let dealerFirstCardRank = dealer.currentHand.cards.first!.integerRank
        if gambler.currentHand.cards.count == 2 {
            let gamblerFirstCardRank = gambler.currentHand.cards.first!.integerRank
            let gamblerSecondCardRank = gambler.currentHand.cards.last!.integerRank
            return basicStrategy.twoCards(firstRank: gamblerFirstCardRank, secondRank: gamblerSecondCardRank, dealerRank: dealerFirstCardRank, soft: gambler.currentHand.soft, alreadySplit: gambler.alreadySplit)
        } else {
            return basicStrategy.threeOrMoreCards(total: gambler.currentHand.total, soft: gambler.currentHand.soft, dealerRank: dealerFirstCardRank)
        }
    }
}
