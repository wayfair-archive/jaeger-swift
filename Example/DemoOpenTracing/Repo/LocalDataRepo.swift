//
//  DataRepo.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation

typealias PuppyResult = (Result<[Puppy]>) -> Void
typealias PuppyDetailResult = (Result<PuppyDetail>) -> Void

protocol DataRepo: class {
    func getNewPuppies(numberOfPuppies number: Int, result: @escaping PuppyResult)
    func getDetail(forPuppyId id: UUID, result: @escaping PuppyDetailResult)
}

class LocalDataRepo: DataRepo {

    private let puppyName: [String] = ["Ace", "Bailey", "Bandit", "Baxter", "Boomer", "Brady", "Brody", "Buster", "Charlie",
                                       "Copper", "Diesel", "Finn", "Gizmo", "Gus", "Harley", "Jack", "Jake", "Jasper", "Joey", "Leo",
                                       "Lucky", "Mac", "Max", "Milo", "Oliver", "Oreo", "Otis", "Prince", "Rocky", "Roscoe", "Sammy",
                                       "Scout", "Spike", "Toby", "Vader", "Ziggy"]

    private let familyName: [String] = ["Smith", "Johnson", "Williams", "Jones", "Brown", "Miller", "Wilson", "Taylor", "Moore",
                                        "Anderson", "Thomas", "Harris", "Thompson", "Allen", "Scott", "Baker", "Carter", "Perez", "Turner", "Morris",
                                        "Sanchez", "Rivera", "Cooper", "Howard", "Jenkins", "Washington", "Russell", "Griffin", "Diaz", "Sanders", "Cox",
                                        "Hill", "Clark", "Lee", "King", "Murphy"]

    private static let story = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    func getNewPuppies(numberOfPuppies number: Int, result: @escaping PuppyResult) {

        guard number > 0 else {
            result(.failure(nil))
            return
        }

        let timeDelay = Double.random(in: 0.1 ..< 1)

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeDelay) { [weak self] in
            guard let strongSelf = self else {
                DispatchQueue.main.async { result(.failure(nil)) }
                return
            }

            var puppies: [Puppy] = []
            puppies.reserveCapacity(number)

            for _ in 0..<number {
                let name = strongSelf.puppyName.randomElement() ?? ""
                let familyName =  strongSelf.familyName.randomElement() ?? ""
                let id = UUID()
                let imageId = strongSelf.getImageId(fromPuppyId: id)
                let url = LocalDataRepo.getURL(forImageName: "puppy\(imageId)")
                let puppy = Puppy(name: name, familyName: familyName, imageURL: url, id: id)
                puppies.append(puppy)
            }

            DispatchQueue.main.async { result(.success(puppies)) }
        }
    }

    func getDetail(forPuppyId id: UUID, result: @escaping PuppyDetailResult) {
        let timeDelay = Double.random(in: 0.1 ..< 1)

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeDelay) { [weak self] in
            let imageId = self?.getImageId(fromPuppyId: id) ?? 1
            let url = LocalDataRepo.getURL(forImageName: "puppy\(imageId)")
            let detail = PuppyDetail(story: LocalDataRepo.story, imageURL: url, id: id)

            DispatchQueue.main.async { result(.success(detail)) }
        }
    }

    private static func getURL(forImageName name: String) -> URL {
        guard let url = URL(string: name) else { fatalError() }
        return url
    }

    private func getImageId(fromPuppyId id: UUID) -> UInt8 {
        return id.uuid.0 % 28 + 1
    }
}
