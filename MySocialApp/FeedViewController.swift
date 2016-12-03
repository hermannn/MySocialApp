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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mytableview.delegate = self
        self.mytableview.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print(snapshot.value)
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.mytableview.dequeueReusableCell(withIdentifier: "PostViewCell", for: indexPath)
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
