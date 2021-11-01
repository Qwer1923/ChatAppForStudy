//
//  File.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/06/23.
//


import UIKit

//　最低限の決まりを設定（送信ボタンが押された時の処理）
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

// チャット送信欄管理クラス
class ChatInputAccessoryView: UIView {
    
    // チャット送信欄との紐付け
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    // 初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    // ビューの細かいレイアウトの調整
    private func setupViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1

        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    // テキストが入力されてなかったら送信ボタンが押せないように
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    // チャット送信欄の最低サイズの指定
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // チャット送信欄UIの初期化処理
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// 送信欄に文字があれば送信ボタンが押せる、逆は逆
extension ChatInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
    
}
