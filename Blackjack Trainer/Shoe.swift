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
    var cards = [Card]()
    
    init(numberOfDecks: Int) {
        for _ in 0..<numberOfDecks {
            let newDeck = Deck()
            newDeck.shuffle()
            cards.append(contentsOf: newDeck.cards)
        }
    }
    
    func dealTopCard() -> Card {
        return cards.removeFirst()
    }
}
