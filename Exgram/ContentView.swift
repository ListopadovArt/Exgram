//
//  ContentView.swift
//  Exgram
//
//  Created by Artem Listopadov on 10.05.23.
//

import SwiftUI

let colorApp = Color(UIColor(red: 1.00, green: 0.98, blue: 0.88, alpha: 1.00))

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @State var isOnboarding: Bool = false
    var body: some View {
        // MARK: Redirecting User Based on Log Status
        if logStatus {
            MainView(isOnboarding: $isOnboarding)
        } else {
            LoginView(isOnboarding: $isOnboarding)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
