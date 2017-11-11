//
//  MovieTableViewCell.swift
//  TMDBAT
//
//  Created by Gustavo Gomes de Oliveira on 11/11/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImgMoviePoster: UIImageView!
    @IBOutlet weak var LblMovieName: UILabel!
    @IBOutlet weak var LblMovieReleaseDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
