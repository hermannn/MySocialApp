//
//  PostinProfilCell.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 07/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit
import Firebase

class PostinProfilCell: UITableViewCell {



    @IBOutlet weak var nbLikes: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    var post:Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCellFromProfil (post: Post, imgpost: UIImage? = nil){
        self.post = post
        self.caption.text = post.caption
        self.nbLikes.text = "\(post.nbLikes)"
        
        if imgpost != nil {
            self.postImage.image = imgpost
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
