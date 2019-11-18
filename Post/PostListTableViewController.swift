//
//  PostListTableViewController.swift
//  Posts
//
//  Created by Nathan Andrus on 11/15/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    let postController = PostController()
    
    //Instantiate our UIRefreshControl. We do this outside of our viewDidLoad so that we can access it throughout the entire class. We need add it to our tableView in the viewDidLoad as well as access it in our selector function refreshControlPulled to stop the animating.
    var pullToRefresh = UIRefreshControl()

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts {
            self.reloadTableView()
        }
        //Add our refreshControl instance to our tableView
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullToRefresh
        } else {
            // Fallback on earlier versions
        }
        pullToRefresh.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    }
    
    //This is our selector function for when the user Pulls down on the tableViewController. We are going to fetch the posts and reload the tableView upon the completion of that function.
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.pullToRefresh.endRefreshing()
            }
        }
    }
    
    //Create our reloadTableView function to call when our fetchPosts function completes. Because there are many spots in the app that we need to reload the tableView on the main thread, we can create this function and make our code more reusable.
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        //Access our source of truth to grab a single post depending on the current index of the tableView.
        let post = postController.posts[indexPath.row]
        //Our post text will occupy the main text label of our cell
        cell.textLabel?.text = post.text
        //Our detail text label will be occupied by the number of post it is, the username of the poster, and the time when it was posted. We used our .stringValue() function from our extension of date to turn that date into a more readable string.
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp).stringValue())"
        //Satisfy the demands of the cellForRowAt function that requires us to return our tableViewCell.
        return cell
    }
}
