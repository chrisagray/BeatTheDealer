//
//  Player.swift
//  Blackjack Trainer
//
//  Created by Chris Gray on 4/10/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class Player
{
    private var hand = Hand()
    var hands = [Hand]()
    private var currentHandIndex = 0
    
    var currentHand: Hand {
        return hands[currentHandIndex]
    }
    
    var alreadySplit = false
    
    var lastHand: Bool {
        return currentHandIndex == 0
    }
    
    init() {
        hands.append(hand)
    }
    
    func splitHand() {
        alreadySplit = true
        currentHand.total = 0
        let newHand = Hand()
        newHand.cards = [hands[currentHandIndex].cards.removeLast()]
        hands.append(newHand)
        currentHandIndex += 1
    }
    
    func switchBackToFirstHand() {
        currentHandIndex -= 1
        currentHand.soft = false
    }
}
