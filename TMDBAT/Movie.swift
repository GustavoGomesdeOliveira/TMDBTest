//
//  Movie.swift
//  TMDBAT
//
//  Created by Gustavo Gomes de Oliveira on 11/11/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation
import UIKit
class Movie {
    
    var tittle: String!
    var posterPath: String!
    var genre: [Int]!
    var overview: String!
    var releaseDate: String!
    var id: Int!
    var posterImage: UIImage!
    
    func Movie(tittle: String, posterPath: String, genre:[Int], overview: String, releaseDate: String, id: Int){
        
        self.tittle = tittle
        self.posterPath = posterPath
        self.genre = genre
        self.overview = overview
        self.releaseDate = releaseDate
        self.id = id
    }
    
}
