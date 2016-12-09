//
//  ProfilViewController.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 06/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import Firebase
import UIKit
import SwiftKeychainWrapper

class ProfilViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mytableview: UITableView!
    @IBOutlet weak var profilImage: CircleImageView!
    @IBOutlet weak var myusername: UILabel!
    var mpickerimage:UIImagePickerController!
    var posts = [Post]()
    var validateAction:UIAlertAction?
    static var localProfilCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mpickerimage = UIImagePickerController()
        self.mpickerimage.allowsEditing = true
        self.mpickerimage.delegate = self
        self.mytableview.delegate = self
        self.mytableview.dataSource = self
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot == \(snapshot)")
            if let userData = snapshot.value as? Dictionary<String, AnyObject> {
                if let username = userData["username"] as? String {
                    self.myusername.text = username
                }
                if let profilimg = userData["profil-img"] as? String {
                    if let img = ProfilViewController.localProfilCache.object(forKey: profilimg as NSString){
                        self.profilImage.image = img
                    }else{
                        self.downloadimg(url: profilimg)
                    }
                }
                if let posts = userData["posts"] as? Dictionary<String, AnyObject> {
                    for post in posts{
                        if let id = post.value["id"] as? String {
                            DataService.ds.REF_POSTS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                                print("snapshot == \(snapshot)")
                                    if let snapshots = snapshot.value as? Dictionary<String, AnyObject>{
                                        print("snpshots dict = \(snapshots)")
                                        let elem = Post(idKey: id, postData: snapshots)
                                        self.posts.append(elem)
                                    }
                                self.posts.sort(by: { (post, post2) -> Bool in
                                    return post.datePublished.compare(post2.datePublished) == .orderedDescending
                                })
                                self.mytableview.reloadData()
                            })
                        }
                    }
                }
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("posts count = \(posts.count)")
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = self.mytableview.dequeueReusableCell(withIdentifier: "PostinProfilCell") as? PostinProfilCell {
            if let img = ProfilViewController.localProfilCache.object(forKey: post.imageUrl as NSString){
                cell.configCellFromProfil(post: post, imgpost: img)
            }else{
                cell.configCellFromProfil(post: post)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func textEdited (sender: UITextField){
        let nbspace = sender.text?.characters.filter({ $0 == " "})
        if let space = nbspace?.count {
            if !(space > 0), !((sender.text?.isEmpty)!) {
                self.validateAction?.isEnabled = true
            }else{
                self.validateAction?.isEnabled = false
            }
        }

    }
    
    
    @IBAction func EditProfil(_ sender: AnyObject) {
        let alertcontroller = UIAlertController(title:"Change username", message: "Please enter an username", preferredStyle: .alert)
        alertcontroller.addTextField { (mytextfield) in
            mytextfield.addTarget(self, action: #selector(self.textEdited), for: .editingChanged)
        }
        validateAction = UIAlertAction(title: "Validate", style: .default) { (maction) in
            let username = alertcontroller.textFields?.first?.text
            DataService.ds.REF_USER_CURRENT.child("username").setValue(username)
            DataService.ds.REF_USER_CURRENT.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    print("edit snapshots done")
                    for snap in snapshots {
                        if let postdict = snap.value as? Dictionary<String, AnyObject> {
                            if let id = postdict["id"] as? String {
                                DataService.ds.REF_POSTS.child(id).child("username").setValue(username)
                                 print("edit username to post done")
                            }
                        }
                    }
                }
                self.myusername.text = username
                 print("end edit snapshots")
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (maction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertcontroller.addAction(validateAction!)
        alertcontroller.addAction(cancelAction)
        self.present(alertcontroller, animated: true, completion: nil)
    }
    
    @IBAction func BackPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func downloadimg (url: String){
        let ref = FIRStorage.storage().reference(forURL:url)
            ref.data(withMaxSize: 1024 * 1024 * 2, completion: { (data, error) in
                if error != nil {
                    print("Unable to dl file from images-profil")
                }else{
                    if let imgData = data {
                        let img = UIImage(data: imgData)
                         self.profilImage.image = img
                        ProfilViewController.localProfilCache.setObject(img!, forKey: url as NSString)
                    }
                }
            })
    }

    
    func saveImage(){
        if let imgData = UIImageJPEGRepresentation(self.profilImage.image!, 0.2) {
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_IMAGES_PROFIL.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("error Unable to upload profil image")
                }else{
                    let dlurl = metadata?.downloadURL()?.absoluteString
                    if let url = dlurl {
                        DataService.ds.REF_USER_CURRENT.child("profil-img").setValue(url)
                    }
                    
                }
            })
            
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.profilImage.image = image
            self.saveImage()
           // DataService.ds.REF_USER_CURRENT.child("profil-image").setValue(<#T##value: Any?##Any?#>)
        }else{
            print("Invalid image selected")
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func ImagePressed(_ sender: AnyObject) {
        self.present(mpickerimage, animated: true, completion: nil)
    }

}
