//
//  Fish.swift
//  NewSeagull
//
//  Created by Yeldos Balgabekov on 7/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Fish: CCSprite {
    
    func randomPositionY(min minLevel: CGFloat, max maxLevel: CGFloat) -> CGFloat {
        return minLevel + CGFloat(arc4random_uniform(UInt32(maxLevel - minLevel)))
    }

    func didLoadFromCCB() {
        self.physicsBody.sensor = true
    }
}