//
//  AppDelegate.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private static let applicationDC: DependencyContainer = {
        let ctx: AppDependenciesCreator.Context = .appJaegerPayload
        return AppDependenciesCreator().create(forContext: ctx)
    }()

    private static let mainRouter = AppRouterCreator().create(forAppDC: AppDelegate.applicationDC)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = AppDelegate.mainRouter.createRootUI()
        //UIPerformance().start()
        return true
    }
}
