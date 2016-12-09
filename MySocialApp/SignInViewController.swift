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

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTxtfield: FancyTextField!
    @IBOutlet weak var emailTxtfield: FancyTextField!
    var validateAction:UIAlertAction?
    var usernameData:String?
    var isUserExist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTxtfield.delegate = self
        self.emailTxtfield.delegate = self
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
                    self.completeSignin(user: user, userData: userData, credential: credential)
                }
            }
        })
    }
    
    
    @IBAction func SignInPressed(_ sender: UIButton) {
        if let email = emailTxtfield.text, let password = passwordTxtfield.text{
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticate with Firebase")
                    self.isUserExist = true
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignin(user: user, userData: userData)
                    }
                }else{
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using email")
                        }else{
                            print("Successfully authenticate with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignin(user: user, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignin(user : FIRUser, userData: Dictionary<String, String>, credential: FIRAuthCredential? = nil) {
        
        DataService.ds.createFirebaseDBUser(uid: user.uid, userData: userData)
        let keychainresult = KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
        print("Data saved to keychain : \(keychainresult)")
        if credential != nil {
            user.reauthenticate(with: credential!, completion: { (error) in
                if error != nil {
                    self.PutUsername()
                }else{
                    print("user reauthenticate")
                    self.performSegue(withIdentifier: "goto-feed", sender: nil)
                }
            })
        }
        else{
            if isUserExist == false{
                self.PutUsername()
            }else{
                performSegue(withIdentifier: "goto-feed", sender: nil)
            }
        }
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

