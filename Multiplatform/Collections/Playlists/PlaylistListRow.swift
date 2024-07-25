//
//  PlaylistListRow.swift
//  iOS
//
//  Created by Rasmus Krämer on 01.01.24.
//

import SwiftUI
import AmpFinKit
import AFPlayback

struct PlaylistListRow: View {
    let playlist: Playlist
    
    @State private var offlineTracker: ItemOfflineTracker?
    
    var body: some View {
        HStack(spacing: 0) {
            ItemImage(cover: playlist.cover)
                .frame(width: 60)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(playlist.name)
                Text("playlist.trackCount \(playlist.trackCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .dropDestination(for: Track.self) { tracks, _ in
            Task {
                try await playlist.add(trackIds: tracks.map { $0.id })
            }
            
            return true
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            QueueNextButton {
                Task {
                    AudioPlayer.current.queueTracks(try await JellyfinClient.shared.tracks(playlistId: playlist.id), index: 0, playbackInfo: .init(container: playlist, queueLocation: .next))
                }
            }
            .tint(.orange)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            QueueLaterButton(forceDisplay: true) {
                Task {
                    AudioPlayer.current.queueTracks(try await JellyfinClient.shared.tracks(playlistId: playlist.id), index: AudioPlayer.current.queue.count, playbackInfo: .init(container: playlist, queueLocation: .later))
                }
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            if let offlineTracker {
                Button {
                    if offlineTracker.status == .none {
                        Task {
                            try! await OfflineManager.shared.download(playlist: playlist)
                        }
                    } else if offlineTracker.status == .downloaded {
                        try! OfflineManager.shared.delete(playlistId: playlist.id)
                    }
                } label: {
                    switch offlineTracker.status {
                        case .none:
                            Label("download", systemImage: "arrow.down")
                                .tint(.green)
                        case .working:
                            ProgressView()
                        case .downloaded:
                            Label("download.remove", systemImage: "xmark")
                                .tint(.red)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                playlist.favorite.toggle()
            } label: {
                Label("favorite", systemImage: playlist.favorite ? "star.slash" : "star")
                    .tint(.orange)
            }
        }
        .task {
            offlineTracker = playlist.offlineTracker
        }
    }
}
