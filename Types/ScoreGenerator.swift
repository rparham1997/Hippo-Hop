//
//  ScoreGenerator.swift
//  Hippo Hop
//
//  Created by Ramar Parham on 12/30/19.
//  Copyright © 2019 Ramar Parham. All rights reserved.
//

import Foundation

class ScoreGenerator {
    
    
    static let sharedInstance = ScoreGenerator()
    private init() {}
    
    static let keyHighscore = "keyHighscore"
    static let keyScore = "keyScore"
    
    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }
    
    func getScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
    
    func setHighscore(_ highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: ScoreGenerator.keyHighscore)
    }
    
    func getHighscore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyHighscore)
    }
}
