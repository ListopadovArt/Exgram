//
//  PostCardView.swift
//  Exgram
//
//  Created by Artem Listopadov on 14.05.23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    // Callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    // MARK: View Properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListner: ListenerRegistration? // For Live Updates
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                
                // Post Image If Any
                
                if let postImageURL = post.imageURL {
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                postInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            // Displaying Delete Button (if it's Author of that post)
            if post.userUID == userUID {
                Menu {
                    Button("Delete Post", role: .destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .containerShape(Rectangle())
                }
                .offset(x: 8)
            }
            
        })
        .onAppear{
            // Когда Post виден на экране, добавляется список документов, в противном случае список удаляется.
            // Adding Only Once
            if docListner == nil {
                guard let postID = post.id else {
                    return
                }
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            // Document Update
                            // Fetching Update Document
                            if let updatePost = try? snapshot.data(as: Post.self){
                                onUpdate(updatePost)
                            }
                        } else {
                            // Document Deleted
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
            /// Так как live updates предоставляются только тогда, когда Post отображается на экране. Мы можем снизить стоимость прочтения документа.
            // MARK: Applying SnapShot Listner Only When the Post is Available on the Screen
            // Else Removing the Listner (It saves unwanted live updates from the post which was swiped away from the screen)
            
            if let docListner {
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
    // MARK: Like/DisLike Interaction
    @ViewBuilder
    func postInteraction() -> some View {
        HStack(spacing: 6) {
            Button(action: likePost){
                // Когда пользователь ставит лайк, мы добавляем UID этого пользователя в массив likedIDs, и в зависимости от того, содержим массив или не содержит UID такого пользователя, то мы меняем изображение на соответствующее
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .particleEffect(
                        systemImage: "hand.thumbsup.fill",
                        status: post.likedIDs.contains(userUID),
                        activeTint: .pink,
                        inActiveTint: .black
                    )
                    .foregroundColor(post.likedIDs.contains(userUID) ? .pink : .black)
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(post.likedIDs.contains(userUID) ? .pink : .gray)
            
            Button(action: dislikePost){
                // Когда пользователь ставит лайк, мы добавляем UID этого пользователя в массив dislikedIDs, и в зависимости от того, содержим массив или не содержит UID такого пользователя, то мы меняем изображение на соответствующее
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading,25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
        }
        .foregroundColor(.black)
        .padding(.vertical,8)
    }
    
    
    // MARK: Liking Post
    func likePost(){
        Task {
            guard let postID = post.id else {
                return
            }
            
            if post.likedIDs.contains(userUID){
                // Removing User ID From the Arrey
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                // Adding User ID To Liked Array and removing our ID from Disliked Array (if Added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    // MARK: Disliking Post
    func dislikePost(){
        Task {
            guard let postID = post.id else {
                return
            }
            
            if post.dislikedIDs.contains(userUID){
                // Removing User ID From the Arrey
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                // Adding User ID To Liked Array and removing our ID from Disliked Array (if Added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayUnion([userUID]),
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    // Deleting Post
    func deletePost(){
        Task{
            // Step 1. Delete Image from Firebase Storage if present
            do {
                if post.imageReferenceID != ""{
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                // Step 2. Delete FireStore Document
                guard let postID = post.id else {
                    return
                }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
