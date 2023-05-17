//
//  ReusableProfileContent.swift
//  Exgram
//
//  Created by Artem Listopadov on 12.05.23.
//

import SwiftUI
import SDWebImageSwiftUI

/// Поскольку приложение содержит функцию поиска пользователей, повторное использование этого компонента позволит избежать дополнительных избыточных кодов, а также упростит отображение сведений о пользователе просто  с помощью обьекта User Model

struct ReusableProfileContent: View {
    
    var user: User
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12) {
                    
                    WebImage(url: user.userProfileURL).placeholder{
                        // MARK: Placeholder Image
                        Image("user-placeholder")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        // MARK: Displaying Bio Link? If Given While Signing Up Profile Page
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
            .padding(15)
        }
    }
}
