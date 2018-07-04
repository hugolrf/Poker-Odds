//
//  FlopHand.swift
//  pokerOdds
//
//  Created by Bufni on 6/11/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class FlopHand {
    
    var ownCards: PreFlopHand
    var communityFlop: [Card]
    var game: PokerRound
    
    init(preFlopHand: PreFlopHand, flop: [Card], round: PokerRound) {
        if flop.count != 3 {
            ownCards = PreFlopHand()
            communityFlop = [Card]()
            game = PokerRound()
        } else {
            ownCards = preFlopHand
            communityFlop = flop
            game = round
        }
    }
    
    init() {
        ownCards = PreFlopHand()
        communityFlop = [Card]()
        game = PokerRound()
    }
    
}


func flopHandRanker(_ hand: FlopHand) {
    
    var ownHand = [Card]()
    ownHand.append(hand.ownCards.firstCard)
    ownHand.append(hand.ownCards.secondCard)
    ownHand += hand.communityFlop
    ownHand = identifyHand(ownHand).1
    print("Hand to rank: \(ownHand[0].name) of \(ownHand[0].suit), \(ownHand[1].name) of \(ownHand[1].suit), \(ownHand[2].name) of \(ownHand[2].suit), \(ownHand[3].name) of \(ownHand[3].suit), \(ownHand[4].name) of \(ownHand[4].suit)")
    
    let remainingDeck = setUpTheDeck(ownHand)
    let allOtherPossibleTwoCardHandsWithThisFlop = allOtherVariations(remainingDeck, forGame: hand.game)
    
    var allOtherPossibleFiveCardHandsWithThisFlop = [FlopHand]()
    for anotherPossibleTwoCardHandWithThisFlop in allOtherPossibleTwoCardHandsWithThisFlop {
        allOtherPossibleFiveCardHandsWithThisFlop.append((FlopHand(preFlopHand: anotherPossibleTwoCardHandWithThisFlop, flop: hand.communityFlop, round: hand.game)))
    }
    
    var winsAgainst = 0
    var losesAgainst = 0
    var chopsAgainst = 0
    for anotherPossibleFiveCardHandWithThisFlop in allOtherPossibleFiveCardHandsWithThisFlop {
        var tempHand = [Card]()
        tempHand.append(anotherPossibleFiveCardHandWithThisFlop.ownCards.firstCard)
        tempHand.append(anotherPossibleFiveCardHandWithThisFlop.ownCards.secondCard)
        tempHand += anotherPossibleFiveCardHandWithThisFlop.communityFlop
        let currentHand = identifyHand(tempHand).1
        let winner = winningHand(ownHand, hand2: currentHand)
        if winner.count != 0 {
            if (winner[0].image == ownHand[0].image) && (winner[4].image == ownHand[4].image) {
                winsAgainst += 1
            } else {
                losesAgainst += 1
            }
        } else {
            chopsAgainst += 1
        }
    }
    print("This hand wins against \(100 * Double(winsAgainst) / Double(allOtherPossibleFiveCardHandsWithThisFlop.count))% of all possible hands with this flop")
    print("This hand loses against \(100 * Double(losesAgainst) / Double(allOtherPossibleFiveCardHandsWithThisFlop.count))% of all possible hands with this flop")
    print("This hand chops against \(100 * Double(chopsAgainst) / Double(allOtherPossibleFiveCardHandsWithThisFlop.count))% of all possible hands with this flop")
}


