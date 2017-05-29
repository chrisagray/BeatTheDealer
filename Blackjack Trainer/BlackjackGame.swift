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
    private var numberOfDecks = 6 { //this should be private, changing it to public so I can print it
        didSet {
            print(numberOfDecks)
        }
    }
    
    let hit = GamblerAction.hit
    let stand = GamblerAction.stand
    let double = GamblerAction.double
    let split = GamblerAction.split
    
    let standAction = GamblerAction.stand
    
    var gambler = Player()
    var dealer = Player()
    
    private var gameDeck = GameDeck(numberOfDecks: 6) //6 is the default value
    
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
    
    weak var delegate: LastHandDelegate?
    
    enum GamblerAction: String {
        case hit = "Hit"
        case stand = "Stand"
        case double = "Double"
        case split = "Split"
    }
    
    func changeNumberOfDecks(number: Int) {
        numberOfDecks = number
        reshuffleShoe()
    }
    
    func getNumberOfDecks() -> Int { //do I need this? Or can I make numberOfDecks public?
        return numberOfDecks
    }
    
    func newGameUpdates() {
        
        gambler = Player()
        dealer = Player()
        
        print(gameDeck.shoe.count)
        
        if lastHandBeforeShuffle {
            reshuffleShoe()
        }
        if gameDeck.shoe.count <= twentyFivePercentOfShoe { //reshuffle shoe once you run low
            lastHandBeforeShuffle = true
            //send delegate notification
            delegate?.didReceiveHandUpdate()
        }
        currentPlayer = gambler
    }
    
    func countHandsWon() -> Int {
        var winCount = 0
        var loseCount = 0
        
        for hand in gambler.hands {
            handsPlayed += 1
            //Fix this to make it simpler
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
        
        if gameDeck.shoe.first == nil { //although this shouldn't happen
            reshuffleShoe()
        }
        
        let topCard = gameDeck.dealTopCard()
        let topCardRank = getIntegerRank(rank: topCard.rank)
        
        hand.cards.append(topCard)
        updateHandTotal(cardRank: topCardRank, hand: hand)
        if faceUp {
            updateCount(rank: topCardRank)
        }
    }
    
    func gamblerCanSplit() -> Bool {
        return getIntegerRank(rank: gambler.currentHand.cards.first!.rank) == getIntegerRank(rank: gambler.currentHand.cards.last!.rank)
    }
    
    func checkForBlackjack() -> Bool {
        if gambler.currentHand.blackjack || dealer.currentHand.blackjack {
            return true
        } else {
            return false
        }
    }
    
    func updateHandTotal(cardRank: Int, hand: Hand) {
        if cardRank == 11 {
            if hand.soft == true {
                hand.total += 1
            } else {
                if hand.total + 11 > 21 {
                    hand.total += 1
                } else {
                    hand.total += 11
                    if hand.total != 21 {
                        hand.soft = true
                    }
                }
            }
        } else if hand.soft == true {
            if hand.total + cardRank > 21 {
                hand.soft = false
                hand.total -= 10
            } else if hand.total + cardRank == 21 {
                hand.soft = false
            }
            hand.total += cardRank
        } else {
            hand.total += cardRank
        }
    }
    
    func splitHand() {
        //not sure if I like calling splitHand in both game and Player
        gambler.splitHand()
        updateHandTotal(cardRank: getIntegerRank(rank: gambler.currentHand.cards.first!.rank), hand: gambler.currentHand)
    }
    
    func splitHandStandsOrBusts() {
        gambler.switchBackToFirstHand()
        updateHandTotal(cardRank: getIntegerRank(rank: gambler.currentHand.cards.first!.rank), hand: gambler.currentHand)
    }
    
    func flipDealerCard() {
        let dealerSecondCardRank = getIntegerRank(rank: dealer.currentHand.cards.last!.rank)
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
        print("Shuffling shoe")
        gameDeck = GameDeck(numberOfDecks: numberOfDecks) //initialize new gameDeck
        count = 0
        lastHandBeforeShuffle = false
    }
    
    func getIntegerRank(rank: String) -> Int {
        
        var rankIntValue: Int
        
        switch rank {
        case "jack", "queen", "king":
            rankIntValue = 10
        case "ace":
            rankIntValue = 11
        default:
            rankIntValue = Int(rank)!
        }
        
        return rankIntValue
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
        
        //fix this
        let dealerFirstCardRank = getIntegerRank(rank: dealer.currentHand.cards.first!.rank)
        
        if gambler.currentHand.cards.count == 2 {
            let gamblerFirstCardRank = getIntegerRank(rank: gambler.currentHand.cards.first!.rank)
            let gamblerSecondCardRank = getIntegerRank(rank: gambler.currentHand.cards.last!.rank)
            return correctBasicStrategyPlayForTwoCards(playerFirstRank: gamblerFirstCardRank, playerSecondRank: gamblerSecondCardRank, dealerRank: dealerFirstCardRank)
        } else {
            return correctBasicStrategyPlayForThreeOrMoreCards(dealerRank: dealerFirstCardRank)
        }
    }
    
    
    //Aces will be passed in as 11
    private func correctBasicStrategyPlayForThreeOrMoreCards(dealerRank: Int) -> GamblerAction {
        
        switch gambler.currentHand.soft {
        case false:
            switch gambler.currentHand.total {
            case 6...11:
                return hit
            case 12...15:
                switch dealerRank {
                case 2...6:
                    return stand
                default: //7...11
                    return hit
                }
            case 16:
                switch dealerRank {
                case 2...6:
                    return stand
                case 7...9, 11:
                    return hit
                default: //10
                    return stand
                }
            default: //17...21
                return stand
            }
        case true:
            switch gambler.currentHand.total {
            case 12...17:
                return hit
            case 18:
                switch dealerRank {
                case 2...8:
                    return stand
                default: //9, 10, 11
                    return hit
                }
            default: //19...21
                return stand
            }
        }
    }
    
    
    //Aces will be passed in as 11
    private func correctBasicStrategyPlayForTwoCards(playerFirstRank: Int, playerSecondRank: Int, dealerRank: Int) -> GamblerAction {

        if playerFirstRank == playerSecondRank && !gambler.alreadySplit {
            switch playerFirstRank {
            case 10:
                return stand
            case 2, 3, 7:
                switch dealerRank {
                case 2...7:
                    return split
                default:
                    return hit
                }
            case 4:
                switch dealerRank {
                case 5, 6:
                    return split
                default:
                    return hit
                }
            case 5:
                switch dealerRank {
                case 10, 11:
                    return hit
                default:
                    return double
                }
            case 6:
                switch dealerRank {
                case 2...6:
                    return split
                default:
                    return hit
                }
            case 9:
                switch dealerRank {
                case 7, 10, 11:
                    return stand
                default:
                    return split
                }
            default: //8, 11
                return split
            }
        }
        
        else if (playerFirstRank == 11 || playerSecondRank == 11) {
            let cardRank = playerFirstRank == 11 ? playerSecondRank : playerFirstRank
            
            switch cardRank {
            case 2, 3:
                switch dealerRank {
                case 5, 6:
                    return double
                default:
                    return hit
                }
            case 4, 5:
                switch dealerRank {
                case 4...6:
                    return double
                default:
                    return hit
                }
            case 6:
                switch dealerRank {
                case 3...6:
                    return double
                default:
                    return hit
                }
            case 7:
                switch dealerRank {
                case 2, 7, 8:
                    return stand
                case 3...6:
                    return double
                default: //9...A
                    return hit
                }
            default: //8...10
                return stand
            }
        }
        
        else {
            let totalRank = playerFirstRank + playerSecondRank
            switch totalRank {
            case 17...21:
                return stand
            case 13...16:
                switch dealerRank {
                case 2...6:
                    return stand
                default:
                    return hit
                }
            case 12:
                switch dealerRank {
                case 4...6:
                    return stand
                default:
                    return hit
                }
            case 11:
                return double
            case 10:
                switch dealerRank {
                case 10, 11:
                    return hit
                default:
                    return double
                }
            case 9:
                switch dealerRank {
                case 3...6:
                    return double
                default:
                    return hit
                }
            default: //5...8
                return hit
            }
        }
    }
}
