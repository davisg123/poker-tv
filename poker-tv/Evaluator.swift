//
//  Evaluator.swift
//  PokerHandEvaluator
//
//  Created by Ivan Sanchez on 06/10/2014.
//  Copyright (c) 2014 Gourame Limited. All rights reserved.
//

import Foundation

public class Deck {
    var cards:[String:Int]
    var count: Int {
        get {
            return cards.count
        }
    }
    init(){
        cards = [:]
        let suitDetails:[String: Int] = [
            "Spades": 0b0001,
            "Hearts": 0b0010,
            "Diamonds": 0b0100,
            "Clubs": 0b1000]
        let faces:[String:[String:Int]] = [
            "2":["index":0, "prime": 2],
            "3":["index":1, "prime": 3],
            "4":["index":2, "prime": 5],
            "5":["index":3, "prime": 7],
            "6":["index":4, "prime": 11],
            "7":["index":5, "prime": 13],
            "8":["index":6, "prime": 17],
            "9":["index":7, "prime": 19],
            "T":["index":8, "prime": 23],
            "J":["index":9, "prime": 29],
            "Q":["index":10, "prime": 31],
            "K":["index":11, "prime": 37],
            "A":["index":12, "prime": 41]]
        for face in faces.keys{
            for suit in suitDetails.keys {
                let faceIndex = faces[face]!["index"]!
                let faceValue = faceIndex << 8
                let suitValue = suitDetails[suit]! << 12
                let facePrime = faces[face]!["prime"]!
                let rank = 1 << (faceIndex + 16)
                cards[face+suit] = rank | suitValue | faceValue | facePrime
            }
        }
    }
    
    func as_binary(card:String) -> Int{
        return cards[card]!
    }
}

enum RankName: String{
    case HighCard = "High Card"
    case OnePair = "One Pair"
    case TwoPairs = "Two Pair"
    case ThreeOfAKind = "Three of a Kind"
    case Straight = "Straight"
    case Flush = "Flush"
    case FullHouse = "Full House"
    case FourOfAKind = "Four of a Kind"
    case StraightFlush = "Straight Flush!"
}

private var rankStarts:[Int:RankName] = [
    7462: RankName.HighCard,
    6185: RankName.OnePair,
    3325: RankName.TwoPairs,
    2467: RankName.ThreeOfAKind,
    1609: RankName.Straight,
    1599: RankName.Flush,
    322: RankName.FullHouse,
    166: RankName.FourOfAKind,
    10: RankName.StraightFlush
]

class HandRank: Equatable {
    var rank:Int
    var name:RankName
    init(rank:Int) {
        self.rank = rank
        let start = Array(rankStarts.keys.filter {$0 >= rank}).sort { $0 < $1 }.first!
        self.name = rankStarts[start]!
    }
}

func == (lhs: HandRank, rhs: HandRank) -> Bool {
    return lhs.rank == rhs.rank
}

class Evaluator {
    var deck = Deck()
    
    func evaluate7(cards:[String]) -> HandRank {
        var bestRank: HandRank?
        //we get all of the 7 choose 5 combinations by finding all of the 2 card combos that could be removed from the 7
        for i in 0..<6{
            for j in i...6{
                var cardsClone = cards
                guard i != j else { continue }
                //need to remove large index before small index to prevent reindexing, not the most elegant
                if (i<j){
                    cardsClone.removeAtIndex(j)
                    cardsClone.removeAtIndex(i)
                }
                else{
                    cardsClone.removeAtIndex(i)
                    cardsClone.removeAtIndex(j)
                }
                let rank = evaluate(cardsClone)
                if (bestRank == nil || bestRank?.rank > rank.rank){
                    bestRank = rank
                }
            }
        }
        return bestRank!
    }
    
    func evaluate(cards:[String]) -> HandRank {
        let cardValues = cards.map { self.deck.as_binary($0) }
        
        let handIndex = cardValues.reduce(0,combine:|) >> 16
        
        let isFlush:Bool = (cardValues.reduce(0xF000,combine:&)) != 0
        
        if isFlush {
            let flushRank = flushes[handIndex]
            return HandRank(rank:flushRank)
        }
        
        let unique5Candidate = uniqueToRanks[handIndex]
        
        if (unique5Candidate != 0){
            return HandRank(rank:unique5Candidate)
        }
        
        let primeProduct = cardValues.map { $0 & 0xFF }.reduce(1, combine:*)
        
        let combination = primeProductToCombination.indexOf(primeProduct)
        return HandRank(rank:combinationToRank[combination!])
    }
}