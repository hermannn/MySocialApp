//
//  PostViewCell.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 03/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit

class PostViewCell: UITableViewCell {
    
    @IBOutlet weak var nbLikes:UILabel!
    @IBOutlet weak var caption:UITextView!
    @IBOutlet weak var postImage:UIImageView!
    @IBOutlet weak var profilImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell (post: Post) {
        self.caption.text = post.caption
        self.nbLikes.text = "\(post.nbLikes)"
    }

}
