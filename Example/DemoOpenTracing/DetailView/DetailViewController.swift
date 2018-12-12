//
//  DetailViewController.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/26/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private var imagePuppy: RoundImageView!
    @IBOutlet private var loadingSection: UIView!
    @IBOutlet private var storyText: UILabel!
    @IBOutlet private var buttonDismiss: UIButton!
    @IBOutlet var navBar: UIVisualEffectView!
    @IBOutlet var scrollView: UIScrollView!

    private var viewAppeared = false
    private var lateInitVM: DetailViewModelable?

    private var viewModel: DetailViewModelable {
        guard let vm = lateInitVM else { fatalError() }
        return vm
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        buttonDismiss.alpha = 0
        hideNavBar(status: true, animated: false)
        viewModel.viewLoaded()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard viewAppeared == false else { return }
        viewAppeared = true
        popDismiss()
    }

    func set(vm: DetailViewModelable) {
        lateInitVM = vm
    }

    func updateUI(fromAction span: WrapSpan?) {
        showLoading(status: !viewModel.model.isLoading)
        change(info: viewModel.model.detailInfo)

        if let url = viewModel.model.imageURL {
            changeImage(url: url, fromAction: span)
        }
    }

    private func changeImage(url: URL, fromAction span: WrapSpan?) {
        let imageSpan = viewModel.tracer.startSpan(callerType: DetailViewController.self, followsFrom: span)

        viewModel.downloader.getImage(at: url) { [weak self] result in
            imageSpan.finish()

            guard let strongSelf = self else { return }
            switch result {
            case .success(let image):
                strongSelf.change(image: image)
            case .failure: break
            }
        }
    }

    func change(info: String?) {
        UIView.transition(with: storyText, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.storyText.text = info
        }, completion: nil)
    }

    func change(image: UIImage) {
        UIView.transition(with: imagePuppy, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.imagePuppy.image = image
        }, completion: nil)
    }

    func hideNavBar(status: Bool, animated: Bool) {
        let hasEffect = navBar.effect != nil
        guard hasEffect == status else {
            return
        }

        let time: Double =  animated ? 0.2 : 0
        let effect: UIVisualEffect? = status ? nil : UIBlurEffect(style: .light)
        UIView.animate(withDuration: time) {
            self.navBar.effect = effect
        }
    }

    func popDismiss() {
        buttonDismiss.alpha = 0
        buttonDismiss.transform = .init(scaleX: 0.3, y: 0.3)

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: [],
                       animations: {

            self.buttonDismiss.alpha = 1
            self.buttonDismiss.transform = .identity

        }, completion: nil)
    }

    private func showLoading(status: Bool) {
        guard status != loadingSection.isHidden else {
            return
        }

        UIView.animate(withDuration: 0.2) {
            self.loadingSection.isHidden = status
        }
    }

    func show(error: String) {
        UIViewController.showError(forController: self, message: error)
    }

    @IBAction func onDismiss(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let hideNav = scrollView.contentOffset.y < 200
        hideNavBar(status: hideNav, animated: true)
    }
}
