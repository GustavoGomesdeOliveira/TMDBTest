//
//  PosterViewController.swift
//  TMDBAT
//
//  Created by Gustavo Gomes de Oliveira on 12/11/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation
import UIKit

class PosterViewController: UIViewController {
    
    @IBOutlet weak var poster: UIImageView!
    var posterImage: UIImage!
    
    override func viewDidLoad() {
        
        self.poster.image = posterImage!
        
    }
    
}
