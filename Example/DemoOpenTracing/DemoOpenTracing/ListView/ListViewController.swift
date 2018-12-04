//
//  ViewController.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    private enum Row: Hashable {
        case loading
        case puppy(model: ListViewModel.PuppyModel)
    }

    @IBOutlet weak var tableView: UITableView!

    private var rows: [Row] = []
    private var lateInitPresenter: ListViewPresentable?

    private var presenter: ListViewPresentable {
        guard let presenter = lateInitPresenter else { fatalError() }
        return presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        presenter.viewLoaded()
    }

    func set(presenter: ListViewPresentable) {
        lateInitPresenter = presenter
    }

    func show(error: String) {
        UIViewController.showError(forController: self, message: error)
    }

    func addNew(puppies: [ListViewModel.PuppyModel], fromAction span: WrapSpan?) {
        let createAndAddRowSpan = presenter.tracer.startSpan(callerType: ListViewController.self, childOf: span)
        createAndAddRowSpan.addOnMainThreadTag()
        addNew(puppies: puppies)
        createAndAddRowSpan.finish()
    }

    private func addNew(puppies: [ListViewModel.PuppyModel]) {
        self.tableView.performBatchUpdates({

            if self.rows.last == Row.loading {
                self.tableView.deleteRows(at: [IndexPath(row: self.rows.count - 1, section: 0)], with: .automatic)
                self.rows.removeLast()
            }

            let newRows: [Row] = puppies.map { return Row.puppy(model: $0) }

            let startCount = self.rows.count
            self.rows.append(contentsOf: newRows)
            self.rows.append(.loading)

            let indexes = startCount ..< self.rows.count
            let rows = indexes.map { return IndexPath(row: $0, section: 0) }

            self.tableView.insertRows(at: rows, with: .automatic)

        }, completion: nil)
    }

    private func height(forRow row: Row) -> CGFloat {
        switch row {
        case .loading:
            return 44
        case .puppy:
            return 70
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.rows[indexPath.row]

        switch row {
        case .loading:
            presenter.loadNewPuppies()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as? LoadingCell else { fatalError() }
            cell.config()
            return cell
        case .puppy(let puppyModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "puppyCell") as? PuppyCell else { fatalError() }
            cell.change(model: puppyModel, downloader: presenter.downloader, tracer: presenter.tracer)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.rows[indexPath.row]

        switch row {
        case .loading: return
        case .puppy(let puppyModel): presenter.selected(puppyId: puppyModel.id)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.rows[indexPath.row]
        return height(forRow: row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.rows[indexPath.row]
        return height(forRow: row)
    }
}
