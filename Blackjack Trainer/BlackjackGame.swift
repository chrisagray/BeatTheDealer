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
    
    private let stand = "Stand"
    private let hit = "Hit"
    private let double = "Double"
    private let split = "Split"
    
    let gambler = Player()
    let dealer = Player()
    
    var gamblerFirstCard = Card()
    
    private var discardDeck = Deck(withCards: false)
    private var gameDeck = Deck(withCards: true)
    
    var cardsOnTable = [Card]()
    var dealerRank = 0 //change this to be dealer total I think
    var currentPlayer = Player()
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
        gambler.splitHand = false
        if !cardsOnTable.isEmpty {
            clearCardsOnTable()
        }
        
        if gameDeck.cards.count <= deckAndAHalf { //reshuffle shoe once you run low
            reshuffleShoe()
        }
        currentPlayer = gambler
    }
    
    func countGamesPlayedAndWon() {
        gamesPlayed += 1
        if gambler.total <= 21 {
            switch dealer.total {
            case 17...21:
                if gambler.total > dealer.total {
                    gamesWon += 1
                } else if gambler.total == 21 && dealer.total == 21 { //if you get blackjack and dealer doesn't have blackjack, you win
                    if gambler.cards.count == 2 && dealer.cards.count > 2 {
                        gamesWon += 1
                    }
                }
            default: // >21
                gamesWon += 1
            }
        }
        
        print("Games played: \(gamesPlayed)")
        print("Games won: \(gamesWon)")
    }
    
    func dealTopCard(to player: Player, faceUp: Bool) {
        
        let topCard = gameDeck.dealTopCard()
        let topCardRank = topCard.rank
        let topCardRankInt = getIntegerRank(rank: topCardRank)
        
        player.cards.append(topCard)
        updatePlayerTotal(cardRank: topCardRankInt, player: player)
        if (player.total > 21) {
            print("BUST")
        }
        cardsOnTable.append(topCard)
        if faceUp {
            updateCount(rank: topCardRankInt)
        }
    }
    
    func ableToSplit() -> Bool {
        return getIntegerRank(rank: gambler.cards.first!.rank) == getIntegerRank(rank: gambler.cards.last!.rank)
    }
    
    func updatePlayerTotal(cardRank: Int, player: Player) {
        if cardRank == 11 {
            if player.softHand == true {
                player.total += 1
            } else {
                if player.total + 11 > 21 {
                    player.total += 1
                } else {
                    player.total += 11
                    if player.total != 21 {
                        player.softHand = true
                    }
                }
            }
        } else if player.softHand == true {
            if player.total + cardRank > 21 {
                player.softHand = false
                player.total -= 10
            } else if player.total + cardRank == 21 {
                player.softHand = false
            }
            player.total += cardRank
        } else {
            player.total += cardRank
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
    
    func splitCards() {
        gambler.splitHand = true
        gambler.total = 0
        gamblerFirstCard = gambler.cards.first!
        gambler.cards.removeFirst() //first card is now the second card that was split
        updatePlayerTotal(cardRank: getIntegerRank(rank: gambler.cards.last!.rank), player: gambler)
    }
    
    func getCorrectPlay() -> String {
        
        //fix this
        let gamblerFirstCardRank = getIntegerRank(rank: gambler.cards[0].rank)
        let gamblerSecondCardRank = getIntegerRank(rank: gambler.cards[1].rank)
        let dealerSecondCardRank = getIntegerRank(rank: dealer.cards[1].rank)
        
        print("Gambler cards:")
        for card in gambler.cards {
            print(card.rank)
            print(card.suit)
        }
        
        if gambler.cards.count == 2 {
            return correctBasicStrategyPlayForTwoCards(playerFirstRank: gamblerFirstCardRank, playerSecondRank: gamblerSecondCardRank, dealerRank: dealerSecondCardRank)
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
            switch gambler.total {
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
    private func correctBasicStrategyPlayForTwoCards(playerFirstRank: Int, playerSecondRank: Int, dealerRank: Int) -> String {

        if playerFirstRank == playerSecondRank && gambler.splitHand == false {
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
