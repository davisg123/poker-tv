//
//  PTDealer.swift
//  poker-tv
//
//  Created by Davis Gossage on 4/4/16.
//  Copyright © 2016 Davis Gossage. All rights reserved.
//

import UIKit

class PTDealer: NSObject {
    var deck: [PTCard]!
    
    static let sharedInstance = PTDealer()
    
    override init() {
        super.init()
        shuffleNewDeck()
    }
    
    private func shuffleNewDeck(){
        self.deck = []
        var card = 0
        while card != Rank.__EXHAUST.rawValue {
            self.deck.append(PTCard(suit: Suit.Hearts, rank: Rank(rawValue: card)!))
            self.deck.append(PTCard(suit: Suit.Diamonds, rank: Rank(rawValue: card)!))
            self.deck.append(PTCard(suit: Suit.Spades, rank: Rank(rawValue: card)!))
            self.deck.append(PTCard(suit: Suit.Clubs, rank: Rank(rawValue: card)!))
            card += 1
        }
        self.deck.shuffle()
        let eval = [self.deck[0].toEvalString(),self.deck[1].toEvalString(),self.deck[2].toEvalString(),self.deck[3].toEvalString(),self.deck[4].toEvalString(),self.deck[5].toEvalString(),self.deck[6].toEvalString()]
        let rank = Evaluator().evaluate7(eval)
        print(rank)
    }
}

//http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
