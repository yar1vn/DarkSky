//
//  Result.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/10/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import Foundation

// This custom type is based on SE-0235:
// https://forums.swift.org/t/accepted-with-modifications-se-0235-add-result-to-the-standard-library/18603
enum Result<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)

    func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
