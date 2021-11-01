//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/06/10.
//

import UIKit
import Firebase

// 翻訳ライブラリのインポート
// import FirebaseMLNLTranslate

// チャットルーム管理クラス
class ChatRoomViewController: UIViewController {
    
    // チャットルーム情報の定義
    var user: User? // ログインユーザ
    var chatroom: ChatRoom?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    // iPhoneに存在するセーフエリアのボトム分を取得
    private var sefeAreaBottom: CGFloat {
        get{
            self.view.safeAreaInsets.bottom
        }
        set{}
    }
    
    // チャット送信欄の設定
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    // チャットルームテーブルビューとの紐付け
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    // 画面が切り替わったら呼び出し
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
    }
    
    // キーボードの動きに対する動きの設定
    private func setupNotification() {
        
        // キーボードが表示された時の動きの設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // キーボードの表示を無くした時の動きの設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // テーブルビューの設定
    private func setupChatRoomTableView() {
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        
        // トーク情報（吹き出し）を表示する範囲を指定
        // ※反転させているのでトップがボトムでボトムがトップ
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        
        // キーボードが表示されたら最下部まで表示できるように
        chatRoomTableView.keyboardDismissMode = .interactive
        
        // チャットルームのテーブルビューを反転
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
    }
    
    // キーボードが表示された時の動き
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userinfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeight { return }
                        
            // キーボードの高さ分だけメッセージを動かす
            let top = keyboardFrame.height - sefeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            // 最下部以外の時はズレるので微調整している
            if chatRoomTableView.contentOffset.y != -60 {
                moveY += 60
            }
            let contentInsent = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            chatRoomTableView.contentInset = contentInsent
            chatRoomTableView.scrollIndicatorInsets = contentInsent
            
            // キーボードが表示された時に一番下のメッセージまで表示
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    // キーボードの表示が消えた時の処理
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
    }
    
    // チャット送信欄をリターン
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    // ???
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // FireStoreからメッセージ情報の取得して並び替えし表示
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        // トーク情報を新しい順にリターン
                        return m1Date < m2Date
                    }
                    
                    self.chatRoomTableView.reloadData()
                    
                // 下までスクロール
                //                self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            
            
        }
        
        
    }
    
}

//
extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    // 送信ボタン後の処理
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
        
    }
    
    // 送信したいチャット情報をFireStoreに保存
    private func addMessageToFirestore (text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        
        // xcodeでmessageIdはランダム生成
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            
            
            
            let latestMessageData = [
                "latestMessageId": messageId
            ]
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }
                
                print("メッセージの保存に成功しました。")
                
                // 最新メッセージの翻訳処理
                
                
            }
        }
    }
    
    // 送信するチャットにチャットIDをランダムに生成
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}

// 
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        
        // チャットルームの吹き出し内容を反転
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
        //        cell.messageTextView.text = messages[indexPath.row]
        cell.message = messages[indexPath.row]
        return cell
    }
    
}
