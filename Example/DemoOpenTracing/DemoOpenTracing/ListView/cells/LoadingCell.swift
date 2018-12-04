//
//  LoadingCell.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = bounds.width
    }

    func config() {
        indicator.startAnimating()
    }
}
