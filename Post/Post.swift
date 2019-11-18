//
//  Post.swift
//  Posts
//
//  Created by Nathan Andrus on 11/15/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//
import Foundation
 
//Our post object is conforming to the Codable protocol here. Doing so allows us to encode and decode our JSON into our custom made Post object.
struct Post: Codable {
    
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    //This is the timestamp used for the feature of pagination. This allows us to ask firebase for the next set of posts from the timestamp of the last received post minus a sliver of a second to make sure that it isn't the exact timestamp.
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
    /*
     Initializer for a new Post object
     
     -Parameters
        -username- non-optional string given from the Usernametextfield of the alertController
        -text- non-optional string given from the Messagetextfield of the alertController
        -timestamp- Date that is defaulted to the exact time the message is created, saved as a time interval
     */
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
