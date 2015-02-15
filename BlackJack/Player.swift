//
//  Player.swift
//  BlackJack
//
//  Created by Jiaxin Li on 2/15/15.
//  Copyright (c) 2015 Jiaxin Li. All rights reserved.
//

import Foundation
class Player {
    var cardSum = 0
    var isTurnOver = false
    var cards = [Card]()
    
    func initPlayerCards(deck: Deck) {
        cards.append(deck.getRandomCard())
        cards.append(deck.getRandomCard())
        cardSum += cards[0].value
        cardSum += cards[1].value
    }
    
    func playerHitCard(deck: Deck) -> Bool {
        cards.append(deck.getRandomCard())
        cardSum += cards[cards.count - 1].value
        
        playerFindAce()
        
        if cardSum > 21 {
            isTurnOver = true
            return false
        }
        
        return true
    }
    
    func playerFindAce() {
        if cardSum > 21 {
            for card in cards {
                if card.value == 11 {
                    card.value = 1
                    cardSum -= 10
                    break
                }
            }
        }
    }
    
    func playerWin() -> String {
        return getPlayerCardStatus() + "\n Win!"
    }
    
    func playerLose() -> String {
        return getPlayerCardStatus() + "\n Lose!"
    }
    
    func playerTie() -> String {
        return getPlayerCardStatus() + "\n Tie!"
    }
    
    func getPlayerCardStatus() -> String {
        var result = ""
        
        for card in cards {
            result += convertCardValue(card)
        }
        
        result += "\t Sum: \(cardSum)"
        
        return result
    }
    
    func convertCardValue(card: Card) -> String {
        if card.value == 11 || card.value == 1 {
            return " A"
        }else {
            return " \(card.value)"
        }
    }
    
    func turnOver() {
        cardSum = 0
        isTurnOver = false
        cards.removeAll(keepCapacity: false)
    }
    
    func splitToTwoPlayer() -> Player {
        var player = Player()
        
        player.cards = [Card]();
        player.cards.append(self.cards[1])
        player.cardSum = player.cards[0].value
        self.cardSum -= self.cards[1].value
        self.cards.removeLast()
        
        return player
    }
}