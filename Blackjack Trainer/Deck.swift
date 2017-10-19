//
//  Deck.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation
import GameplayKit

class Deck
{
    var cards = [Card]()
    
    let validSuits = ["hearts", "diamonds", "spades", "clubs"]
    let validRanks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
    
    init() {
        for rank in validRanks {
            for suit in validSuits {
                let newCard = Card()
                newCard.rank = rank
                newCard.suit = suit
                cards.append(newCard)
            }
        }
    }
    
    func shuffle() {
        let newDeck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cards) as! [Card]
        cards = newDeck
    }
}
