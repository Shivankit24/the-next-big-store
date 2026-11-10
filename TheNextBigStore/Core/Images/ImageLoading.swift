//
//  ImageLoading.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import UIKit

/// Loads remote images. Features depend on this protocol so the loading and caching
/// strategy can change without touching any view.
nonisolated protocol ImageLoading: Sendable {
    /// The image if it is already in memory, so views can show it without a loading flash.
    nonisolated func cachedImage(for url: URL) -> UIImage?

    /// Returns the image for `url`, downloading it only if it is not already cached
    /// or being downloaded by another caller.
    func image(for url: URL) async throws -> UIImage
}
