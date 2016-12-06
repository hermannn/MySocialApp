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
import SwiftKeychainWrapper

class SignInViewController: UIViewController {

    @IBOutlet weak var passwordTxtfield: FancyTextField!
    @IBOutlet weak var emailTxtfield: FancyTextField!
    var validateAction:UIAlertAction?
    var usernameData:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            performSegue(withIdentifier: "goto-feed", sender: nil)
        }
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
                if let user = user {
                 let userData = ["provider": credential.provider]
                 self.completeSignin(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    
    @IBAction func SignInPressed(_ sender: UIButton) {
        if let email = emailTxtfield.text, let password = passwordTxtfield.text{
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticate with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignin(id: user.uid, userData: userData)
                    }
                }else{
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using email")
                        }else{
                            print("Successfully authenticate with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignin(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignin(id : String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainresult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain : \(keychainresult)")
        self.PutUsername()
        //performSegue(withIdentifier: "goto-feed", sender: nil)
        
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
    
    
    func PutUsername (){
        var username:String?
        let alertcontroller = UIAlertController(title: "One more thing", message: "Please enter an username, it must not contain any space", preferredStyle: .alert)
        alertcontroller.addTextField { (mytextfield) in
            mytextfield.addTarget(self, action: #selector(self.textEdited), for: .editingChanged)
        }
        self.validateAction = UIAlertAction(title: "Validate", style: .default, handler: { (alertaction) in
             username = alertcontroller.textFields?.first?.text
            if let usernamefill = username {
                self.usernameData = usernamefill
                DataService.ds.REF_USER_CURRENT.child("username").setValue(usernamefill)
                self.performSegue(withIdentifier: "goto-feed", sender: nil)
            }
        })
        self.validateAction?.isEnabled = false
        alertcontroller.addAction(self.validateAction!)
        self.present(alertcontroller, animated: true, completion: nil)
    }
}

