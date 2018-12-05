//
//  ListViewInteractor.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation

class ListViewInteractor {

    let repo: DataRepo

    init(repo: DataRepo) {
        self.repo = repo
    }

    func getNewPuppies(result: @escaping PuppyResult) {
        repo.getNewPuppies(numberOfPuppies: 15) { value in
            result(value)
        }
    }
}
