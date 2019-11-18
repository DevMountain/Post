//
//  PostController.swift
//  Posts
//
//  Created by Nathan Andrus on 11/15/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//
import Foundation

class PostController {
    
    //MARK: - Default URL
    static let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    //MARK: - Properties
    var posts: [Post] = []
    
    //MARK: URL Request
    /*
     FetchPosts Function
     -Parameters
        -reset- This allows us to decide whether we are loading our first set of posts to display or we are paging for another set to add to our current posts. The parameter is changed to false in the willDisplayCell function on the PostListTableViewController.
     -Completion- Network calls need a completion so we know when our call is complete and we can update the UI accordingly.
     */
    func fetchPosts(completion: @escaping() -> Void) {
        guard let baseURL = PostController.baseURL else { return }
        let getterEndpoint = baseURL.appendingPathExtension("json")
        
        //In our fetchPosts function we are "GETTING" posts. httpMethod by default is set to "GET"
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            
            if let error = error {
                print("There was an error retrieving data in \(#function). Error: \(error)")
                completion()
                return
            }
            guard let data = data else {
                print("No data returned from data task.")
                completion()
                return
            }
            do {
                let decoder = JSONDecoder()
                //This will decode the data into a [String:Post] (a dictionary with keys being the UUID that they are stored under on the database as you will see by inspecting the json returned from the network request, and values which should be actual instances of post).
                let postDictionary = try decoder.decode([String:Post].self, from: data)
                //From the VALUES of the postDictionary, we will get an array of Posts.
                let posts: [Post] = postDictionary.compactMap({ $0.value })
                //Sort the above posts, the newest posts will be on top of the others.
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                //By default(reset = true) we are going to set our source of truth to be the returned posts.
                //If the reset is set to false, we are going to append our new posts onto our array of posts
                self.posts = sortedPosts
                completion()
            } catch {
                print("Error Decoding: \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
    }
}
