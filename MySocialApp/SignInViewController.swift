//
//  SignInViewController.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 01/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func facebookBtnPressed(_ sender: UIButton) {
        let fbLogin = FBSDKLoginManager()
        
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Unable to Authenticate with facebook - \(error)")
            } else if result?.isCancelled == true {
                print("User cancelled authentification")
            }else{
                print("Succesfully authenticated with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential: credential)
            }
        }
    }
    
    func firebaseAuth(credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to Authenticate with firebase - \(error)")
            }else {
                print("Succesfully authenticate with firebase")
            }
        })
    }
}

