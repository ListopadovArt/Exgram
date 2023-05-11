//
//  ExgramApp.swift
//  Exgram
//
//  Created by Artem Listopadov on 10.05.23.
//

import SwiftUI
import Firebase

@main
struct ExgramApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
