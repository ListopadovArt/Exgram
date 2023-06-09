//
//  LoginView.swift
//  Exgram
//
//  Created by Artem Listopadov on 10.05.23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LoginView: View {
    
    // MARK: - User Details
    @State var email: String = ""
    @State var password: String = ""
    // MARK: View Properties
    @State var creatAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    @Binding var isOnboarding: Bool
    // MARK: UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Let Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed!")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    // MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
                .disableWithOpacity(email == "" || password == "")
            }
            
            // MARK: Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button("Register Now") {
                    creatAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .background(
            LinearGradient(colors: [.white, colorApp],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $creatAccount) {
            RegisterView(isOnboarding: $isOnboarding)
        }
        .onAppear{
            isOnboarding = false
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
        // MARK: UI Must Be Update on Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            self.userUID = userUID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword() {
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Link Sent")
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
