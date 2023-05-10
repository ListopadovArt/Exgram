//
//  LoginView.swift
//  Exgram
//
//  Created by Artem Listopadov on 10.05.23.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - User Details
    @State var email: String = ""
    @State var password: String = ""
    
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
                
                Button("Reset password?", action: {})
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    print("Press")
                } label: {
                    // MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            
            // MARK: Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now") {
                    
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

// MARK: - View Extensions For UI Building
extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    //MARK: Custom Border View With Padding
    func border(_ width: CGFloat,_ color: Color) -> some View {
        self.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    //MARK: Custom Fill View With Padding
    func fillView(_ color: Color) -> some View {
        self.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
