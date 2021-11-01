//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/07/06.
//

import Foundation
import Firebase

// ユーザ情報管理クラス
class User {
    
    // ユーザ情報
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    // 初期化メソッド
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
    
}
