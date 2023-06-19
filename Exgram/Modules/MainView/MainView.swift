//
//  MainView.swift
//  Exgram
//
//  Created by Artem Listopadov on 12.05.23.
//

import SwiftUI

struct MainView: View {
    @Binding var isOnboarding: Bool
    var body: some View {
        // MARK: TabView With Recent Post's And Profile Tabs
        TabView {
            PostView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        // Changing Tab Lable Tint to Black
        .tint(.black)
        .overlay(alignment: .bottom, content: {
            HStack(spacing: 0) {
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 45, height: 45)
                    .showCase(order: 3,
                              title: "All post's",
                              cornerRadius: 10,
                              style: .continuous)
                    .frame(maxWidth: .infinity)
                
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 45, height: 45)
                    .showCase(order: 4,
                              title: "Your profile",
                              cornerRadius: 10,
                              style: .continuous)
                    .frame(maxWidth: .infinity)
                
            }
            // Disabling User Interactions
            .allowsHitTesting(false)
        })
        
        /// Call this Modifier (.modifier) on the top of the current View, also it must be called once
        ///  Необходимо добавить в начало всех View и убедиться, что добавлены только один раз, в противном случае выделение будет вызвано дважды:
        
        .modifier(ShowCaseRoot(showHighlights: isOnboarding, onFinished: {
            print("Finish OnBoarding")
        }))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
