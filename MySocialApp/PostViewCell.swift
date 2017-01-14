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
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var nbLikes:UILabel!
    @IBOutlet weak var caption:UITextView!
    @IBOutlet weak var postImage:UIImageView!
    @IBOutlet weak var profilImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    var likeref:FIRDatabaseReference!
    var post:Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        self.likeImage.addGestureRecognizer(tap)
        self.likeImage.isUserInteractionEnabled = true
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        print("like Tapped")
        self.likeref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likeref.setValue(true)
                
            }else{
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likeref.removeValue()
            }
        })

    }
    
    func configCell (post: Post, imgpost: UIImage? = nil, imguser: UIImage? = nil) {
        self.post = post
        self.likeref = DataService.ds.REF_USER_CURRENT.child("likes").child(post.idKey)
        
        self.caption.text = post.caption
        self.nbLikes.text = "\(post.nbLikes)"
        self.username.text = post.username
        print("cell row init")
        print("caption == \(post.caption) -- usernmae == \(post.username)")
          print("cell row end init")
        if imguser != nil {
                self.profilImage.image = imguser
        }else{
            dlUserProfilImg()
        }
        
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
            likeref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likeImage.image = UIImage(named: "empty-heart")
                }else{
                    self.likeImage.image = UIImage(named: "filled-heart")
                }
            })
        }
    
    func dlUserProfilImg (){
        let ref = FIRStorage.storage().reference(forURL: post.imgUser)
        ref.data(withMaxSize: 1024 * 1024 * 2, completion: { (data, error) in
            if error != nil {
                print("Unable to dl image profil post to firebase")
            }else{
                if let imageData = data {
                    if let img = UIImage(data: imageData){
                        self.profilImage.image = img
                        FeedViewController.imageCache.setObject(img, forKey: self.post.imgUser as NSString)
                    }
                }
            }
        })
    }
        
}


