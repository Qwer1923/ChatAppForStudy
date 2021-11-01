//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/07/11.
//

import Foundation
import Firebase

// チャットルーム情報管理クラス
class ChatRoom {
    
    // チャットルーム情報
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
