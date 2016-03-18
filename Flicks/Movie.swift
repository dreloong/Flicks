//
//  Movie.swift
//  Flicks
//
//  Created by Xiaofei Long on 3/17/16.
//  Copyright © 2016 Xiaofei Long. All rights reserved.
//

import Foundation

class Movie {

    let title: String!
    let overview: String?
    let releaseDate: String?
    let rating: Float?
    let posterImageUrl: NSURL?

    init(dictionary: NSDictionary) {
        title = dictionary["title"] as! String
        overview = dictionary["overview"] as? String
        releaseDate = dictionary["release_date"] as? String
        rating = dictionary["vote_average"] as? Float

        let posterPath = dictionary["poster_path"] as? String
        posterImageUrl = posterPath != nil
            ? NSURL(string: "http://image.tmdb.org/t/p/w500" + posterPath!)
            : nil
    }

    class func movies(dictionaries: [NSDictionary]) -> [Movie] {
        return dictionaries.map({ dictionary in Movie(dictionary: dictionary) })
    }
}
