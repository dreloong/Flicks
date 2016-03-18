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

    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(
            width: scrollView.frame.width,
            height: infoView.frame.origin.y + infoView.frame.height
        )

        titleLabel.text = movie.title
        dateLabel.text = movie.releaseDate
        ratingLabel.text = String(movie.rating!)
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        posterImageView.setImageWithURL(movie.posterImageUrl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
