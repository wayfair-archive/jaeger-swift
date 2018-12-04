//
//  UIViewControllerHelper.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

extension UIViewController {

    static func instantiate<T: UIViewController>(forSBName sbName: String, vcId: String) -> T {
        let storyBoard = UIStoryboard(name: sbName, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vcId)
        guard let vcTyped = vc as? T else { fatalError() }
        return vcTyped
    }

    static func showError(forController controller: UIViewController, message: String) {
        let title = NSLocalizedString("Error", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)

        controller.present(alert, animated: true, completion: nil)
    }
}
