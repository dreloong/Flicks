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

    @IBOutlet weak var tableView: UITableView!

    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        let progressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHud.labelText = "Loading"

        loadMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onRefresh() {
        loadMovies()
        refreshControl.endRefreshing()
    }

    func loadMovies() {
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
            completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data,
                        options:[]
                    ) as? NSDictionary {
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.tableView.reloadData()
                    }
                }
            }
        )
        task.resume()
    }

}

extension MoviesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies != nil ? movies!.count : 0
    }

    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let movie = movies![indexPath.row]
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
