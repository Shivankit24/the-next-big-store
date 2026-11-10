//
//  LoadState.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Loading lifecycle of a screen's data, shared by all view models.
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

extension LoadState: Equatable where Value: Equatable {}
