//
//  DetailViewModel.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/27/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation

protocol DetailViewModelable: class {
    var model: DetailModel { get }
    var downloader: ImageDownloader { get }
    var tracer: WrapTracer { get }
    func viewLoaded()
}

struct DetailModel {

    init() {
        isLoading = false
        detailInfo = nil
    }

    var isLoading: Bool
    var detailInfo: String?
    var imageURL: URL?

    fileprivate mutating func update(for puppy: PuppyDetail) {
        detailInfo = puppy.story
        imageURL = puppy.imageURL
    }
}

class DetailViewModel: DetailViewModelable {

    private(set) var model = DetailModel()
    let downloader: ImageDownloader
    let tracer: WrapTracer
    let repo: DataRepo
    let puppyId: UUID

    private weak var vc: DetailViewController?

    init(vc: DetailViewController,
         downloader: ImageDownloader,
         tracer: WrapTracer,
         repo: DataRepo,
         puppyId: UUID
        ) {

        self.repo = repo
        self.downloader = downloader
        self.vc = vc
        self.tracer = tracer
        self.puppyId = puppyId
    }

    func viewLoaded() {
        loadData()
    }

    func loadData() {
        guard model.isLoading == false else { return }

        set(loading: true)
        let puppyLoadSpan = tracer.startSpan(callerType: DetailViewModel.self)

        repo.getDetail(forPuppyId: puppyId) { [weak self] result in
            puppyLoadSpan.finish()

            guard let strongSelf = self else { return }
            switch result {
            case .failure:
                strongSelf.vc?.show(error: "Oups!")
            case .success(let info):
                strongSelf.model.update(for: info)
            }

            strongSelf.set(loading: false)
            strongSelf.vc?.updateUI(fromAction: puppyLoadSpan)
        }
    }

    private func set(loading: Bool) {
        model.isLoading = loading
    }
}
