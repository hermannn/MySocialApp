//
//  FeedViewController.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 03/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var captionTxtField: FancyTextField!
    @IBOutlet weak var AddImage: CircleImageView!
    @IBOutlet weak var mytableview: UITableView!
    var  posts = [Post]()
    var imagepicker:UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mytableview.delegate = self
        self.mytableview.dataSource = self
        self.imagepicker = UIImagePickerController()
        self.imagepicker.allowsEditing = true // choose how to croped the image selected 
        self.imagepicker.delegate = self
        
        print("view did load feed")
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                if self.posts.count > 0 {
                    self.posts.removeAll()
                }
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(idKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.posts.sort(by: { (post, post2) -> Bool in
                return post.datePublished.compare(post2.datePublished) == .orderedDescending
            })
            self.mytableview.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell =  self.mytableview.dequeueReusableCell(withIdentifier: "PostViewCell") as? PostViewCell {
            var imgpost: UIImage?
            var imguser: UIImage?
            
            imgpost = FeedViewController.imageCache.object(forKey: post.imageUrl as NSString)
            imguser = FeedViewController.imageCache.object(forKey: post.imgUser as NSString)
            
            if let imgpost = imgpost , let imguser = imguser {
                print("img user img post")
                cell.configCell(post: post, imgpost: imgpost, imguser: imguser)
            }else if let imgpost = imgpost, imguser == nil {
                 print("img user nil")
                cell.configCell(post: post, imgpost: imgpost)
            }else if let imguser = imguser, imgpost == nil {
                 print("img post nil")
                cell.configCell(post: post, imguser: imguser)
            }
            else {
                 print("img both nil")
                cell.configCell(post: post)
            }
                print("--------")
               return cell
        }else{
            return PostViewCell()
        }
    }
    
    //picker image function
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageSelected = true
           self.AddImage.image = image
        }
        else{
            print("Invalid image selected")
        }
         self.imagepicker.dismiss(animated: true, completion: nil)
    }
    
    
    //IBAction
    
    @IBAction func ImagePressed(_ sender: AnyObject) {
        self.present(self.imagepicker, animated: true, completion: nil)
    }

    @IBAction func PostBtnPressed(_ sender: AnyObject) {
        guard let caption = self.captionTxtField.text, caption != "" else{
            print("Caption must contain text")
            return
        }
        guard let image = self.AddImage.image, self.imageSelected == true else{
            print("An image must be selected")
            return
        }
        if let imgData = UIImageJPEGRepresentation(image, 0.2){
            let imgUid = NSUUID().uuidString // give an unique id for img
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg" // indicate to the firebase that we will store a jpeg
            
         DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
            if error != nil {
                print("Unable to upload image to Firebase storage")
            }else {
                print("Successfully uploaded image to Firebase")
                let dlurl = metadata?.downloadURL()?.absoluteString
                if let url = dlurl {
                    self.postToFirebase(imageUrl: url)
                }
            }
         })
        }
    }
    
    func postToFirebase (imageUrl: String){
        var myusername:String?
        var profilimage:String?
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot == \(snapshot)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"
            let date = Date()
            let mdate = dateFormatter.string(from: date)
            if let userData = snapshot.value as? Dictionary<String, AnyObject> {
                if let username = userData["username"] as? String {
                    myusername = username
                }
                if let profilimg = userData["profil-img"] as? String {
                   profilimage = profilimg
                }
                let post: Dictionary<String, AnyObject> = [
                    "caption" : self.captionTxtField.text! as AnyObject,
                    "imageUrl" : imageUrl as AnyObject,
                    "likes" : 0 as AnyObject,
                    "username" :  myusername! as AnyObject,
                    "date-published": mdate as AnyObject,
                    "user-img" : profilimage! as AnyObject
                ]
                
                let uuistring = NSUUID().uuidString
                let firebasePost = DataService.ds.REF_POSTS.child(uuistring)
                firebasePost.setValue(post)
                let userpost : Dictionary<String, AnyObject> = ["id": uuistring as AnyObject]
                DataService.ds.REF_USER_CURRENT.child("posts").child(uuistring).setValue(userpost)
                
                
                self.captionTxtField.text = ""
                self.imageSelected = false
                self.AddImage.image = UIImage(named: "add-image")
                if self.posts.count > 0 {
                    self.posts.removeAll()
                }
                self.mytableview.reloadData()
            }
        })
    }
    
    
    @IBAction func ProfilTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "feed-to-profil", sender: nil)
    }
    
    @IBAction func SignOutTapped(_ sender: AnyObject) {
        let keychainresult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        if keychainresult == true {
            do{
                try FIRAuth.auth()?.signOut()
            }catch{
                print("error sign out firebase")
            }
            self.dismiss(animated: true, completion: nil)
        }else{
            print("couldn't remove uid save in keychain")
        }

    }
}
