//
//  ImageDownloader.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

typealias ImageResult = (Result<UIImage>) -> Void

protocol ImageDownloader {
    func getImage(at url: URL, result: @escaping ImageResult)
}

class AssetDownloader: ImageDownloader {

    private var wasLoadedOnce: [URL: Bool] = [:]

    func getImage(at url: URL, result: @escaping ImageResult) {

        guard !(wasLoadedOnce[url] == true)  else {
            let image = UIImage(named: url.absoluteString)
            self.complete(with: image, at: url, result: result)
            return
        }

        let timeDelay = Double.random(in: 0.1 ..< 1)

        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeDelay) { [weak self] in
            let image = UIImage(named: url.absoluteString)
            DispatchQueue.main.async { [weak self] in
                self?.complete(with: image, at: url, result: result)
            }
        }
    }

    private func complete(with image: UIImage?, at url: URL, result: @escaping ImageResult) {
        guard let image = image else {
            result(.failure(nil))
            return
        }
        self.wasLoadedOnce[url] = true
        result(.success(image))
    }
}
