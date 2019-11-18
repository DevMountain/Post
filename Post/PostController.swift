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
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        guard let baseURL = PostController.baseURL else { return }
        //Ternary Operator deciding whether or not we are loading our first set of posts or not. We will create our query based on the Date that is returned from this boolean. By default we are loading from the current Date.
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        //Create a dictionary that we can use to make our three URLQueryItems
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        //Create our 3 Query Items based on the above dictionary.
        let queryItems = urlParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
        //Add our query items to our URL
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        let getterEndpoint = url.appendingPathExtension("json")
        
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
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                print("Error Decoding: \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
    }
    
    /*
    addPost Function
    -Parameters
        -username- String made from the text of our usernameTextField on the alertController.
        -text- String made from the text of our messageTextField on the alertController.
    -Completion- Network calls need a completion so we know when our call is complete and we can update the UI accordingly.
    */
    func addPost(username: String, text: String, completion: @escaping() -> Void) {
        guard let baseURL = PostController.baseURL else { return }
        let post = Post(username: username, text: text)
        //Create a variable that our data will be written to.
        var postData: Data
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch {
            print("Error decoding post to be saved: \(error.localizedDescription)")
            completion()
            return
        }
        
        let postEndoint = baseURL.appendingPathExtension("json")
        
        //Change the httpMethod to "POST" because we are POSTING to the URL rather than GETTING from the URL.
        var request = URLRequest(url: postEndoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion()
                return
            }
            guard data != nil else {
                print("Data is nil, Unable to verify if data was able to be plut to endpoint.")
                completion()
                return
            }
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
}
