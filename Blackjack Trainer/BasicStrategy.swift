//
//  BasicStrategy.swift
//  Beat the Dealer
//
//  Created by Chris Gray on 8/21/17.
//  Copyright © 2017 Chris Gray. All rights reserved.
//

import Foundation

class BasicStrategy
{
    //Aces will be passed in as 11
    func threeOrMoreCards(total: Int, soft: Bool, dealerRank: Int) -> GamblerAction {
        switch soft {
        case false:
            switch total {
            case 6...11:
                return .hit
            case 12:
                switch dealerRank {
                case 4...6:
                    return .stand
                default: //2, 3, 7...11
                    return .hit
                }
            case 13...16:
                switch dealerRank {
                case 2...6:
                    return .stand
                default: //7...11
                    return .hit
                }
            default: //17...21
                return .stand
            }
        case true:
            switch total {
            case 12...17:
                return .hit
            case 18:
                switch dealerRank {
                case 2...8:
                    return .stand
                default: //9, 10, 11
                    return .hit
                }
            default: //19...21
                return .stand
            }
        }
    }
    
    //Aces will be passed in as 11
    func twoCards(firstRank: Int, secondRank: Int, dealerRank: Int, soft: Bool, alreadySplit: Bool) -> GamblerAction {
        if firstRank == secondRank && !alreadySplit { //pairs
            switch firstRank {
            case 10:
                return .stand
            case 2, 3, 7:
                switch dealerRank {
                case 2...7:
                    return .split
                default:
                    return .hit
                }
            case 4:
                switch dealerRank {
                case 5, 6:
                    return .split
                default:
                    return .hit
                }
            case 5:
                switch dealerRank {
                case 10, 11:
                    return .hit
                default:
                    return .double
                }
            case 6:
                switch dealerRank {
                case 2...6:
                    return .split
                default:
                    return .hit
                }
            case 9:
                switch dealerRank {
                case 7, 10, 11:
                    return .stand
                default:
                    return .split
                }
            default: //8, 11
                return .split
            }
        }
            
        else if soft { //soft hands
            let cardRank = firstRank == 11 ? secondRank : firstRank
            
            switch cardRank {
            case 2, 3:
                switch dealerRank {
                case 5, 6:
                    return .double
                default:
                    return .hit
                }
            case 4, 5:
                switch dealerRank {
                case 4...6:
                    return .double
                default:
                    return .hit
                }
            case 6:
                switch dealerRank {
                case 3...6:
                    return .double
                default:
                    return .hit
                }
            case 7:
                switch dealerRank {
                case 2, 7, 8:
                    return .stand
                case 3...6:
                    return .double
                default: //9...A
                    return .hit
                }
            default: //8...10
                return .stand
            }
        }
            
        else { //hard hands
            let totalRank = firstRank + secondRank
            switch totalRank {
            case 17...21:
                return .stand
            case 13...16:
                switch dealerRank {
                case 2...6:
                    return .stand
                default:
                    return .hit
                }
            case 12:
                switch dealerRank {
                case 4...6:
                    return .stand
                default:
                    return .hit
                }
            case 11:
                switch dealerRank {
                case 11:
                    return .hit
                default:
                    return .double
                }
            case 10:
                switch dealerRank {
                case 10, 11:
                    return .hit
                default:
                    return .double
                }
            case 9:
                switch dealerRank {
                case 3...6:
                    return .double
                default:
                    return .hit
                }
            default: //5...8
                return .hit
            }
        }
    }
}
