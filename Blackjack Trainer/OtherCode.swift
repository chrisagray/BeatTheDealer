//
//  OtherCode.swift
//  Beat the Dealer
//
//  Created by Chris Gray on 8/29/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class OtherCode
{
    
//    private func updateGamblerTotalLabelsAfterSplit() {
//        splitHandTotalLabel.frame = CGRect(x: gamblerCards.last!.frame.minX, y: gamblerTotalLabel.frame.minY, width: gamblerTotalLabel.frame.width, height: gamblerTotalLabel.frame.height)
//        splitHandTotalLabel.textColor = UIColor.white
//        splitHandTotalLabel.font = UIFont.systemFont(ofSize: gamblerTotalLabel.font.pointSize)
//        splitHandTotalLabel.textAlignment = .center
//        view.addSubview(splitHandTotalLabel)
//        gamblerTotalLabel.isHidden = true
//    }
    
    //    private func splitHandStandsOrBusts() {
    //        if !actionButtons[2].isEnabled {
    //            changeButtonState(button: actionButtons[2], enabled: true)
    //        }
    //        gamblerTotalLabel.isHidden = false
    //        numberOfCardsHitToPlayer = 0
    //        previousCard = gamblerCards.first!
    //        game.splitHandStandsOrBusts()
    ////        revealCardHitToPlayer()
    //        moveCircleToCurrentHand()
    //        if aces || gamblerHas21OrBusts {
    //            switchPlayToDealer()
    //        }
    //    }
    
    
    
    
    
    
    
    //    private func gamblerSplits() {
    //        previousHandWasSplit = true
    //        if game.gambler.currentHand.cards.first!.rank == "ace" && game.gambler.currentHand.cards.last!.rank == "ace" {
    //            aces = true
    //        }
    //        splitCardsOnTable()
    //        updateGamblerTotalLabelsAfterSplit()
    //        game.gambler.splitHand()
    //        revealCardHitToPlayer()
    //        moveCircleToCurrentHand()
    //        if aces || gamblerHas21OrBusts {
    //            splitHandStandsOrBusts()
    //        }
    //    }
    
    
    
    
    
    
    
    //    private func switchPlayToDealer() {
    //        //this needs to go in Model, except for all the view stuff
    //        if game.gambler.alreadySplit {
    //            currentHandCircle.removeFromSuperview()
    //        }
    //        for actionButton in actionButtons {
    //            changeButtonState(button: actionButton, enabled: false)
    //        }
    //        game.flipDealerCard()
    //        previousCard = dealerCards.last!
    //        updateCardImage(cardImageView: dealerCards.last!, card: game.dealer.currentHand.cards.last!)
    //
    //        //TODO: Should this go in Model? Is it ok to have game.method()??? Yes, definitely. But make sure all UI independent stuff goes in Model
    //        //Have to updateUI when a card is hit. Or I could update the images of all the cards after they have been hit to the dealer. Might be redundant...
    //        if !game.gambler.bust {
    //            while game.dealer.needsToHit() {
    //                game.dealTopCard(to: game.dealer)
    ////                revealCardHitToPlayer()
    //            }
    //        }
    //        updateDealerTotalLabel()
    //        endOfGameUpdates()
    //    }
}
