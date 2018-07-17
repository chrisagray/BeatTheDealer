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
    private(set) var cards = [Card]()
    
    init() {
        for rank in Card.validRanks {
            for suit in Card.validSuits {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        shuffle()
    }
    
    func draw() -> Card? {
        return cards.removeFirst()
    }
    
    func shuffle() {
        cards = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cards) as! [Card]
    }
}
