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

class ProfilViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilImage: CircleImageView!
    @IBOutlet weak var myusername: UILabel!
    var mpickerimage:UIImagePickerController!
    static var localProfilCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mpickerimage = UIImagePickerController()
        self.mpickerimage.allowsEditing = true
        self.mpickerimage.delegate = self
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
            }
        })
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
