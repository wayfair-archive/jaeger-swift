//
//  ListViewRouter.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class ListViewRouter {

    private enum Constant {
        static let detailViewControllerId = "DetailViewControllerId"
        static let detailStoryBoard  = "DetailView"
    }

    let appDC: DependencyContainer
    private weak var vc: ListViewController?

    init(
        appDC: DependencyContainer,
        vc: ListViewController
        ) {

        self.appDC = appDC
        self.vc = vc
    }

    func showDetail(forPuppyId id: UUID) {

        let detailVC: DetailViewController = UIViewController.instantiate(
            forSBName: Constant.detailStoryBoard,
            vcId: Constant.detailViewControllerId
        )

        let vm = DetailViewModel(
            vc: detailVC,
            downloader: appDC.imageDownloader ,
            tracer: appDC.demoTracer ,
            repo: appDC.dataRepo,
            puppyId: id
        )

        detailVC.set(vm: vm)
        detailVC.modalTransitionStyle = .crossDissolve
        vc?.present(detailVC, animated: true, completion: nil)
    }
}
