//
//  Hand.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 4/24/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class Hand
{
    
    var soft = false
    var total = 0
    var cards = [Card]()
    var blackjack: Bool {
        return total == 21 && cards.count == 2
    }
    var bust: Bool {
        return total > 21
    }
    
    var bet = 10
    
    func add(card: Card) {
        cards.append(card)
        updateTotal(cardRank: card.integerRank)
    }
    
    func updateTotal(cardRank: Int) {
        switch cardRank {
        case 11:
            switch soft {
            case true:
                total += 1
            case false:
                total += 11
                if total > 21 {
                    total -= 10
                } else {
                    soft = true
                }
            }
        default:
            total += cardRank
            if soft {
                if total > 21 {
                    total -= 10
                    soft = false
                }
            }
        }
    }
}
