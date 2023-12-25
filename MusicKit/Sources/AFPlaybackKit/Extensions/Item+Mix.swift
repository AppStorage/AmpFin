//
//  File.swift
//  
//
//  Created by Rasmus Krämer on 24.12.23.
//

import Foundation
import AFBaseKit
import AFApiKit

extension Item {
    public func startInstantMix() async throws {
        let tracks = try await JellyfinClient.shared.getTracks(instantMixBaseId: id)
        AudioPlayer.current.startPlayback(tracks: tracks, startIndex: 0, shuffle: false)
    }
}
