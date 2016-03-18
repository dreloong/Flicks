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

    @IBOutlet weak var collectionView: UICollectionView!

    var allMovies = [Movie]() {
        didSet {
            updateFilteredMovies()
        }
    }

    var searchText = "" {
        didSet {
            updateFilteredMovies()
        }
    }

    var filteredMovies = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }

    var endpoint: String!
    var refreshControl: UIRefreshControl!
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.keyboardAppearance = .Dark
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        let searchField = searchBar.valueForKey("_searchField") as! UITextField
        searchField.backgroundColor = UIColor(white: 0.2, alpha: 1)
        searchField.textColor = UIColor(white: 0.7, alpha: 1)
        navigationItem.titleView = searchBar

        collectionView.dataSource = self
        collectionView.delegate = self

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)

        let progressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHud.labelText = "Loading"

        updateAllMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
        let movieDetailViewController =
            segue.destinationViewController as! MovieDetailViewController
        movieDetailViewController.movie = filteredMovies[indexPath!.row]
    }

    // MARK: - Actions

    func onRefresh() {
        updateAllMovies()
        refreshControl.endRefreshing()
    }

    // MARK: - Helpers

    func updateAllMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let request = NSURLRequest(
            URL: NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!,
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
                if let error = error {
                    let alertController = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .Alert
                    )
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else if let data = data {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data,
                        options:[]
                    ) as? NSDictionary {
                        let dictionaries = responseDictionary["results"] as! [NSDictionary]
                        self.allMovies = Movie.movies(dictionaries)
                    }
                }
            }
        )
        task.resume()
    }

    func updateFilteredMovies() {
        filteredMovies = searchText.isEmpty
            ? allMovies
            : allMovies.filter({ movie in
                return movie.title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
    }
}

extension MoviesViewController: UICollectionViewDataSource {

    func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredMovies.count
    }

    func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath
    ) -> UICollectionViewCell {
        let movie = filteredMovies[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "Movie Cell",
            forIndexPath: indexPath
        ) as! MovieCollectionViewCell

        cell.movie = movie
        return cell
    }
}

extension MoviesViewController: UICollectionViewDelegate {

    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath
    ) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {

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
