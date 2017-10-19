//
//  Card.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class Card
{
    var rank = String()
    var suit = String()
    
    var integerRank: Int {
        switch rank {
        case "jack", "queen", "king":
            return 10
        case "ace":
            return 11
        default:
            return Int(rank)!
        }
    }
}
