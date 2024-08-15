//
//  TrackGrid.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 01.05.24.
//

import SwiftUI
import AmpFinKit
import AFPlayback

struct TrackGrid: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    let tracks: [Track]
    let container: Item?
    
    var amount = 2
    
    private var count: Int {
        horizontalSizeClass == .compact ? 1 : 2
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible(), spacing: 8)].repeated(count: min(tracks.count, amount)), spacing: 0) {
                ForEach(Array(tracks.enumerated()), id: \.element) { index, track in
                    TrackListRow(track: track) {
                        AudioPlayer.current.startPlayback(tracks: tracks, startIndex: index, shuffle: false, playbackInfo: .init(container: container))
                    }
                    .containerRelativeFrame(.horizontal) { length, _ in
                        let minimum = horizontalSizeClass == .compact ? 300 : 450.0
                        
                        let amount = CGFloat(Int(length / minimum))
                        let available = length - 12 * (amount - 1)
                        
                        return max(minimum, available / amount)
                    }
                    .padding(.trailing, 12)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
        .padding(.horizontal, 20)
    }
}

#Preview {
    TrackGrid(tracks: [
        .fixture,
        .fixture,
        .fixture,
        .fixture,
        .fixture,
        .fixture,
        .fixture,
    ], container: nil)
}
