//
//  Card.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 3/23/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

struct Card
{
    var rank = String()
    var suit = String()
    
    static let validSuits = ["hearts", "diamonds", "spades", "clubs"]
    static let validRanks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
    
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
