//
//  ReusablePostView.swift
//  Exgram
//
//  Created by Artem Listopadov on 14.05.23.
//

import SwiftUI
import Firebase

/// Нам нужно отображать Post текущего пользователя на экране профиля,
/// и нам так же нужно отображать Posts этого пользователя при поиске другого пользователя.
/// Сделав Post повторно используемым компонентом, мы избавимся от множества избыточного кода.

struct ReusablePostView: View {
    
    @Binding var posts: [Post]
    // MARK: View Properties
    @State var isFetching: Bool = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                // Почему LazyVStack?
                // При использовании он удаляет содержимое, когда оно перемещается за пределы экрана, позволяя нам использовать onAppear() и onDisappear(), чтобы получать уведомления, когда оно фактически выходит/покидает экран.
                
                if isFetching {
                    ProgressView()
                        .padding(.top,30)
                } else {
                    if posts.isEmpty {
                        /// No Post's Found on Firestore
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top,30)
                    } else {
                        /// Displaying Post's
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            // Scroll to Refresh
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task {
            // Fetching For One Time
            guard posts.isEmpty else {
                return
            }
            await fetchPosts()
        }
    }
    
    // MARK: Displaying Fetched Post's
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts){post in
            PostCardView(post: post) { updatedPost in
                // Updating Post in the Array
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                    
                }
            } onDelete: {
                // Removing Post From the Array
                withAnimation(.easeInOut(duration: 0.25)){
                    posts.removeAll{post == $0}
                }
            }
            Divider()
                .padding(.horizontal,-15)
        }
    }
    
    func fetchPosts() async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
