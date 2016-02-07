//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Xiaofei Long on 1/31/16.
//  Copyright © 2016 Xiaofei Long. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(
            width: scrollView.frame.width,
            height: infoView.frame.origin.y + infoView.frame.height
        )

        titleLabel.text = movie["title"] as? String
        dateLabel.text = movie["release_date"] as? String
        ratingLabel.text = String(movie["vote_average"] as! Float)
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        if let posterPath = movie["poster_path"] as? String {
            let posterImageUrl = NSURL(string: "http://image.tmdb.org/t/p/w500" + posterPath)
            posterImageView.setImageWithURL(posterImageUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
