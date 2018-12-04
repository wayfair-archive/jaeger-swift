//
//  AppRouter.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.

import UIKit

protocol RootRouter: class {
    func createRootUI() -> UIWindow
}

class AppRouter: RootRouter {

    private let appDC: DependencyContainer

    private struct Constant {
        static let listStoryBoard = "ListView"
        static let listViewControllerId = "ListViewControllerId"
    }

    init(appDC: DependencyContainer) {
        self.appDC = appDC
    }

    func createRootUI() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)

        let listVC: ListViewController = UIViewController.instantiate(forSBName: Constant.listStoryBoard, vcId: Constant.listViewControllerId)

        let router = ListViewRouter(appDC: appDC, vc: listVC)
        let interactor = ListViewInteractor(repo: appDC.dataRepo)
        let presenter = ListViewPresenter(
            vc: listVC, router: router,
            interator: interactor,
            downloader: appDC.imageDownloader,
            tracer: appDC.demoTracer
        )

        listVC.set(presenter: presenter)

        window.rootViewController = listVC
        window.makeKeyAndVisible()
        return window
    }
}
