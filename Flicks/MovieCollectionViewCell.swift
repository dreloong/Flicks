//
//  MovieCollectionViewCell.swift
//  Flicks
//
//  Created by Xiaofei Long on 2/5/16.
//  Copyright © 2016 Xiaofei Long. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var movie: Movie! {
        didSet {
            titleLabel.text = movie.title

            if let posterImageUrl = movie.posterImageUrl {
                let posterImageUrlRequest = NSURLRequest(URL: posterImageUrl)
                posterImageView.setImageWithURLRequest(
                    posterImageUrlRequest,
                    placeholderImage: nil,
                    success: { (request, response, image) in
                        if response != nil {
                            self.posterImageView.alpha = 0.0
                            self.posterImageView.image = image
                            UIView.animateWithDuration(0.3, animations: {
                                self.posterImageView.alpha = 1.0
                            })
                        } else {
                            self.posterImageView.image = image
                        }
                    },
                    failure: { (request, response, error) in
                        self.posterImageView.image = nil
                    }
                )
            } else {
                posterImageView.image = nil
            }
        }
    }
}
