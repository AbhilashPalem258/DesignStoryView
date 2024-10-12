//
//  Optional+Extensions.swift
//  DesignStoryView
//
//  Created by Abhilash Palem on 08/10/24.
//

import Foundation

extension Optional {
    var isNil: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
}
