//
//  ViewController.swift
//  BlackJack
//
//  Created by Jiaxin Li on 2/14/15.
//  Copyright (c) 2015 Jiaxin Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var moneyStatus: UILabel!
    @IBOutlet var turnStatus: UILabel!
    @IBOutlet var currentBetStatus: UILabel!
    @IBOutlet var betInput: UITextField!
    @IBOutlet var betButton: UIButton!
    @IBOutlet var dealerStatus: UITextField!
    
    @IBOutlet var playerInd: UILabel!
    @IBOutlet var hints: UITextView!
    @IBOutlet var playerStatus: UITextView!
    
    @IBOutlet var passButton: UIButton!
    @IBOutlet var dealButton: UIButton!
    @IBOutlet var insuranceButton: UIButton!
    @IBOutlet var splitButton: UIButton!
    @IBOutlet var surrenderButton: UIButton!
    @IBOutlet var doubleButton: UIButton!
    
    var playground = Playground()
    
    var isGameStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialization
        
        betButton.addTarget(self, action: "betButtonPressed:", forControlEvents: .TouchUpInside)
        passButton.addTarget(self, action: "passButtonPressed:", forControlEvents: .TouchUpInside)
        dealButton.addTarget(self, action: "dealButtonPressed:", forControlEvents: .TouchUpInside)
        insuranceButton.addTarget(self, action: "insuranceButtonPressed:", forControlEvents: .TouchUpInside)
        doubleButton.addTarget(self, action: "doubleButtonPressed:", forControlEvents: .TouchUpInside)
        splitButton.addTarget(self, action: "splitButtonPressed:", forControlEvents: .TouchUpInside)
        surrenderButton.addTarget(self, action: "surrenderButtonPressed:", forControlEvents: .TouchUpInside)
        
        resetNewGame()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //button listener
    func betButtonPressed(sender: UIButton) {
        if betInput.text.isEmpty {
            let alert = createAlertController("Warning", msg: "Bet cannot be null.")
            presentViewController(alert, animated: false, completion: nil)
        }else {
            let bet = betInput.text.toInt()!
            if playground.setBet(bet) {
                currentBetStatus.text = "Current:\(playground.bet)"
                //hint
                hints.text = "Now press start to start the game."
                //button status
                dealButton.enabled = true
                //bet end
                betInput.enabled = false
                betButton.enabled = false
            }else {
                let alert = createAlertController("Warning", msg: "Bet should less than the money you have now.")
                presentViewController(alert, animated: false, completion: nil)
                
            }
        }
    }
    
    func passButtonPressed(sender: UIButton) {
        if insuranceButton.enabled {
            insuranceButton.enabled = false
            dealButton.enabled = true
            hints.text = "Player pass the insurance, game continue."
        }else if doubleButton.enabled {
            doubleButton.enabled = false
            dealButton.enabled = true
            hints.text = "Player pass the double bet, game continue."
        }else if splitButton.enabled {
            splitButton.enabled = false
            dealButton.enabled = true
            hints.text = "Player pass the split, game continue."
        }else if playground.playerExists() {
            playerInd.text = "Player(2)"
        }else {
            dealerTurn()
        }
    }
    
    func dealerTurn() {
        let isPlayerWin = !playground.dealerTurn()
        dealerStatus.text = playground.getDealerCardStatus()
        playerStatus.text = playground.updatePlayerStatus(isPlayerWin)
        
        endTurn()
    }
    
    func dealButtonPressed(sender: UIButton) {
        if !isGameStarted {
            isGameStarted = true
            
            //button status
            dealButton.enabled = false;
            
            passButton.enabled = true
            surrenderButton.enabled = true
            
            //change button title
            sender.setTitle("Hit", forState: .Normal)
            
            //get player & dealer cards
            playerStatus.text = playground.createPlayerInitCards()
            dealerStatus.text = playground.createDealerInitCards()
            
            //hints
            hints.text = "Pass to end turn, Hit to hit a card, Surrender to end this turn."
            
            //judge insurance & double & split
            checkSpecialCase()
        }else {
            let status = playground.playerAppendCard()
            
            if !status && playground.getPlayerNum() > 1 {
                playerInd.text = "Player(2)"
            }
            
            playerStatus.text = playground.playerTurnOver()
            
            //check player bust
            if playground.playerBust() {
                playground.bet *= playground.getPlayerNum()
                playground.dealBets(false)
                
                endTurn()
            }
        }
    }
    
    func checkSpecialCase() {
        
        let status = playground.checkSpecialCase()
        
        if status == SpecialCase.Show {
            dealerStatus.text = playground.getDealerCardStatus()
            
            if playground.isDealerBlackJack() {
                playerStatus.text =  playground.updatePlayerStatus(false)
                endTurn()
            }else {
                dealButton.enabled = true
            }
            
        }else if status == SpecialCase.Insurance { //insurance
            //button status
            insuranceButton.enabled = true
            //change hint
            hints.text = "Dealer has an Ace face up, you can choose an insurance or not, if not, press pass."
        }else if status == SpecialCase.Split { //spilt
            //button status
            splitButton.enabled = true
            
            //change hint
            hints.text = "You can split your cards now, if not, press pass."
        }else if status == SpecialCase.Double { //double
            //button status
            doubleButton.enabled = true
            //change hint
            hints.text = "You get two cards sum 11, would you like double your bets? if not, press pass."
        }else {	//normal
            dealButton.enabled = true
        }
    }
    
    func insuranceButtonPressed(sender: UIButton) {
        dealerStatus.text = playground.playerInsurance()
        
        if playground.isDealerBlackJack() {
            playerStatus.text = playground.updatePlayerStatus(true)
        }else {
            playground.setBet(playground.bet / 2) //half bet to insurance
            playerStatus.text = playground.updatePlayerStatus(false)
        }
        endTurn()
    }
    
    func doubleButtonPressed(sender: UIButton) {
        playground.playerDouble()
        //dealerTurn
        dealerTurn()
    }
    
    func splitButtonPressed(sender: UIButton) {
        let result = playground.playerSpilt()
        
        playerInd.text = "Player(1)"
        playerStatus.text = result
        
        //button status
        dealButton.enabled = true
        splitButton.enabled = false
    }
    
    func surrenderButtonPressed(sender: UIButton) {
        //change isPlayerWin
        playground.playerSurrender()
        endTurn()
    }
    
    func resetNewGame() {
        playground.resetGame()
        
        playerStatus.text = ""
        dealerStatus.text = ""
        
        createNewGame()
    }
    
    func createNewGame() {
        //player
        playerInd.text = "Player"
        
        //isGameStarted
        isGameStarted = false
        //game turn
        playground.gameTurns += 1
        
        //playground
        playground.newTurn()
        
        //button status
        betButton.enabled = true
        passButton.enabled = false
        dealButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        splitButton.enabled = false
        surrenderButton.enabled = false
        
        betInput.enabled = true
        
        //title status
        currentBetStatus.text = "Current:0"
        betInput.text = ""
        hints.text = "Please input bets you want to bet."
        dealButton.setTitle("Start", forState: UIControlState.Normal)
        moneyStatus.text = "Money:\(playground.money)"
        turnStatus.text = "Turn:\(playground.gameTurns)"
    }
    
    func endTurn() {
        //shuffle
        if playground.gameTurns == 5 {
            playground.resetTurns()
        }
        //check if game can be over
        checkGameOver()
        //create new game
        createNewGame()
    }
    
    func checkGameBets(total: Int) -> Bool {
        if playground.setBet(total) {
            let alert = createAlertController("Warning", msg: "bet can not larger than rest money.")
            presentViewController(alert, animated: false, completion: nil)
            return false
        }
        
        return true
    }
    
    func checkGameOver() {
        if playground.money < 1 {
            betButton.enabled = false
            passButton.enabled = false
            dealButton.enabled = false
            insuranceButton.enabled = false
            doubleButton.enabled = false
            splitButton.enabled = false
            surrenderButton.enabled = false
            betInput.enabled = false
            
            hints.text = "Game Over"
        }
    }
    
    func createAlertController(title: String, msg: String) -> UIAlertController {
        let alertViewController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alertViewController.addAction(okAction)
        
        return alertViewController;
    }
    
    
    @IBAction func restartGame(sender: AnyObject) {
        resetNewGame()
    }
}

