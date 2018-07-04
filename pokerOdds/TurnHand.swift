//
//  TurnHand.swift
//  pokerOdds
//
//  Created by Bufni on 7/7/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class TurnHand {
    var ownCards: PreFlopHand
    var communityFlop: [Card]
    var turnCard: Card
    var game: PokerRound
    
    init(preFlopHand: PreFlopHand, flop: [Card], turn: Card, round: PokerRound) {
        if flop.count != 3 || turn.value == -1 {
            ownCards = PreFlopHand()
            communityFlop = [Card]()
            turnCard = Card()
            game = PokerRound()
        } else {
            ownCards = preFlopHand
            communityFlop = flop
            turnCard = turn
            game = round
        }
    }
    
    init() {
        ownCards = PreFlopHand()
        communityFlop = [Card]()
        turnCard = Card()
        game = PokerRound()
    }
}

func bestFiveCardHandAfterTurn(_ availableCards: TurnHand) -> [Card] {
    var mySetOfSixCards = [Card]()
    mySetOfSixCards.append(availableCards.ownCards.firstCard)
    mySetOfSixCards.append(availableCards.ownCards.secondCard)
    mySetOfSixCards += availableCards.communityFlop
    mySetOfSixCards.append(availableCards.turnCard)
    
    if mySetOfSixCards.count != 6 {
        print("Not the correct number of cards after the turn (6). You gave me \(mySetOfSixCards.count) cards")
        return []
    }
    
    var possibleHandsICanMake = allSubsetsOf(mySetOfSixCards, withCardinality: 5)
    var bestHand = identifyHand(possibleHandsICanMake[0]).1
    for i in 1...possibleHandsICanMake.count - 1 {
        var currentHand: [Card] = identifyHand(possibleHandsICanMake[i]).1
        let tempWinner = winningHand(bestHand, hand2: currentHand)
        if tempWinner.count != 0 {
            if (tempWinner[0].image == currentHand[0].image) && (tempWinner[4].image == currentHand[4].image) {
                bestHand = currentHand
            }
        }
    }
    return bestHand
}

func turnHandRanker(_ hand: TurnHand) {
    let ownHand = bestFiveCardHandAfterTurn(hand)
    var knownCards = [Card]()
    knownCards.append(hand.ownCards.firstCard)
    knownCards.append(hand.ownCards.secondCard)
    knownCards += hand.communityFlop
    knownCards.append(hand.turnCard)
    let remainingDeck = setUpTheDeck(knownCards)
    let allOtherPossibleTwoCardHandsAfterTheTurn = allOtherVariations(remainingDeck, forGame: hand.game)
    
    var allOtherBestHandsAfterTurn = [[Card]]()
    for anotherPossibleTwoCardHandAfterTheTurn in allOtherPossibleTwoCardHandsAfterTheTurn {
        allOtherBestHandsAfterTurn.append(bestFiveCardHandAfterTurn(TurnHand(preFlopHand: anotherPossibleTwoCardHandAfterTheTurn, flop: hand.communityFlop, turn: hand.turnCard, round: hand.game)))
    }
    
    var winsAgainst = 0
    var losesAgainst = 0
    var chopsAgainst = 0
    for anotherPossibleBestHandAfterTurn in allOtherBestHandsAfterTurn {
        let currentHand = identifyHand(anotherPossibleBestHandAfterTurn).1
        let winner = winningHand(ownHand, hand2: currentHand)
        if winner.count != 0 {
            if (winner[0].image == ownHand[0].image) && (winner[1].image == ownHand[1].image) && (winner[2].image == ownHand[2].image) && (winner[3].image == ownHand[3].image) && (winner[4].image == ownHand[4].image) {
                winsAgainst += 1
            } else {
                losesAgainst += 1
            }
        } else {
            chopsAgainst += 1
        }
    }
    print("This hand wins against \(100 * Double(winsAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop and turn")
    print("This hand loses against \(100 * Double(losesAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop and turn")
    print("This hand chops against \(100 * Double(chopsAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop and turn")
}
