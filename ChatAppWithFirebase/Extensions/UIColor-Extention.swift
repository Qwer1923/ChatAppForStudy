//
//  UIColor-Extention.swift
//  ChatAppWithFirebase
//
//  Created by Yudai Tanaka on 2021/06/10.
//

import UIKit

extension UIColor {
    
    // UIColor管理関数
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}
