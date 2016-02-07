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

    var allMovies = [NSDictionary]() {
        didSet {
            updateFilteredMovies()
        }
    }

    var searchText = "" {
        didSet {
            updateFilteredMovies()
        }
    }

    var filteredMovies = [NSDictionary]() {
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
                if error != nil {
                    let alertController = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription,
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
                        self.allMovies = responseDictionary["results"] as! [NSDictionary]
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
                let movieTitle = movie["title"] as! String
                return movieTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
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

        cell.titleLabel.text = movie["title"] as? String

        if let posterPath = movie["poster_path"] as? String {
            let posterImageUrl = NSURL(string: "http://image.tmdb.org/t/p/w500" + posterPath)
            let posterImageUrlRequest = NSURLRequest(URL: posterImageUrl!)
            cell.posterImageView.setImageWithURLRequest(
                posterImageUrlRequest,
                placeholderImage: nil,
                success: { (request, response, image) in
                    if response != nil {
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animateWithDuration(0.3, animations: {
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        cell.posterImageView.image = image
                    }
                },
                failure: { (request, response, error) in
                    cell.posterImageView.image = nil
                }
            )
        } else {
            cell.posterImageView.image = nil
        }

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
