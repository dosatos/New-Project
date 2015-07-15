//
//  MainScene.swift
//  NewSeagull
//
//  Created by Yeldos Balgabekov on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class MainScene: CCNode {
    
    var bestPoints: NSInteger!
    
    func didLoadFromCCB() {
    }
    
    func play() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
        
}
