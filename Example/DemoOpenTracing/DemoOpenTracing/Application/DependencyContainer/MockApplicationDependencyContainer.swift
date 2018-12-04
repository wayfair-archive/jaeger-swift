//
//  AppRouter.swift
//  MockApplicationDependencyContainer
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.

import Foundation

class MockApplicationDependencyContainer: DependencyContainer {

    enum Context {
        case consoleSender
        case noopTracer
    }

    let dataRepo: DataRepo = LocalDataRepo()
    let demoTracer: WrapTracer
    let imageDownloader: ImageDownloader = AssetDownloader()

    init(context: Context) {

        switch context {
        case .consoleSender:
            self.demoTracer = DemoTracer(sender: ConsoleSpanSender(), savingInterval: 5, sendingInterval: 10)
        case .noopTracer:
            self.demoTracer = NoopTracer()
        }
    }
}
