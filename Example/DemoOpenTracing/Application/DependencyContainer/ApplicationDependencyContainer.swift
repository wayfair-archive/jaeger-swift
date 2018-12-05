//
//  AppRouter.swift
//  ApplicationDependencyContainer
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.

import UIKit
import Jaeger

protocol DependencyContainer {
    var dataRepo: DataRepo { get }
    var demoTracer: WrapTracer { get }
    var imageDownloader: ImageDownloader { get }
}

class ApplicationDependencyContainer: DependencyContainer {

    private enum Const {
        static let spanSenderEndPoint = URL(string: "http://127.0.0.1:3000/spans")!
    }

    let dataRepo: DataRepo = LocalDataRepo()
    let imageDownloader: ImageDownloader = AssetDownloader()
    let demoTracer: WrapTracer

    init() {
        let sender = JSONSender(endPoint: Const.spanSenderEndPoint)
        self.demoTracer = DemoTracer(sender: sender, savingInterval: 15, sendingInterval: 60)
    }
}
