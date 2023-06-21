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
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    // MARK: View Properties
    @State var isFetching: Bool = true
    // MARK: Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
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
            // Disbaling Refresh for UID based Post's
            guard !basedOnUID else {
                return
            }
            isFetching = true
            posts = []
            // Resetting Pagination Doc
            paginationDoc = nil // Значение необходимо установить nil. Когда пользователь обновляет Posts, поскольку обновление пользователя начнется с самых последних написанных Posts и, если документ с разбивкой на страницы не был обновлен, будут получены самые последние документы.
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
                    posts.removeAll{post.id == $0.id}
                }
            }
            .onAppear{
                // When Last Post Appears, Fetching New Post (If there)
                if post.id == posts.last?.id && paginationDoc != nil {
                    /*
                     Почему проверка разбивки документа на страницы не
                     является нулевой?
                     Предположим, что всего имеется 40 постов,
                     и что при первоначальной выборке было выбрано 20
                     постов, причем документ с разбивкой
                     на страницы является 20-м постом, и что при появлении
                     последнего поста он выбирает следующий раздел
                     из 20 постов,
                     при этом документ с разбивкой на страницы является 40-м постом.
                     Когда он попытается получить другой набор из 20,
                     он будет пустым, потому что больше нет доступных постов, поэтому документ с разбивкой на страницы будет равен нулю, и он больше не будет пытаться получить посты.
                     
                     print("Fetch New Post's")
                     */
                    Task {
                        await fetchPosts()
                    }
                }
            }
            
            Divider()
                .padding(.horizontal,-15)
        }
    }
    
    // Fetching Post's
    func fetchPosts() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            // New Query For UID Based Document Fetch
            // Simply Filter the Post's Which is not belongs to this UID
            
            if basedOnUID {
                query = query.whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                // Сохранение последнего извлеченного документа, чтобы его можно было использовать для разбивки на страницы в Firebase Firestore
                paginationDoc = docs.documents.last
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
