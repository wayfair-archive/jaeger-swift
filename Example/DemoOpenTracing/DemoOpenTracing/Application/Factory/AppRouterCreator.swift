//
//  AppRouter.swift
//  AppRouterCreator
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.

import Foundation

class AppRouterCreator {
    func create(forAppDC appDC: DependencyContainer) -> RootRouter {
        return AppRouter(appDC: appDC)
    }
}
