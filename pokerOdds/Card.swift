//
//  Card.swift
//  pokerOdds
//
//  Created by Bufni on 6/9/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class Card {
    var value : Int // used for comparing cards' rank; cards have values from 0 (Deuce) to 13 (Ace)
    var suit : String
    var name : String // used to denominate each card value (Jack, Three, etc)
    var image : UIImage // unique identifier for each card
    var chenPoints: Double

    init(called: String, ofSuit: String) { // constructor for a Card object
        suit = ofSuit
        image = UIImage(named: called)!
        switch Int(called)! % 13 {
        case 0:
            name = "Ace"
            value = 13
            chenPoints = 10
            return
        case 1:
            name = "Two"
            value = 1
            chenPoints = 1
            return
        case 2:
            name = "Three"
            value = 2
            chenPoints = 1.5
            return
        case 3:
            name = "Four"
            value = 3
            chenPoints = 2
            return
        case 4:
            name = "Five"
            value = 4
            chenPoints = 2.5
            return
        case 5:
            name = "Six"
            value = 5
            chenPoints = 3
            return
        case 6:
            name = "Seven"
            value = 6
            chenPoints = 3.5
            return
        case 7:
            name = "Eight"
            value = 7
            chenPoints = 4
            return
        case 8:
            name = "Nine"
            value = 8
            chenPoints = 4.5
            return
        case 9:
            name = "Ten"
            value = 9
            chenPoints = 5
            return
        case 10:
            name = "Jack"
            value = 10
            chenPoints = 6
            return
        case 11:
            name = "Queen"
            value = 11
            chenPoints = 7
            return
        case 12:
            name = "King"
            value = 12
            chenPoints = 8
            return
        default:
            name = ""
            value = -1
            chenPoints = 0
            print("Cannot do that")
            break
        }
    }
    
    init() {
        value = -1
        suit = ""
        name = ""
        chenPoints = 0
        image = UIImage(named: "back")!
    }
}

// Function that returns a deck of cards minus the ones we know already
func setUpTheDeck(_ knownCards: [Card]) -> [Card] {
    var deck = [Card]() // creating an empty deck  - an empty array of Card objects
    var remainingDeck = [Card]() // container for the rest of the deck once the known cards have been removed
    
    var suit = ""
    // setting up a new deck in order; at first we set up the suit of each card (they are ordered already, and their respective images are named from 0 to 51 ;))
    for i in 0...51 {
        if i < 13 {
            suit = "Spades"
        } else if i < 26 {
            suit = "Clubs"
        } else if i < 39 {
            suit = "Diamonds"
        } else {
            suit = "Hearts"
        }
        deck.append(Card(called: "\(i)", ofSuit: suit)) // appending each card in order to the initially empty deck
    }
    
    // populating the remainingDeck container with just the unknown cards
    var i = 0
    while i < deck.count {
        var isKnown = false
        for card in knownCards {
            if (card.name == deck[i].name) && (card.suit == deck[i].suit) {
                isKnown = true
            }
        }
        if !isKnown {
            remainingDeck.append(deck[i])
        }
        i += 1
    }
    
    return remainingDeck
}


// Function that takes an unordered collection of cards, it checks whether they're five and returns a triple consisting of (the name of the hand, the ordered hand, the hand's rank)
func identifyHand(_ hand: [Card]) -> (String, [Card], Int) {
    if hand.count != 5 {
        return ("Error", hand, 0)
    } else {
        var currentHand = hand // will be used to order the initial collection of five cards
        
        // ordinary ascending order (by value) algorithm to get the original hand in a manageable state
        var swapped = false
        repeat {
            swapped = false
            for i in 1...currentHand.count - 1 {
                if (currentHand[i-1].value > currentHand[i].value) {
                    let temp = currentHand[i-1]
                    currentHand[i-1] = currentHand[i]
                    currentHand[i] = temp
                    swapped = true
                }
            }
        } while swapped
        
        // getting each card of the now ordered collection; will be used to get the hand's name and it's rank
        let lowestCard = currentHand[0]
        let thirdKicker = currentHand[1]
        let secondKicker = currentHand[2]
        let kicker = currentHand[3]
        let highestCard = currentHand[4]
        
        // check (by analyzing the cards in the hand) and return what type of hand it is: Royal Flush, Straight Flush, Four of a Kind, Full House, Flush, Straight, Three of a Kind, Two Pair, One Pair, High Card
        var handName = ""
        var handRank = 0
        if lowestCard.value == highestCard.value {
            handName = "Error, highest card cannot equal lowest card in a five-card hand"
        } else if (lowestCard.suit == thirdKicker.suit) && (thirdKicker.suit == secondKicker.suit) && (secondKicker.suit == kicker.suit) && (kicker.suit == highestCard.suit) {
            if (highestCard.value - lowestCard.value == 4) {
                if highestCard.value == 13 && kicker.value == 12 {
                    handName = "Royal Flush"
                    handRank = 1
                } else {
                    handName = "Straight Flush"
                    handRank = 2
                }
            } else if (highestCard.value == 13) && (kicker.value == 4) && (secondKicker.value == 3) && (thirdKicker.value == 2) && (lowestCard.value == 1) {
                handName = "Straight Flush"
                handRank = 2
            } else {
                handName = "Flush"
                handRank = 5
            }
        } else if (lowestCard.value == thirdKicker.value) && (thirdKicker.value == secondKicker.value) && (secondKicker.value == kicker.value) {
            handName = "Four of a Kind"
            handRank = 3
        } else if (thirdKicker.value == secondKicker.value) && (secondKicker.value == kicker.value) && (kicker.value == highestCard.value) {
            handName = "Four of a Kind"
            handRank = 3
        } else if (lowestCard.value == thirdKicker.value) && (thirdKicker.value == secondKicker.value) {
            if (kicker.value == highestCard.value) {
                handName = "Full House"
                handRank = 4
            } else {
                handName = "Three of a Kind"
                handRank = 7
            }
        } else if (thirdKicker.value == secondKicker.value) && (secondKicker.value == kicker.value) {
            handName = "Three of a Kind"
            handRank = 7
        } else if (secondKicker.value == kicker.value) && (kicker.value == highestCard.value) {
            if (lowestCard.value == thirdKicker.value) {
                handName = "Full House"
                handRank = 4
            } else {
                handName = "Three of a Kind"
                handRank = 7
            }
        } else if (lowestCard.value == thirdKicker.value) {
            if (secondKicker.value == kicker.value) {
                handName = "Two Pair"
                handRank = 8
            } else if (secondKicker.value == highestCard.value) {
                handName = "Two Pair"
                handRank = 8
            } else if (kicker.value == highestCard.value) {
                handName = "Two Pair"
                handRank = 8
            } else {
                handName = "One Pair"
                handRank = 9
            }
        } else if (thirdKicker.value == secondKicker.value) {
            if (kicker.value == highestCard.value) {
                handName = "Two Pair"
                handRank = 8
            } else {
                handName = "One Pair"
                handRank = 9
            }
        } else if (secondKicker.value == kicker.value) {
            if (lowestCard.value == thirdKicker.value) {
                handName = "Two Pair"
                handRank = 8
            } else {
                handName = "One Pair"
                handRank = 9
            }
        } else if (kicker.value == highestCard.value) {
            if (lowestCard.value == thirdKicker.value) {
                handName = "Two Pair"
                handRank = 8
            } else if (lowestCard.value == secondKicker.value) {
                handName = "Two Pair"
                handRank = 8
            } else if (thirdKicker.value == secondKicker.value) {
                handName = "Two Pair"
                handRank = 8
            } else {
                handName = "One Pair"
                handRank = 9
            }
        } else if (highestCard.value - lowestCard.value == 4) {
            handName = "Straight"
            handRank = 6
        } else if (highestCard.value == 13) && (kicker.value == 4) && (secondKicker.value == 3) && (thirdKicker.value == 2) && (lowestCard.value == 1) {
            handName = "Straight"
            handRank = 6
        } else {
            handName = "High Card"
            handRank = 10
        }
        
        return (handName, currentHand, handRank)
    }
}

// Takes two hands and returns the winner of the two
func winningHand(_ hand1: [Card], hand2: [Card]) -> [Card] {
    
    var winner = [Card]() // used for the return statement
    
    if identifyHand(hand1).2 < identifyHand(hand2).2 {
        winner = hand1
    } else if identifyHand(hand1).2 > identifyHand(hand2).2 {
        winner = hand2
    } else if identifyHand(hand1).2 == identifyHand(hand2).2 {       
        let orderedHand1 = identifyHand(hand1).1
        let orderedHand2 = identifyHand(hand2).1
        switch identifyHand(hand1).2 {
        case 2: // straight flush
            if orderedHand1[4].value > orderedHand2[4].value {
                winner = hand1
            } else if orderedHand1[4].value < orderedHand2[4].value {
                winner = hand2
            }
            break
        case 3: // 4 of a kind
            if orderedHand1[2].value > orderedHand2[2].value {
                winner = hand1
            } else if orderedHand1[2].value < orderedHand2[2].value {
                winner = hand2
            } else if max(orderedHand1[0].value, orderedHand1[4].value) > max(orderedHand2[0].value, orderedHand2[4].value) {
                winner = hand1
            } else if max(orderedHand1[0].value, orderedHand1[4].value) < max(orderedHand2[0].value, orderedHand2[4].value) {
                winner = hand2
            }
            break
        case 4: // full house
            if (orderedHand1[0].value == orderedHand1[2].value) && (orderedHand2[0].value == orderedHand2[2].value) {
                if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                }
            } else if (orderedHand1[4].value == orderedHand1[2].value) && (orderedHand2[4].value == orderedHand2[2].value) {
                if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[0].value == orderedHand1[2].value) && (orderedHand2[4].value == orderedHand2[2].value) {
                if orderedHand1[0].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[4].value {
                    winner = hand2
                }
            } else if (orderedHand1[4].value == orderedHand1[2].value) && (orderedHand2[0].value == orderedHand2[2].value) {
                if orderedHand1[4].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[0].value {
                    winner = hand2
                }
            }
            break
        case 5: // flush
            if orderedHand1[4].value > orderedHand2[4].value {
                winner = hand1
            } else if orderedHand1[4].value < orderedHand2[4].value {
                winner = hand2
            } else if orderedHand1[3].value > orderedHand2[3].value {
                winner = hand1
            } else if orderedHand1[3].value < orderedHand2[3].value {
                winner = hand2
            } else if orderedHand1[2].value > orderedHand2[2].value {
                winner = hand1
            } else if orderedHand1[2].value < orderedHand2[2].value {
                winner = hand2
            } else if orderedHand1[1].value > orderedHand2[1].value {
                winner = hand1
            } else if orderedHand1[1].value < orderedHand2[1].value {
                winner = hand2
            } else if orderedHand1[0].value > orderedHand2[0].value {
                winner = hand1
            } else if orderedHand1[0].value < orderedHand2[0].value {
                winner = hand2
            }
            break
        case 6: // straight
            if orderedHand1[4].value > orderedHand2[4].value {
                winner = hand1
            } else if orderedHand1[4].value < orderedHand2[4].value {
                winner = hand2
            }
            break
        case 7: // three of a kind
            if (orderedHand1[0].value == orderedHand1[2].value) && (orderedHand2[0].value == orderedHand2[2].value) {
                if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                }
            } else if (orderedHand1[0].value == orderedHand1[2].value) && (orderedHand2[1].value == orderedHand2[3].value) {
                if orderedHand1[0].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[1].value {
                    winner = hand2
                }
            } else if (orderedHand1[0].value == orderedHand1[2].value) && (orderedHand2[2].value == orderedHand2[4].value) {
                if orderedHand1[0].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[2].value {
                    winner = hand2
                }
            } else if (orderedHand1[1].value == orderedHand1[3].value) && (orderedHand2[0].value == orderedHand2[2].value) {
                if orderedHand1[1].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[1].value == orderedHand1[3].value) && (orderedHand2[1].value == orderedHand2[3].value) {
                if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                }
            } else if (orderedHand1[1].value == orderedHand1[3].value) && (orderedHand2[2].value == orderedHand2[4].value) {
                if orderedHand1[1].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[2].value {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[4].value) && (orderedHand2[0].value == orderedHand2[2].value) {
                if orderedHand1[2].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[4].value) && (orderedHand2[1].value == orderedHand2[3].value) {
                if orderedHand1[2].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[1].value {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[4].value) && (orderedHand2[2].value == orderedHand2[4].value) {
                if orderedHand1[2].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[2].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                }
            }
            break
        case 8: // two pair
            if (orderedHand1[4].value == orderedHand1[3].value) && (orderedHand2[4].value == orderedHand2[3].value) {
                if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[2].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[4].value == orderedHand1[3].value) && (orderedHand2[3].value == orderedHand2[2].value) {
                if orderedHand1[4].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[3].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[3].value == orderedHand1[2].value) && (orderedHand2[4].value == orderedHand2[3].value) {
                if orderedHand1[3].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else {
                    winner = hand1
                }
            } else if orderedHand1[3].value > orderedHand2[3].value {
                winner = hand1
            } else if orderedHand1[3].value < orderedHand2[3].value {
                winner = hand2
            } else if orderedHand1[1].value > orderedHand2[1].value {
                winner = hand1
            } else if orderedHand1[1].value < orderedHand2[1].value {
                winner = hand2
            } else if orderedHand1[4].value > orderedHand2[4].value {
                winner = hand1
            } else if orderedHand1[4].value < orderedHand2[4].value {
                winner = hand2
            }
            break
        case 9: // one pair
            if (orderedHand1[0].value == orderedHand1[1].value) && (orderedHand2[0].value == orderedHand2[1].value) {
                if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                } else if orderedHand1[2].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[2].value > orderedHand2[2].value {
                    winner = hand2
                }
            } else if (orderedHand1[0].value == orderedHand1[1].value) && (orderedHand2[1].value == orderedHand2[2].value) {
                if orderedHand1[0].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[0].value == orderedHand1[1].value) && (orderedHand2[2].value == orderedHand2[3].value) {
                if orderedHand1[0].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[0].value < orderedHand2[2].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[0].value == orderedHand1[1].value) && (orderedHand2[3].value == orderedHand2[4].value) {
                if orderedHand1[0].value < orderedHand2[3].value {
                    winner = hand1
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[1].value == orderedHand1[2].value) && (orderedHand2[0].value == orderedHand2[1].value) {
                if orderedHand1[1].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[1].value == orderedHand1[2].value) && (orderedHand2[1].value == orderedHand2[2].value) {
                if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[1].value == orderedHand1[2].value) && (orderedHand2[2].value == orderedHand2[3].value) {
                if orderedHand1[1].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[2].value {
                    winner = hand2
                } else if orderedHand1[4].value < orderedHand2[2].value {
                    winner = hand2
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[1].value == orderedHand1[2].value) && (orderedHand2[3].value == orderedHand2[4].value) {
                if orderedHand1[1].value < orderedHand2[3].value {
                    winner = hand2
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[2].value == orderedHand1[3].value) && (orderedHand2[0].value == orderedHand2[1].value) {
                if orderedHand1[2].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[0].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[3].value) && (orderedHand2[1].value == orderedHand2[2].value) {
                if orderedHand1[2].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[3].value) && (orderedHand2[2].value == orderedHand2[3].value) {
                if orderedHand1[2].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[2].value {
                    winner = hand2
                } else if orderedHand1[4].value > orderedHand2[4].value {
                    winner = hand1
                } else if orderedHand1[4].value < orderedHand2[4].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand2
                }
            } else if (orderedHand1[2].value == orderedHand1[3].value) && (orderedHand2[3].value == orderedHand2[4].value) {
                if orderedHand1[2].value < orderedHand2[3].value {
                    winner = hand2
                } else {
                    winner = hand1
                }
            } else if (orderedHand1[3].value == orderedHand1[4].value) && (orderedHand2[0].value == orderedHand2[1].value) {
                if orderedHand1[3].value > orderedHand2[0].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[3].value == orderedHand1[4].value) && (orderedHand2[1].value == orderedHand2[2].value) {
                if orderedHand1[3].value > orderedHand2[1].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[3].value == orderedHand1[4].value) && (orderedHand2[2].value == orderedHand2[3].value) {
                if orderedHand1[3].value > orderedHand2[2].value {
                    winner = hand1
                } else {
                    winner = hand2
                }
            } else if (orderedHand1[3].value == orderedHand1[4].value) && (orderedHand2[3].value == orderedHand2[4].value) {
                if orderedHand1[3].value > orderedHand2[3].value {
                    winner = hand1
                } else if orderedHand1[3].value < orderedHand2[3].value {
                    winner = hand2
                } else if orderedHand1[2].value > orderedHand2[2].value {
                    winner = hand1
                } else if orderedHand1[2].value < orderedHand2[2].value {
                    winner = hand2
                } else if orderedHand1[1].value > orderedHand2[1].value {
                    winner = hand1
                } else if orderedHand1[1].value < orderedHand2[1].value {
                    winner = hand2
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand1
                } else if orderedHand1[0].value > orderedHand2[0].value {
                    winner = hand2
                }
            }
            break
        case 10: // high card
            if orderedHand1[4].value > orderedHand2[4].value {
                winner = hand1
            } else if orderedHand1[4].value < orderedHand2[4].value {
                winner = hand2
            } else if orderedHand1[3].value > orderedHand2[3].value {
                winner = hand1
            } else if orderedHand1[3].value < orderedHand2[3].value {
                winner = hand2
            } else if orderedHand1[2].value > orderedHand2[2].value {
                winner = hand1
            } else if orderedHand1[2].value < orderedHand2[2].value {
                winner = hand2
            } else if orderedHand1[1].value > orderedHand2[1].value {
                winner = hand1
            } else if orderedHand1[1].value < orderedHand2[1].value {
                winner = hand2
            } else if orderedHand1[0].value > orderedHand2[0].value {
                winner = hand1
            } else if orderedHand1[0].value < orderedHand2[0].value {
                winner = hand2
            }
            break
        default:
            break
        }
    }    
    return winner
}


func allSubsetsOf(_ elements: [Card], withCardinality k : UInt, combinedWith prefix : [Card] = [], startingWithIndex j : Int = 0) -> [[Card]] {
    
    if k == 0 {
        return [prefix]
    }
    
    if j < elements.count  {
        let first = elements[j]
        return allSubsetsOf(elements, withCardinality: k-1, combinedWith: prefix + [first], startingWithIndex : j+1)
            + allSubsetsOf(elements, withCardinality: k, combinedWith: prefix, startingWithIndex: j+1)
    } else {
        return []
    }
}







