//
//  Theme.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Layout tokens (spacing, corner radii). The look and feel will change as the creative
/// work lands, so views use these instead of hard-coded numbers and a restyle is one edit.
nonisolated enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
    }

    enum Radius {
        static let card: CGFloat = 16
    }
}
