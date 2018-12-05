//
//  PuppyCell.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class PuppyCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var puppyImage: UIImageView!

    private var savedModel: ListViewModel.PuppyModel?
    private var downloader: ImageDownloader?
    private var tracer: WrapTracer?

    func change(
        model: ListViewModel.PuppyModel,
        downloader: ImageDownloader,
        tracer: WrapTracer
        ) {
        self.tracer = tracer
        self.downloader = downloader
        self.savedModel = model
        changeImage(url: model.imageURL)
        self.nameLabel.text = model.name
    }

    private func changeImage(url: URL) {
        puppyImage.image = #imageLiteral(resourceName: "placeholder-dog.jpg")

        let changeImageSpan = tracer?.startSpan(callerType: PuppyCell.self)
        changeImageSpan?.set(tag: .init(key: "image_key", tagType: .string(url.absoluteString)))

        downloader?.getImage(at: url) { [weak self] result in

            changeImageSpan?.finish()
            guard let strongSelf = self, strongSelf.savedModel?.imageURL == url else { return }

            switch result {
            case .success(let image): strongSelf.change(image: image)
            case .failure: break
            }
        }
    }

    func change(image: UIImage) {
        UIView.transition(with: puppyImage, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.puppyImage.image = image
        }, completion: nil)
    }
}
