//
//  CardView.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 02/06/2024.
//

import UIKit


    class CardView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        private func setupView() {
            self.layer.cornerRadius = 10
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = 4
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 0.5
        }
    }
