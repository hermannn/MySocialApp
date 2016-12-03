//
//  FancyView.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 02/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit

class FancyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.cornerRadius = 2.0
    }

}
