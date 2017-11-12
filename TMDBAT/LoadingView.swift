//
//  LoadingView.swift
//  TMDBAT
//
//  Created by Gustavo Gomes de Oliveira on 12/11/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
