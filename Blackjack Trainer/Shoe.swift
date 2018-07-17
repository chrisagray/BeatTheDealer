//
//  GameDeck.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 4/29/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class Shoe
{
    var numberOfDecks = 0 //make only one variable - also in BlackjackGame
    
    var decks = [Deck]()
    
    var cardCount: Int {
        var count = 0
        for deck in decks {
            count += deck.cards.count
        }
        return count
    }
    
    var totalCards: Int {
        return decks.count * 52
    }
    
    var twentyFivePercent: Int {
        return Int(Double(numberOfDecks) * 52 * 0.25)
    }
    
    init(numberOfDecks: Int) {
        self.numberOfDecks = numberOfDecks
        for _ in 0..<numberOfDecks {
            decks.append(Deck())
        }
    }
    
    //want this method here or in Deck?
//    func dealTopCard() -> Card {
//        return cards.removeFirst()
//    }
}
