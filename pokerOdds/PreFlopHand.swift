//
//  Hand.swift
//  pokerOdds
//
//  Created by Bufni on 6/9/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class PreFlopHand {

    var roundOfPlay: PokerRound
    var firstCard: Card // will always hold the highest card of the pair
    var secondCard: Card
    var smallBlind: Int
    var bigBlind: Int
    var isSmallBlind: Bool // will tell us if the hand is the small blind
    var isBigBlind: Bool // same as above, but about the big blind
    var chenValue: Double!
    
    init(game: PokerRound, cardOne: Card, cardTwo: Card, isSB: Bool, isBB: Bool) {
        roundOfPlay = game
        if cardOne.value < cardTwo.value {
            firstCard = cardTwo
            secondCard = cardOne
        } else {
            firstCard = cardOne
            secondCard = cardTwo
        }
        
        isSmallBlind = isSB
        isBigBlind = isBB
        
        if isSB {
            smallBlind = roundOfPlay.smallBlind
            bigBlind = 0
        } else if isBB {
            smallBlind = 0
            bigBlind = 2 * roundOfPlay.smallBlind
        } else {
            smallBlind = 0
            bigBlind = 0
        }
        chenValue = chenValueCalculator(self)
    }
    
    init() {
        roundOfPlay = PokerRound()
        firstCard = Card()
        secondCard = Card()
        isSmallBlind = false
        isBigBlind = false
        smallBlind = 0
        bigBlind = 0
        chenValue = -10
    }
    
    func calculateChenOdds() {
        let totalCombinationsOfTwoCardsOutOfFifty = 25 * 49
        let unknownCardsBeforeTheFlop = setUpTheDeck([self.firstCard, self.secondCard])
        let allOtherPossibleTwoCardHandsInOrder = allOtherVariations(unknownCardsBeforeTheFlop, forGame: self.roundOfPlay)
        
        var allOtherChenValuesAndTheirWeight = [Double: Int]()
        var sameChenValueHandCounter = 1
        var currentChenValue = chenValueCalculator(allOtherPossibleTwoCardHandsInOrder[0])
        for i in 1...allOtherPossibleTwoCardHandsInOrder.count - 1 {
            if chenValueCalculator(allOtherPossibleTwoCardHandsInOrder[i]) == currentChenValue {
                sameChenValueHandCounter += 1
            } else {
                sameChenValueHandCounter = 1
            }
            currentChenValue = chenValueCalculator(allOtherPossibleTwoCardHandsInOrder[i])
            allOtherChenValuesAndTheirWeight[currentChenValue] = sameChenValueHandCounter
        }
        
        var winsAgainst = 0
        var tiesAgainst = 0
        var losesAgainst = 0
        for (points, weight) in allOtherChenValuesAndTheirWeight {
            if chenValueCalculator(self) > points {
                winsAgainst += weight
            } else if chenValueCalculator(self) == points {
                tiesAgainst += weight
            } else {
                losesAgainst += weight
            }
        }
        
        print("The hand has a Chen value of \(chenValueCalculator(self))")
        print("The hand has a \(Double(winsAgainst) / Double(totalCombinationsOfTwoCardsOutOfFifty)) chance to win ")
        print("The hand has a \(Double(tiesAgainst) / Double(totalCombinationsOfTwoCardsOutOfFifty)) chance to chop")
        print("The hand has a \(Double(losesAgainst) / Double(totalCombinationsOfTwoCardsOutOfFifty)) chance to lose")
        print("******************************************")
    }
    
}

func chenValueCalculator(_ hand: PreFlopHand) -> Double {
    
    var gapSubtract: Double
    switch hand.firstCard.value - hand.secondCard.value - 1 {
    case -1:
        gapSubtract = 0
    case 0:
        if hand.firstCard.value < 11 {
            gapSubtract = -1
        } else {
            gapSubtract = 0
        }
    case 1:
        if hand.firstCard.value < 11 {
            gapSubtract = 0
        } else {
            gapSubtract = 1
        }
    case 2:
        gapSubtract = 2
    case 3:
        gapSubtract = 4
    default:
        gapSubtract = 5
    }
    
    var helper: Double
    if hand.firstCard.name == hand.secondCard.name {
        if hand.firstCard.chenPoints + hand.secondCard.chenPoints >= 5 {
            helper = 2 * hand.firstCard.chenPoints
        } else {
            helper = 5
        }
    } else if hand.firstCard.suit == hand.secondCard.suit {
        helper = hand.firstCard.chenPoints + 2
    } else {
        helper = hand.firstCard.chenPoints
    }
    
    return ceil(helper - gapSubtract)
}



func allOtherVariations(_ remainingDeck: [Card], forGame: PokerRound) -> [PreFlopHand] {    
    var allOtherPossibleHandsOfTwoCardsLeft = [PreFlopHand]()
    var tempDeck = remainingDeck
    while tempDeck.count > 1 {
        let firstCardOfTheHand = tempDeck.remove(at: 0)
        for i in 0...tempDeck.count - 1 {
            let secondCardOfTheHand = tempDeck[i]
            allOtherPossibleHandsOfTwoCardsLeft.append(PreFlopHand(game: forGame, cardOne: firstCardOfTheHand, cardTwo: secondCardOfTheHand, isSB: false, isBB: false))
        }
    }
    
    var swapped = false
    repeat {
        swapped = false
        for i in 1...allOtherPossibleHandsOfTwoCardsLeft.count - 1 {
            if (chenValueCalculator(allOtherPossibleHandsOfTwoCardsLeft[i-1]) > chenValueCalculator(allOtherPossibleHandsOfTwoCardsLeft[i])) {
                let temp = allOtherPossibleHandsOfTwoCardsLeft[i-1]
                allOtherPossibleHandsOfTwoCardsLeft[i-1] = allOtherPossibleHandsOfTwoCardsLeft[i]
                allOtherPossibleHandsOfTwoCardsLeft[i] = temp
                swapped = true
            }
        }
    } while swapped
    
    return allOtherPossibleHandsOfTwoCardsLeft
}


