//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Xiaofei Long on 1/24/16.
//  Copyright © 2016 Xiaofei Long. All rights reserved.
//

import AFNetworking
import MBProgressHUD
import UIKit

class MoviesViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var allMovies: [NSDictionary]? {
        didSet {
            updateFilteredMovies()
        }
    }

    var searchText = "" {
        didSet {
            updateFilteredMovies()
        }
    }

    var filteredMovies: [NSDictionary]? {
        didSet {
            tableView.reloadData()
        }
    }

    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        let progressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHud.labelText = "Loading"

        updateAllMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onRefresh() {
        updateAllMovies()
        refreshControl.endRefreshing()
    }

    func updateAllMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let request = NSURLRequest(
            URL: NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!,
            cachePolicy: .ReloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )

        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(
            request,
            completionHandler: { (data, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if error != nil {
                    let alertController = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription,
                        preferredStyle: .Alert
                    )
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!,
                    options:[]
                ) as? NSDictionary {
                    self.allMovies = responseDictionary["results"] as? [NSDictionary]
                }
            }
        )
        task.resume()
    }

    func updateFilteredMovies() {
        filteredMovies = allMovies == nil || searchText.isEmpty
            ? allMovies
            : allMovies!.filter({ movie in
                let movieTitle = movie["title"] as! String
                return movieTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
    }

}

extension MoviesViewController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchText = ""
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

}

extension MoviesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies != nil ? filteredMovies!.count : 0
    }

    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let movie = filteredMovies![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "Movie Cell",
            forIndexPath: indexPath
        ) as! MovieTableViewCell

        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String

        if let posterPath = movie["poster_path"] as? String {
            let posterImageUrl = NSURL(string: "http://image.tmdb.org/t/p/w500" + posterPath)
            cell.posterImageView.setImageWithURL(posterImageUrl!)
        } else {
            cell.posterImageView.image = nil
        }

        return cell
    }

}

extension MoviesViewController: UITableViewDelegate {

}
