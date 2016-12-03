//
//  Post.swift
//  MySocialApp
//
//  Created by Hermann Dorio on 03/12/2016.
//  Copyright © 2016 Hermann Dorio. All rights reserved.
//

import Foundation

class Post {
    private var _caption:String!
    private var _imageUrl:String!
    private var _nbLikes:Int!
    private var _idKey:String!
    
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
    
    init(caption: String, imageUrl:String, nblikes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._nbLikes = nblikes
    }
    
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
        
    }
}
