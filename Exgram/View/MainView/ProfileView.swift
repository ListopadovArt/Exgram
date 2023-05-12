//
//  ProfileView.swift
//  Exgram
//
//  Created by Artem Listopadov on 12.05.23.
//

import SwiftUI

struct ProfileView: View {
    // My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                
            }
            .refreshable {
                // MARK: Refresh User Data
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // MARK: Two Actions
                        // 1. Logout
                        // 2. Delete Account
                        Button("Logout") {
                            
                        }
                        
                        Button("Delete Account", role: .destructive) {
                            
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
