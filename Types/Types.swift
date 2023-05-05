//
//  Types.swift
//  Hippo Hop
//
//  Created by Ramar Parham on 12/27/19.
//  Copyright © 2019 Ramar Parham. All rights reserved.
//

import Foundation

struct PhysicsCategory {
    static let Player:          UInt32 = 0b1
    static let Obstacle:        UInt32 = 0b10
    static let Ground:          UInt32 = 0b100
    static let Slime:           UInt32 = 0b1000
}
