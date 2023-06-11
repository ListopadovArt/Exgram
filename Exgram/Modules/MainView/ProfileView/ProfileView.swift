//
//  ProfileView.swift
//  Exgram
//
//  Created by Artem Listopadov on 12.05.23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    // MARK: My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            // MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // MARK: Two Actions
                        // 1. Logout
                        Button("Logout", action: logOutUser)
                        // 2. Delete Account
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
        .task {
            // This Modifer is like onAppear
            // So Fetching for the First Time Only
            /// Т.к. TASK является альтернативой onAppear, которая является асинхронным вызовом, всякий раз, когда вкладка изменяется и повторно открывается, она будет вызываться как onAppear. Вот почему мы ограничиваем это начальной выборкой (First Time)
            if myProfile != nil {
                return
            }
            // MARK: Initial Fetch
            await fetchUserData()
        }
    }
    
    // MARK: Fetching User Data
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else {
            return
        }
        // MARK: UI Must Be Update on Main Thread
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    // MARK: Logging User Out
    func logOutUser(){
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    // MARK: Deleting User Entire Account
    func deleteAccount(){
        isLoading = true
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {
                    return
                }
                // Step 1. First Deleting Profile Image From Storage
                try await Storage.storage().reference().child("Profile_Images").child(userUID).delete()
                // Step 2. Deleting Firestore User Document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // Step 3. Deleting Auth Account and Setting Log Status to False
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        // MARK: UI Must Be Update on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
