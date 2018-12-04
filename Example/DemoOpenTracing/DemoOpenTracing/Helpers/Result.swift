//
//  Result.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation

enum Result<SuccessType> {
    case success(SuccessType)
    case failure(Error?)
}

struct EmptyResult {}
