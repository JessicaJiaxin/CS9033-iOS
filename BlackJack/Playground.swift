//
//  Playground.swift
//  BlackJack
//
//  Created by Jiaxin Li on 2/15/15.
//  Copyright (c) 2015 Jiaxin Li. All rights reserved.
//

import Foundation
enum GameType: Int {
    case Win = 0, Lose, Tie
}

enum SpecialCase: Int {
    case Insurance = 0, Double, Split, Show, None
}

class Playground: NSObject {
    let MAX_GAME_TURN = 5
    
    private let deck = Deck()
    private var players = NSMutableArray(capacity: 2)
    private var dealer = Dealer()
    
    override init() {
        super.init()
        
        players.addObject(Player())
    }
    
    var gameTurns = 0
    var money = 100
    var bet = 0
    
    func getPlayerNum() -> Int {
        return players.count
    }
    
    func createPlayerInitCards() -> String {
        var result = ""
        
        for item in players {
            let player = item as Player
            player.initPlayerCards(self.deck)
            
            result += (player.getPlayerCardStatus() + "\n")
        }
        
        return result
    }
    
    func createDealerInitCards() -> String {
        dealer.initDealerCards(self.deck)
        return dealer.getDealerCardStatus()
    }
    
    func playerAppendCard() -> Bool {
        
        for item in players {
            let player = item as Player
            
            if player.isTurnOver {
                continue
            }
            
            return player.playerHitCard(self.deck)
        }
        
        return false
    }
    
    func playerExists() -> Bool {
        if players.count < 2 {
            let player = players.objectAtIndex(0) as Player
            player.isTurnOver = true
            return false
        }
        
        var result = false
        for item in players {
            let player = item as Player
            if !player.isTurnOver {
                player.isTurnOver = true
                result = true
                break;
            }
        }
        
        let last = players.objectAtIndex(1) as Player
        if last.isTurnOver {
            result = false
        }
        
        return result
    }
    
    func playerBust() -> Bool {
        for item in players {
            let player = item as Player
            if !player.isTurnOver {
                return false
            }
        }
        
        return true
    }
    
    func playerTurnOver() -> String {
        var string = ""
        for item in players {
            let player = item as Player
            
            if player.isTurnOver && player.cardSum > 21 {//bust
                string += player.playerLose()
                string += "\n"
            }else {
                string += player.getPlayerCardStatus()
                string += "\n"
            }
        }
        
        return string
    }
    
    func checkSpecialCase() -> SpecialCase {
        if dealer.cards[0].value == 10 {//show
            dealer.canShow = true
            return .Show
        }else if dealer.cards[0].value == 11 {//insurance
            return .Insurance
        }else {
            let player = players.objectAtIndex(0) as Player
            
            if player.cards[0].value == player.cards[1].value {//split
                return .Split
            }else if player.cards[0].value + player.cards[1].value == 11 {//double
                return .Double
            }
        }
        return .None
    }
    
    func playerInsurance() -> String {
        dealer.canShow = true
        
        return getDealerCardStatus()
    }
    
    func playerDouble() {
        bet *= 2
        
        for item in players {
            let player = item as Player
            player.playerHitCard(self.deck)
        }
    }
    
    func playerSpilt() -> String {
        let player = players.objectAtIndex(0) as Player
        
        players.addObject(player.splitToTwoPlayer())
        
        //add another card
        for item in players {
            let ply = item as Player
            ply.playerHitCard(self.deck)
        }
        
        return getPlayerCardStatus()
    }
    
    func playerSurrender() -> String {
        dealBets(false)
        
        var string = "Surrender! \n"
        string += getPlayerCardStatus()
        return string
    }
    
    func setBet(bet: Int) -> Bool {
        if bet <= money {
            self.bet = bet
            return true
        }
        
        return false
    }
    
    func resetGame() {
        gameTurns = 0
        money = 100
        
        deck.shuffleCards()
        newTurn()
    }
    
    func newTurn() {
        if players.count > 1 {
            players.removeObjectAtIndex(1)
        }
        
        let player = players.objectAtIndex(0) as Player
        
        player.turnOver()
        dealer.turnOver()
        
        bet = 0
    }
    
    func resetTurns() {
        deck.shuffleCards()
        gameTurns = 0;
    }
    
    func dealBets(isPlayerWin: Bool) {
        if isPlayerWin {
            self.money += bet
        }else {
            self.money -= bet
        }
    }
    
    func getDealerCardStatus() -> String {
        return dealer.getDealerCardStatus()
    }
    
    func getPlayerCardStatus() -> String {
        var result = ""
        
        for item in players {
            let player = item as Player
            result += (player.getPlayerCardStatus() + "\n")
        }
        
        return result
    }
    
    func isDealerBlackJack() -> Bool {
        if dealer.cards.count == 2 && dealer.cardSum == 21 {
            return true
        }else {
            return false
        }
    }
    
    func dealerTurn() -> Bool {
        return dealer.dealerTurn(self.deck)
    }
    
    func updatePlayerStatus(isPlayerWin: Bool) -> String {
        var string = ""
        
        for item in players {
            let player = item as Player
            if isPlayerWin {
                dealBets(true)
                string += player.playerWin()
                string += "\n"
            }else {
                let type = compareWithDealer(player)
                if type == GameType.Win {
                    dealBets(true)
                    string += player.playerWin()
                }else if type == GameType.Lose {
                    dealBets(false)
                    string += player.playerLose()
                }else {
                    string += player.playerTie()
                }
                string += "\n"
            }
        }
        
        return string
    }
    
    
    func compareWithDealer(player: Player) -> GameType {
        if dealer.cardSum > player.cardSum {
            return .Lose
        }else if dealer.cardSum < player.cardSum {
            return .Win
        }else {
            if dealer.cardSum == 21 && dealer.cards.count == player.cards.count && player.cards.count == 2 {//black jack push
                return .Tie
            }else {
                return .Lose
            }
        }
    }
}
