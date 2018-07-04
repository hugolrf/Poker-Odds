//
//  ViewController.swift
//  pokerOdds
//
//  Created by Bufni on 6/9/16.
//  Copyright © 2016 Bufni. All rights reserved.
//






// Will simulate a game of Texas Hold'em with 10 hands initially (we'll add a way to select how many players, who's got the button, how big are the blinds, size of the pot, who bet what and who folded, and to track each known hand's odds to win the pot at a later time)


import UIKit

class ViewController: UIViewController {
    
    var round = PokerRound()
    
    
    @IBOutlet weak var numberOfHandsInput: UITextField!
    
    @IBOutlet weak var whoIsDealingInput: UITextField!
    
    @IBOutlet weak var smallBlindAmountInput: UITextField!

    @IBAction func playTapped(_ sender: AnyObject) {
        if let selectedNumberOfHands = Int(numberOfHandsInput.text!), let smallBlindAmount = Int(smallBlindAmountInput.text!), let dealerPosition = Int(whoIsDealingInput.text!) {
            if selectedNumberOfHands > 1 && selectedNumberOfHands <= 10 && Int(whoIsDealingInput.text!)! < selectedNumberOfHands {
                round.play(selectedNumberOfHands, dealerPosition: dealerPosition, smallBlindBet: smallBlindAmount)
            } else {
                print("Damn your illogical input!")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        round.play(3, dealerPosition: 2, smallBlindBet: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    



}



