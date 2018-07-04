//
//  PokerRound.swift
//  pokerOdds
//
//  Created by Bufni on 6/9/16.
//  Copyright © 2016 Bufni. All rights reserved.
//

import Foundation
import UIKit

class PokerRound {
    var smallBlind: Int
    var pot: Int
    var numberOfHandsInPlay: Int
    
    init(sB: Int, hands: Int) {
        if hands < 2 {
            smallBlind = 0
            pot = 0
            numberOfHandsInPlay = 0
        } else {
            smallBlind = sB
            pot = 3 * smallBlind
            numberOfHandsInPlay = hands
        }
    }
    
    init() {
        smallBlind = 0
        pot = 0
        numberOfHandsInPlay = 0
    }
    
    func play(_ totalNumberOfHandsInPlay: Int, dealerPosition: Int, smallBlindBet: Int) {
        var deck = [Card](repeating: Card(), count: 52) // we get a "real" deck of cards, with an array of type Card; it's empty for now, we'll populate it below
        var flop = [Card](repeating: Card(), count: 3) // seemingly adequate container for simulating dealing a flop to the playing hands; empty for now; not really requiring its own class, I think
        var turn = Card() // seemingly adequate container for simulating dealing a turn to the playing hands; empty for now; not really requiring its own class, I think
        var river = Card() // seemingly adequate container for simulating dealing a river to the playing hands; empty for now; not really requiring its own class, I think
        var smallBlind = PreFlopHand()
        var bigBlind = PreFlopHand()
        var suit = String()
        
        for i in 0...51 { // setting up the deck in order; at first we set up the suit of each card (they are ordered already, and their respective images are named from 0 to 51 ;))
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
        deck.shuffle() // using the extension below
        
        // My dealing algorithm differs a bit from the real one, as follows:
        //      - first, we will create and fill two [Card] arrays with the first card for each hand and second card for each hand - both created at the same time and ordered and filled together, so that the cards correspond to the same hand by having the same index in their respective array, respectively - immediately removing them from the deck afterwards;
        //      - second, using the established dealer position, we will form the hands from the two [Card] arrays defined above, while appending them in order (from small  blind to dealer) to a [Hand] array called initialPlayingHands (initially empty)
        // It is a bit unnatural when you really think about it, but the effect is the same and the computer can do it in a fraction of a second anyway
        
        // First:
        var firstCardOfEachPlayingHand = [Card](repeating: Card(), count: totalNumberOfHandsInPlay) // empty container for the first card of each hand; note that we can (and also need) to initialize it with a fixed number of spaces (but don't worry, everything will fit perfectly in the end)
        var secondCardOfEachPlayingHand = [Card](repeating: Card(), count: totalNumberOfHandsInPlay) // just like above, but for the second card
        
        if totalNumberOfHandsInPlay > 1 && dealerPosition <= totalNumberOfHandsInPlay - 1 { // all we care about before dealing the cards is whether there is more than one player and that the dealerPosition is among those playing. obviously ;)
            
            // forming the arrays of first and second card for each playing hand, respectively; mind that the cards in each array are ordered from index 0 to last, without any care for the dealer position at this point
            for i in 0...totalNumberOfHandsInPlay - 1 {
                firstCardOfEachPlayingHand[i] = deck[i]
                secondCardOfEachPlayingHand[i] = deck[totalNumberOfHandsInPlay + i]
            }
            
            // removing the cards from the top of the deck, now that their values have been saved in the two (carefully ordered) [Card] containers
            for _ in 0...2 * totalNumberOfHandsInPlay - 1 {
                deck.remove(at: 0) // the card at the top of our deck is always at index 0. Great!
            }
        }
        
        // Second:
        // Algorithm to select the small and the big blind hands, and to start forming the playing hands by appending them in the correct order (from small blind at index 0 onward) to a [Hand] array called preFlopHands. Seems choppy, maybe there's a more elegant way to do it; however, I'm quite proud of the use of .append(removeAtIndex(Int)), method which will be employed shortly after with redoubled poignancy when completing the preFlopHands array
        
        var preFlopHands = [PreFlopHand]() // empty container for the hands that are initially playing
        let lastHandPosition = totalNumberOfHandsInPlay - 1 // useful in establishing who the small and big blinds are and a good pivot for assigning the hands in the correct order
        if dealerPosition <= lastHandPosition - 2 { // if there are at least two hands before the end of the [Card] arrays
            smallBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: dealerPosition+1) , cardTwo: secondCardOfEachPlayingHand.remove(at: dealerPosition+1), isSB: true, isBB: false) // generating the small blind hand with the Hand initializer and .removeAtIndex(dealerPosition+1) - dealerPosition+1 because the first hand that gets dealt to is the one to the left of the dealer (who's at index dealerPosition, remember?)
            bigBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: dealerPosition+1) , cardTwo: secondCardOfEachPlayingHand.remove(at: dealerPosition+1), isSB: false, isBB: true) // .removeAtIndex(dealerPosition+1) would seem odd when used to generate the big blind hand, but we just removed the previous tennant of index dealerPosition+1, and in its place we got the next elements of the two [Card] arrays, "sliding" one index to the left
        } else if dealerPosition == lastHandPosition - 1 { // if the dealer is at the penultimate hand in the hand order decribed by handPosition
            smallBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: dealerPosition+1), cardTwo: secondCardOfEachPlayingHand.remove(at: dealerPosition+1), isSB: true, isBB: false) // same as above: the small blind is the formed with the respective last elements of the two [Card] arrays, firstCardOfEachPlayingHand and secondCardOfEachPlayingHand (which happen to reside at index dealerPosition+1)
            bigBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: 0), cardTwo: secondCardOfEachPlayingHand.remove(at: 0), isSB: false, isBB: true) // the big blind will be formed by removing the first respective elements of our two [Card] arrays in the Hand(card One: Card, cardTwo: Card ) initializer I concocted
        } else { // in all other cases (meaning dealerPosition == lastHandPosition)
            smallBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: 0), cardTwo: secondCardOfEachPlayingHand.remove(at: 0), isSB: true, isBB: false) // using the initializer with .removeAtIndex(0) on each of the two [Card] arrays simultaneously
            bigBlind = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: 0), cardTwo: secondCardOfEachPlayingHand.remove(at: 0), isSB: false, isBB: true) // will create the correct hand for the big blind, since the two arrays have slid into the old indexes (losing the last) once the previous tennants of index 0 have been removed with the previous removal at index 0
        }
        preFlopHands.append(smallBlind) // the small blind hand goes in preFlopHands at index 0, naturally
        preFlopHands.append(bigBlind) // the big blind will be appended at (and form) index 1 of our preFlopHands [Hand] array
        
        var numberOfHandsLeftToSetUp = totalNumberOfHandsInPlay - 2 // we already set up the first two hands; incidentally, the .count property of both our [Card] arrays will also return 2 less than before the establishment of the small and big blind hands and their respective appending to the initially empty preFlopHands [Hand] array
        
        while numberOfHandsLeftToSetUp > 0 { // once we established our necessary hands (small and big blind), appended them to the preFlopHands [Hand] array and removed their cards from our two [Card] arrays respectively, we will only attempt to distribute remaining hands as long as the number of hands left to be dealt (represented by numberOfHands, reduced by 2 in the previous command) is greater than 0
            let newLastHandPosition = numberOfHandsLeftToSetUp - 1 // local constant; same explanation as above
            var hand : PreFlopHand // local container; will be filled with the appropriate Hand object, formed with the initializer and .removeAtIndex(Int)
            if dealerPosition <= newLastHandPosition - 1 { // if there is at least one hand left before the end of the positions (signified by lastHandPosition)
                hand = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: dealerPosition+1), cardTwo: secondCardOfEachPlayingHand.remove(at: dealerPosition+1), isSB: false, isBB: false) // we assign the local hand: Hand container the Hand formed with the initializer described above and the old by now .removeAtIndex(dealerPosition+1)
            } else { // meaning the dealerPosition is on the position of the last hand signified by the new local variable newLastHandPosition
                hand = PreFlopHand(game: self, cardOne: firstCardOfEachPlayingHand.remove(at: 0), cardTwo: secondCardOfEachPlayingHand.remove(at: 0), isSB: false, isBB: false) // we assign the local hand: Hand container the Hand formed with the initializer described above and the old by now .removeAtIndex(0)
            }
            preFlopHands.append(hand) // once we established the correct next hand, we append it to the preFlopHands [Hand] array
            numberOfHandsLeftToSetUp -= 1 // since we assigned a hand, the number of hands still in need of assignment is decremented by one; the initial condition of the while loop - numberOfHands > 0 - is checked and, if found true, the cycle repeats
            
        }
        
        print("The hands, in order, from small blind to dealer") // Just a check
        for preFlopHand in preFlopHands {
            print("\(preFlopHand.firstCard.name) of \(preFlopHand.firstCard.suit), \(preFlopHand.secondCard.name) of \(preFlopHand.secondCard.suit)")
            preFlopHand.calculateChenOdds()
        }
        print("Before community cards")
        print("\(deck.count) cards are left in the deck")
        
        // The pre-flop cards have been dealt, it's time to bet, evaluate who folds and who plays (I'm thinking there has to be a class "Hand"; definitely) and the odds of winning the pot of every known hand (yea, definitely a "Hand" class)
        
        // Burning a card before the flop, customarily
        deck.remove(at: 0)
        
        // Dealing the flop by populating the empty "Card" slots in the flop array of declared size 3 from above with the top card of the deck one at a time with .removeAtIndex(0)
        for i in 0...2 {
            flop[i] = deck.remove(at: 0)
        }
        print("The flop is: \(flop[0].name) of \(flop[0].suit), \(flop[1].name) of \(flop[1].suit), \(flop[2].name) of \(flop[2].suit)")
        var flopHands = [FlopHand]()
        for preFlopHand in preFlopHands {
            let flopHand = FlopHand(preFlopHand: preFlopHand, flop: flop, round: self)
            flopHands.append(flopHand)
        }
        
        for flopHand in flopHands {
            print("The hand after the flop is: \(flopHand.ownCards.firstCard.name) of \(flopHand.ownCards.firstCard.suit), \(flopHand.ownCards.secondCard.name) of \(flopHand.ownCards.secondCard.suit), \(flopHand.communityFlop[0].name) of \(flopHand.communityFlop[0].suit), \(flopHand.communityFlop[1].name) of \(flopHand.communityFlop[01].suit), \(flopHand.communityFlop[2].name) of \(flopHand.communityFlop[2].suit)")
            flopHandRanker(flopHand)
            print("******************************************")
        }
        
        // Burning another card before the turn, customarily
        deck.remove(at: 0)
        
        // Revealing the turn by updating the empty "Card" object turn to the new card at the top of the deck, always deck[0] (how convenient!), while also removing it from the deck with the process described above; another round of evaluating who folds and who plays and the odds of winning the pot of every known hand
        turn = deck.remove(at: 0)
        
        print("The turn is \(turn.name) of \(turn.suit)")
        
        var turnHands = [TurnHand]()
        for flopHand in flopHands {
            let turnHand = TurnHand(preFlopHand: flopHand.ownCards, flop: flopHand.communityFlop, turn: turn, round: self)
            turnHands.append(turnHand)
        }
        
        for turnHand in turnHands {
            let bestHand = bestFiveCardHandAfterTurn(turnHand)
            print("Best hand: \(bestHand[0].name) of \(bestHand[0].suit), \(bestHand[1].name) of \(bestHand[1].suit), \(bestHand[2].name) of \(bestHand[2].suit), \(bestHand[3].name) of \(bestHand[3].suit), \(bestHand[4].name) of \(bestHand[4].suit)")
            turnHandRanker(turnHand)
            print("&&&&&&&&&&&&&&&&&&&&&&")
        }
        
        // Burning one last card, this time before the river, also customarily, of course
        deck.remove(at: 0)
        
        // Revealing the turn by updating the empty "Card" object turn to the new card at the top of the deck, always deck[0] (how convenient!), while also removing it from the deck with the process described above; at this point we should know which hand has won the pot (bluffing aside)
        river = deck.remove(at: 0)
        print("The river is \(river.name) of \(river.suit)")
        
        var riverHands = [RiverHand]()
        for turnHand in turnHands {
            let riverHand = RiverHand(preFlopHand: turnHand.ownCards, flop: turnHand.communityFlop, turn: turnHand.turnCard, river: river, round: turnHand.game)
            riverHands.append(riverHand)
        }
        
        for riverHand in riverHands {
            let bestHand = bestFiveCardHandAfterRiver(riverHand)
            print("Best hand: \(bestHand[0].name) of \(bestHand[0].suit), \(bestHand[1].name) of \(bestHand[1].suit), \(bestHand[2].name) of \(bestHand[2].suit), \(bestHand[3].name) of \(bestHand[3].suit), \(bestHand[4].name) of \(bestHand[4].suit)")
            riverHandRanker(riverHand)
            print("$$$$$$$$$$$$$$$$$$$$$$$$$$$")            
        }
        
        print("After community cards")
        print("\(deck.count) cards are left in the deck")
    }
    

}

// Seemingly great extension from https://www.hackingwithswift.com/example-code/arrays/how-to-shuffle-an-array-in-ios-8-and-below for shuffling arrays; I had to put in the conditional statement for i != j, as I was getting errors without it - will look into it more closely
extension Array {
    mutating func shuffle() {
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
}



