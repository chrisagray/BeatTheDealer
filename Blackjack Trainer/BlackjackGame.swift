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
    private var numberOfDecks = 6 //don't think this should be in BlackjackGame
    
    var gambler = Player()
    var dealer = Player()
    
    private var shoe = Shoe(numberOfDecks: 6) //6 is the default value
    
    var currentPlayer: Player {
        return gamblersTurn ? gambler : dealer
    }
    var gamblersTurn = true
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
    
    var chips = 0
    
    weak var delegate: LastHandDelegate?
    
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
            print("shuffling shoe")
            reshuffleShoe()
        }
        if shoe.cardCount <= shoe.twentyFivePercent { //reshuffle shoe once it runs low
            lastHandBeforeShuffle = true
            print("didReceiveHandUpdate first")
            delegate?.didReceiveHandUpdate()
        }
        gamblersTurn = true
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
                        if hand.blackjack {
                            chips += Int(Double(hand.bet)*1.5)
                        } else {
                            chips += hand.bet
                        }
                    } else if hand.total < dealer.currentHand.total {
                        loseCount += 1
                        chips -= hand.bet
                    }
                case 21:
                    if hand.total != 21 {
                        loseCount += 1
                        chips -= hand.bet
                    } else {
                        if hand.blackjack && !dealer.currentHand.blackjack {
                            winCount += 1
                            chips += Int(Double(hand.bet)*1.5)
                        } else if !hand.blackjack && dealer.currentHand.blackjack {
                            loseCount += 1
                            chips -= hand.bet
                        } else {
                            break
                        }
                    }
                default: // >21
                    winCount += 1
                    if hand.blackjack {
                        chips += Int(Double(hand.bet)*1.5)
                    } else {
                        chips += hand.bet
                    }
                }
            } else {
                loseCount += 1
                chips -= hand.bet
            }
        }
        handsGamblerWon += winCount
        return winCount - loseCount
    }
    
    func dealTopCard(to hand: Hand, faceUp: Bool) {
        if shoe.decks.first!.cards.isEmpty {
            shoe.decks.removeFirst()
        }
        
        let topCard = shoe.decks.first!.draw()!
        let topCardRank = topCard.integerRank
        hand.add(card: topCard)
        
        if faceUp {
            updateCount(rank: topCardRank)
        }
    }
    
    var gamblerCanSplit: Bool {
        return gambler.currentHand.cards.first!.integerRank == gambler.currentHand.cards.last!.integerRank
    }
    
    func checkForBlackjack() -> Bool {
        return gambler.currentHand.blackjack || dealer.currentHand.blackjack
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
            return BasicStrategy.twoCards(firstRank: gamblerFirstCardRank, secondRank: gamblerSecondCardRank, dealerRank: dealerFirstCardRank, soft: gambler.currentHand.soft, alreadySplit: gambler.alreadySplit)
        } else {
            return BasicStrategy.threeOrMoreCards(total: gambler.currentHand.total, soft: gambler.currentHand.soft, dealerRank: dealerFirstCardRank)
        }
    }
}
