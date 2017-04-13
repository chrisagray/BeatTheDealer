//
//  BlackjackTrainerModel.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class BlackjackGame
{
    private let deckAndAHalf = 78
    
    private let stay = "Stay"
    private let hit = "Hit"
    private let double = "Double"
    private let split = "Split"
    
    //Change whole game to incorporate new Player class - these might be private
    let gambler = Player()
    let dealer = Player()
    
    private var discardDeck = Deck(withCards: false)
    private var gameDeck = Deck(withCards: true)
    
    var cardsOnTable = [Card]()
    
    var dealerRank = 0
    
    var currentPlayer = "player"
    
    var count = 0
    
    var gamesPlayed = 0
    var gamesWon = 0
    
    init() {
        gameDeck.shuffle()
    }
    
    func newGameUpdates() {
        gambler.total = 0
        dealer.total = 0
        gambler.softHand = false
        dealer.softHand = false
        if !cardsOnTable.isEmpty {
            clearCardsOnTable()
        }
        
        if gameDeck.cards.count <= deckAndAHalf { //reshuffle shoe once you run low
            reshuffleShoe()
        }
    }
    
    func dealTopCard(to player: String, faceUp: Bool) {
        
        let topCard = gameDeck.dealTopCard()
        
        let topCardRank = topCard.rank
        let topCardRankInt = getIntegerRank(rank: topCardRank)
        
        if player == "gambler" {
            gambler.cards.append(topCard)
            updatePlayerTotal(cardRank: topCardRankInt)
            if (gambler.total > 21) {
                print("Player busts")
            }
        } else if player == "dealer" {
            dealer.cards.append(topCard)
            updateDealerTotal(cardRank: topCardRankInt)
            if (dealer.total > 21) {
                print("Dealer busts")
            }
        }
        cardsOnTable.append(topCard)
        if faceUp {
            updateCount(rank: topCardRankInt)
        }
    }
    
    
    //combine these two methods
    func updatePlayerTotal(cardRank: Int) {        
        if cardRank == 11 {
            if gambler.softHand == true {
                gambler.total += 1
            } else {
                if gambler.total + 11 > 21 {
                    gambler.total += 1
                } else {
                    gambler.softHand = true
                    gambler.total += 11
                }
            }
        }
        else if gambler.softHand == true {
            if gambler.total + cardRank > 21 {
                gambler.softHand = false
                gambler.total -= 10
            }
            gambler.total += cardRank
        }
        else {
            gambler.total += cardRank
        }
    }
    
    func updateDealerTotal(cardRank: Int) {
        if cardRank == 11 {
            if dealer.softHand == true {
                dealer.total += 1
            } else {
                if dealer.total + 11 > 21 {
                    dealer.total += 1
                } else {
                    dealer.softHand = true
                    dealer.total += 11
                }
            }
        }
        else if dealer.softHand == true {
            if dealer.total + cardRank > 21 {
                dealer.softHand = false
                dealer.total -= 10
            }
            dealer.total += cardRank
        }
        else {
            dealer.total += cardRank
        }
    }
    
    func reshuffleShoe() {
        print("Shuffling shoe")
        gameDeck.cards.append(contentsOf: discardDeck.cards)
        discardDeck.cards.removeAll()
        gameDeck.shuffle()
        count = 0
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
    
    func clearCardsOnTable() {
        discardDeck.cards.append(contentsOf: cardsOnTable)
        gambler.cards.removeAll()
        dealer.cards.removeAll()
        cardsOnTable.removeAll()
    }
    
    func getCorrectPlay() -> String {
        
        //fix this
        let playerFirstCardRank = getIntegerRank(rank: gambler.cards[0].rank)
        let playerSecondCardRank = getIntegerRank(rank: gambler.cards[1].rank)
        let dealerSecondCardRank = getIntegerRank(rank: dealer.cards[1].rank)
        
        if gambler.cards.count == 2 {
            return correctBasicStrategyPlayForTwoCards(playerFirstRank: playerFirstCardRank, playerSecondRank: playerSecondCardRank, dealerRank: dealerSecondCardRank)
        } else {
            return correctBasicStrategyPlayForThreeOrMoreCards(dealerRank: dealerSecondCardRank)
        }
    }
    
    
    //Aces will be passed in as 11
    private func correctBasicStrategyPlayForThreeOrMoreCards(dealerRank: Int) -> String {
        
        switch gambler.softHand {
        case false:
            switch gambler.total {
            case 6...11:
                return hit
            case 12...15:
                switch dealerRank {
                case 2...6:
                    return stay
                default: //7...11
                    return hit
                }
            case 16:
                switch dealerRank {
                case 2...6:
                    return stay
                case 7...9, 11:
                    return hit
                default: //10
                    return stay
                }
            default: //17...21
                return stay
            }
        case true:
            switch gambler.total {
            case 12...17:
                return hit
            case 18:
                switch dealerRank {
                case 2...8:
                    return stay
                default: //9, 10, 11
                    return hit
                }
            default: //19...21
                return stay
            }
        }
    }
    
    
    //Aces will be passed in as 11
    private func correctBasicStrategyPlayForTwoCards(playerFirstRank: Int, playerSecondRank: Int, dealerRank: Int) -> String {

        if playerFirstRank == playerSecondRank {
            switch playerFirstRank {
            case 10:
                return stay
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
                    return stay
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
                case 2:
                    return stay
                case 3...6:
                    return double
                default:
                    return hit
                }
            default: //8...10
                return stay
            }
        }
        
        else {
            let totalRank = playerFirstRank + playerSecondRank
            switch totalRank {
            case 17...21:
                return stay
            case 13...16:
                switch dealerRank {
                case 2...6:
                    return stay
                default:
                    return hit
                }
            case 12:
                switch dealerRank {
                case 4...6:
                    return stay
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
