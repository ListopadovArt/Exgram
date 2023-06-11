//
//  SearchUserView.swift
//  Exgram
//
//  Created by Artem Listopadov on 17.05.23.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    // MARK: View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    // Для этого и был создан переиспользуемый ProfileView, чтобы, если мы передадим ему пользовательский обьект, он просто отобразил все данные пользователя, избегая избыточных кодов
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            // Fetch User From Firebase
            Task{
                await searchUsers()
            }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
    
    func searchUsers() async {
        do {
            // Так как нет никакого другого способа найти "String contains" в Firebase Firestore, мы должны использовать значения больше или меньше эквивалентности, чтобы найти строки в документе.
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments() // Это своего рода ограничение, поэтому лучший способ - сохранить имя пользователя полностью в нижнем регистре и вместо этого выполнять поиск со строчной буквы.
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            // UI Must be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
