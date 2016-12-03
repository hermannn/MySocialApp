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

class FeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mytableview: UITableView!
    var  posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mytableview.delegate = self
        self.mytableview.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(idKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
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
            cell.configCell(post: post)
            return cell
        }
        return PostViewCell()
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
