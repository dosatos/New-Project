//
//  Multiplayer.swift
//  
//
//  Created by Yeldos Balgabekov on 7/22/15.
//
//

import Firebase

import Foundation

class Multiplayer {
    // Create a connection to your Firebase database
    let ref = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com")
    
    // Save data
    ref.setValue(["name": "Alex Wolfe"])
    
    // Listen for realtime changes
    ref.observeEventType(.Value, withBlock: { snapshot in
    var name = snapshot.value["name"]
    println("User full name is \(name)")
    })
    
    
}
