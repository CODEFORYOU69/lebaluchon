//
//  style.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 24/05/2024.
//

import Foundation
import UIKit

func styleTextField(_ textField: UITextField) {
    textField.layer.cornerRadius = 8
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.lightGray.cgColor
    textField.layer.shadowColor = UIColor.black.cgColor
    textField.layer.shadowOpacity = 0.1
    textField.layer.shadowOffset = CGSize(width: 0, height: 2)
    textField.layer.shadowRadius = 4
    textField.textColor = UIColor.black
    textField.font = UIFont(name: "SFPro-CompressedMedium", size: 16)
}
func styleTextView(_ textView: UITextView) {
    textView.layer.cornerRadius = 8
    textView.layer.borderWidth = 1
    textView.layer.borderColor = UIColor.lightGray.cgColor
    textView.layer.shadowColor = UIColor.black.cgColor
    textView.layer.shadowOpacity = 0.1
    textView.layer.shadowOffset = CGSize(width: 0, height: 2)
    textView.layer.shadowRadius = 4
    textView.textColor = UIColor.black
    textView.font = UIFont(name: "SFPro-CompressedMedium", size: 12)
}

func styleButton(_ button: UIButton) {
    button.layer.cornerRadius = 8
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.lightGray.cgColor
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.2
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowRadius = 4
    button.titleLabel?.font = UIFont(name: "SFPro-CompressedMedium", size: 18)
}

func styleLabel(_ label: UILabel) {
    label.layer.cornerRadius = 8
    label.layer.borderWidth = 1
    label.layer.borderColor = UIColor.lightGray.cgColor
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.2
    label.layer.shadowOffset = CGSize(width: 0, height: 2)
    label.layer.shadowRadius = 4
}
