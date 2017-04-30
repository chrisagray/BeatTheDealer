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
}
