//
//  RiverHand.swift
//  pokerOdds
//
//  Created by Bufni on 7/9/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class RiverHand {
    var ownCards: PreFlopHand
    var communityFlop: [Card]
    var turnCard: Card
    var riverCard: Card
    var game: PokerRound
    
    init(preFlopHand: PreFlopHand, flop: [Card], turn: Card, river: Card, round: PokerRound) {
        if flop.count != 3 || turn.value == -1 || river.value == -1 {
            ownCards = PreFlopHand()
            communityFlop = [Card]()
            turnCard = Card()
            riverCard = Card()
            game = PokerRound()
        } else {
            ownCards = preFlopHand
            communityFlop = flop
            turnCard = turn
            riverCard = river
            game = round
        }
    }
    
    init() {
        ownCards = PreFlopHand()
        communityFlop = [Card]()
        turnCard = Card()
        riverCard = Card()
        game = PokerRound()
    }
}

func bestFiveCardHandAfterRiver(_ availableCards: RiverHand) -> [Card] {
    var mySetOfSevenCards = [Card]()
    mySetOfSevenCards.append(availableCards.ownCards.firstCard)
    mySetOfSevenCards.append(availableCards.ownCards.secondCard)
    mySetOfSevenCards += availableCards.communityFlop
    mySetOfSevenCards.append(availableCards.turnCard)
    mySetOfSevenCards.append(availableCards.riverCard)
    
    if mySetOfSevenCards.count != 7 {
        print("Not the correct number of cards after the turn (6). You gave me \(mySetOfSevenCards.count) cards")
        return []
    }
    
    var possibleHandsICanMakeAfterRiver = allSubsetsOf(mySetOfSevenCards, withCardinality: 5)
    var bestHand = identifyHand(possibleHandsICanMakeAfterRiver[0]).1
    for i in 1...possibleHandsICanMakeAfterRiver.count - 1 {
        var currentHand: [Card] = identifyHand(possibleHandsICanMakeAfterRiver[i]).1
        let tempWinner = winningHand(bestHand, hand2: currentHand)
        if tempWinner.count != 0 {
            if (tempWinner[0].image == currentHand[0].image) && (tempWinner[1].image == currentHand[1].image) && (tempWinner[2].image == currentHand[2].image) && (tempWinner[3].image == currentHand[3].image) && (tempWinner[4].image == currentHand[4].image) {
                bestHand = currentHand
            }
        }
    }
    return bestHand
}

func riverHandRanker(_ hand: RiverHand) {
    let ownHand = bestFiveCardHandAfterRiver(hand)
    var knownCards = [Card]()
    knownCards.append(hand.ownCards.firstCard)
    knownCards.append(hand.ownCards.secondCard)
    knownCards += hand.communityFlop
    knownCards.append(hand.turnCard)
    knownCards.append(hand.riverCard)
    let remainingDeck = setUpTheDeck(knownCards)
    let allOtherPossibleTwoCardHandsAfterTheTurn = allOtherVariations(remainingDeck, forGame: hand.game)
    
    var allOtherBestHandsAfterTurn = [[Card]]()
    for anotherPossibleTwoCardHandAfterTheTurn in allOtherPossibleTwoCardHandsAfterTheTurn {
        allOtherBestHandsAfterTurn.append(bestFiveCardHandAfterRiver(RiverHand(preFlopHand: anotherPossibleTwoCardHandAfterTheTurn, flop: hand.communityFlop, turn: hand.turnCard, river: hand.riverCard, round: hand.game)))
    }
    
    var winsAgainst = 0
    var losesAgainst = 0
    var chopsAgainst = 0
    for anotherPossibleBestHandAfterTurn in allOtherBestHandsAfterTurn {
        let currentHand = identifyHand(anotherPossibleBestHandAfterTurn).1
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
    print("This hand wins against \(100 * Double(winsAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop, turn and river")
    print("This hand loses against \(100 * Double(losesAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop, turn and river")
    print("This hand chops against \(100 * Double(chopsAgainst) / Double(allOtherPossibleTwoCardHandsAfterTheTurn.count))% of all possible hands with this flop, turn and river")
}

