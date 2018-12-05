//
//  AppRouter.swift
//  AppDependenciesCreator
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.

import Foundation

class AppDependenciesCreator {

    enum Context {
        case consoleTracer
        case noopTracer
        case app
    }

    func create(forContext context: Context) -> DependencyContainer {
        switch context {
        case .consoleTracer: return MockApplicationDependencyContainer(context: .consoleSender)
        case .noopTracer: return MockApplicationDependencyContainer(context: .noopTracer)
        case .app: return ApplicationDependencyContainer()
        }
    }
}
