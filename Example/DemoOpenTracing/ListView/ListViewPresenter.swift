//
//  ListViewPresenter.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation

protocol ListViewPresentable: class {
    func loadNewPuppies()
    func selected(puppyId id: UUID)
    func viewLoaded()
    var downloader: ImageDownloader { get }
    var tracer: WrapTracer { get }
    var model: ListViewModel { get }
}

struct ListViewModel {

    struct PuppyModel: Hashable {

        fileprivate init(puppy: Puppy) {
            self.name = puppy.name + " " + puppy.familyName
            self.imageURL = puppy.imageURL
            self.id = puppy.id
        }

        let name: String
        let imageURL: URL
        let id: UUID
    }

    fileprivate init(puppyData: [Puppy]) {
        puppies = puppyData.map { return PuppyModel(puppy: $0) }
    }

    var puppies: [PuppyModel]
}

class ListViewPresenter: ListViewPresentable {

    let downloader: ImageDownloader
    let tracer: WrapTracer

    var model: ListViewModel = ListViewModel(
        puppyData: [
            Puppy(
                name: "Saved",
                familyName: "Puppy",
                imageURL: URL(string: "puppy1")!, // demo purpose! Sorry for the force unwrap!
                id: UUID()
            )
        ]
    )

    private weak var vc: ListViewController?
    private let interator: ListViewInteractor
    private let router: ListViewRouter
    private var isLoading = false

    init(
        vc: ListViewController,
        router: ListViewRouter,
        interator: ListViewInteractor,
        downloader: ImageDownloader,
        tracer: WrapTracer
        ) {

        self.vc = vc
        self.router = router
        self.interator = interator
        self.downloader = downloader
        self.tracer = tracer
    }

    func viewLoaded() {
        vc?.addNew(puppies: model.puppies, fromAction: nil)
    }

    func loadNewPuppies() {
        guard isLoading == false else { return }
        self.update(isLoading: true)
        let loadPuppiesSpan = tracer.startSpan(callerType: ListViewPresenter.self)
        self.interator.getNewPuppies { [weak self] (value) in
            loadPuppiesSpan.finish()
            guard let strongSelf = self else { return }
            switch value {
            case .failure:
                strongSelf.update(isLoading: false)
                strongSelf.vc?.show(error: "Oups!")
            case .success(let puppies):
                strongSelf.handle(newPuppies: puppies, fromAction: loadPuppiesSpan)
            }
        }
    }

    func selected(puppyId id: UUID) {
        router.showDetail(forPuppyId: id)
    }

    private func update(isLoading: Bool) {
        self.isLoading = isLoading
    }

    private func handle(newPuppies puppies: [Puppy], fromAction action: WrapSpan?) {
        let mapPuppiesSpan = tracer.startSpan(callerType: ListViewPresenter.self, childOf: action)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let modelPuppies = puppies.map { return ListViewModel.PuppyModel(puppy: $0) }
            DispatchQueue.main.async { [weak self] in
                mapPuppiesSpan.finish()
                guard let strongSelf = self else { return }
                strongSelf.updateModel(forNewpuppies: modelPuppies, fromAction: mapPuppiesSpan)
                strongSelf.update(isLoading: false)
                strongSelf.vc?.addNew(puppies: modelPuppies, fromAction: mapPuppiesSpan)
            }
        }
    }

    private func updateModel(forNewpuppies puppies: [ListViewModel.PuppyModel], fromAction action: WrapSpan?) {
        let saveSpan = tracer.startSpan(callerType: ListViewPresenter.self, childOf: action)
        saveSpan.addOnMainThreadTag()
        self.model.puppies.append(contentsOf: puppies)
        saveSpan.finish()
    }
}
