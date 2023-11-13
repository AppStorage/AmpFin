//
//  AlbumTab.swift
//  watchOS
//
//  Created by Rasmus Krämer on 13.11.23.
//

import SwiftUI
import MusicKit
import TipKit

struct AlbumTab: View {
    let album: Album
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Button {
                // this is so incredibly stupid
            } label: {
                VStack {
                    ItemImage(cover: album.cover)
                    
                    VStack {
                        Text(album.name)
                            .font(.caption)
                        Text(album.artists.map { $0.name }.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    .multilineTextAlignment(.center)
                    .ignoresSafeArea(edges: .bottom)
                    .containerBackground(.accent.gradient, for: .tabView)
                }
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture()
                .onEnded { _ in
                    startPlayback(shuffle: false)
                })
            .simultaneousGesture(LongPressGesture()
                .onEnded { _ in
                    startPlayback(shuffle: true)
                })
            
            /*
            TipView(ShuffleTip())
                .padding()
             */
        }
    }
}

// MARK: playback

extension AlbumTab {
    private func startPlayback(shuffle: Bool) {
        Task {
            if let tracks = try? await JellyfinClient.shared.getAlbumTracks(id: album.id) {
                AudioPlayer.shared.startPlayback(tracks: tracks, startIndex: 0, shuffle: shuffle)
            }
        }
    }
}

#Preview {
    TabView {
        AlbumTab(album: Album.fixture)
    }
    .tabViewStyle(.verticalPage)
}
