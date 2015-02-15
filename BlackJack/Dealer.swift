//
//  Dealer.swift
//  BlackJack
//
//  Created by Jiaxin Li on 2/15/15.
//  Copyright (c) 2015 Jiaxin Li. All rights reserved.
//

import Foundation
class Dealer {
    var cards = [Card]()
    
    var cardSum = 0
    var canShow = false
    
    func dealerTurn(deck: Deck) -> Bool {
        canShow = true
        
        while cardSum < 17 {
            dealerHitCard(deck)
        }
        
        if cardSum > 21 {
            return false
        }
        
        return true
    }
    
    func turnOver() {
        cardSum = 0
        canShow = false
        cards.removeAll(keepCapacity: false)
    }
    
    func initDealerCards(deck: Deck) {
        cards.append(deck.getRandomCard())
        cards.append(deck.getRandomCard())
        cardSum += cards[0].value
        cardSum += cards[1].value
    }
    
    func dealerHitCard(deck: Deck) -> Bool {
        cards.append(deck.getRandomCard())
        cardSum += cards[cards.count - 1].value
        
        return true
    }
    
    func getDealerCardStatus() -> String {
        var result = ""
        
        for card in cards {
            if cards[1] == card && !canShow {
                result += " H"
            }else {
                result += convertCardValue(card)
            }
        }
        
        if canShow {
            result += "\t Sum:\(cardSum)"
        }else {
            result += "\t Sum: Unknown"
        }
        
        return result
    }
    
    func convertCardValue(card: Card) -> String {
        if card.value == 11 || card.value == 1 {
            return " A"
        }else {
            return " \(card.value)"
        }
    }
}