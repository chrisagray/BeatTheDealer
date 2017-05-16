//
//  GameDeck.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 4/29/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class GameDeck
{
    var shoe = [Card]() //might wanna rename this to "cards"
    
    init(numberOfDecks: Int) {
        for _ in 0..<numberOfDecks {
            let newDeck = Deck(withCards: true)
            newDeck.shuffle()
            for card in newDeck.cards { //slow implementation
                shoe.append(card)
            }
        }
    }
    
    func dealTopCard() -> Card {
        return shoe.removeFirst()
    }
}
