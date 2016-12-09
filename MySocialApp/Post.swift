//
//  Post.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 03/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _username:String!
    private var _imgUser:String!
    private var _caption:String!
    private var _imageUrl:String!
    private var _nbLikes:Int!
    private var _idKey:String!
    private var _datepublished:String!
    private var _postRef:FIRDatabaseReference!
    
    var caption:String {
        return _caption
    }
    var imageUrl:String {
        return _imageUrl
    }
    var nbLikes:Int {
        return _nbLikes
    }
    var idKey:String {
        return _idKey
    }
    var imgUser:String {
        return _imgUser
    }
    var username:String {
        return _username
    }
    var datePublished:String{
        return _datepublished
    }
    
    
    /*init(caption: String, imageUrl:String, nblikes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._nbLikes = nblikes
    }*/
    
    init(idKey: String, postData: Dictionary<String, AnyObject>) {
        self._idKey = idKey
        if let caption = postData["caption"] as? String{
            self._caption = caption
        }
        if let imageUrl = postData["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        if let nbLikes = postData["likes"] as? Int{
            self._nbLikes = nbLikes
        }
        if let username = postData["username"] as? String{
            self._username = username
        }
        if let userimg = postData["user-img"] as? String {
            self._imgUser = userimg
        }
        if let datePublished = postData["date-published"] as? String {
            self._datepublished = datePublished
        }
        _postRef = DataService.ds.REF_POSTS.child(idKey)
        
    }
    
    
    
    func adjustLikes (addLike: Bool){
        if addLike{
            _nbLikes = _nbLikes + 1
        }else{
            _nbLikes = _nbLikes - 1
        }
        _postRef.child("likes").setValue(nbLikes)
    }
}
