//
//  RoundBtn.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 02/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit

class RoundBtn: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1, height: 1)
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // this where the size of frame are determined
        
        layer.cornerRadius = self.frame.width / 2
    }

}
