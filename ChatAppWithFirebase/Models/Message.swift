//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/07/15.
//

import Foundation
import Firebase

// メッセージ情報管理クラス
class Message {
    
    // メッセージ情報
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
