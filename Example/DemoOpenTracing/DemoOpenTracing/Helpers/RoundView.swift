//
//  RoundView.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/26/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}

class CornerImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}
