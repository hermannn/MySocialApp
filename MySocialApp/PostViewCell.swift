//
//  PostViewCell.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 03/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit
import Firebase

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
    
    func configCell (post: Post, img: UIImage? = nil) {
        self.caption.text = post.caption
        self.nbLikes.text = "\(post.nbLikes)"
        
        if img != nil {
            self.postImage.image = img
        }else {
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                ref.data(withMaxSize: 1024 * 1024 * 2, completion: { (data, error) in
                    if error != nil {
                     print("Unable to download image from Firebase storage")
                    }else{
                      print("Image DL from Firebase storage")
                        if let imageData = data {
                            if let img = UIImage(data: imageData){
                                self.postImage.image = img
                                FeedViewController.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
        
}


