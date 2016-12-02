//
//  FancyTextField.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 02/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit

class FancyTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 2.0
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        //handle position of placeholder text
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // handle position of text when editing
        return bounds.insetBy(dx: 10, dy: 5)
    }
    


}
