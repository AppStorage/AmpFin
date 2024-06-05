//
//  TrackListRow.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI
import AmpFinKit
import AFPlayback

struct TrackListRow: View {
    let track: Track
    var album: Album? = nil
    
    var disableMenu: Bool = false
    
    var deleteCallback: TrackList.DeleteCallback = nil
    let startPlayback: () -> ()
    
    @State private var playing: Bool? = nil
    @State private var addToPlaylistSheetPresented = false
    
    private var size: CGFloat {
        album == nil ? 48 : 24
    }
    private var showArtist: Bool {
        album == nil || !track.artists.elementsEqual(album!.artists) { $0.id == $1.id }
    }
    
    private var playbackIndicator: some View {
        Image(systemName: "waveform")
            .symbolEffect(.variableColor.iterative, isActive: playing ?? false)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                startPlayback()
            } label: {
                HStack(spacing: 0) {
                    Group {
                        if album != nil {
                            if playing == true {
                                playbackIndicator
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(String(track.index.index))
                                    .bold(track.favorite)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 4)
                            }
                        } else {
                            ItemImage(cover: track.cover)
                                .overlay {
                                    if playing == true {
                                        ZStack {
                                            Color.black.opacity(0.2)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                            
                                            playbackIndicator
                                                .font(.body)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                        }
                    }
                    .id(track.id)
                    .frame(width: size, height: size)
                    .padding(.trailing, 8)
                    .transition(.blurReplace)
                    
                    VStack(alignment: .leading) {
                        Text(track.name)
                            .lineLimit(1)
                            .font(.body)
                            .bold(track.favorite && album == nil)
                            .padding(.vertical, showArtist ? 0 : 6)
                        
                        if showArtist, let artistName = track.artistName {
                            Text(artistName)
                                .lineLimit(1)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer(minLength: 8)
                }
                .contentShape(.hoverMenuInteraction, Rectangle())
            }
            .buttonStyle(.plain)
            .hoverEffectDisabled()
            .onChange(of: AudioPlayer.current.playing, initial: true) {
                guard AudioPlayer.current.nowPlaying == track else {
                    playing = nil
                    return
                }
                
                playing = AudioPlayer.current.playing
            }
            
            DownloadIndicator(item: track)
            
            if !disableMenu {
                Menu {
                    TrackMenu(track: track, album: album, deleteCallback: deleteCallback, addToPlaylistSheetPresented: $addToPlaylistSheetPresented)
                } label: {
                    Label("more", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .font(.caption)
                        .imageScale(.large)
                        .foregroundStyle(Color(UIColor.label))
                        .padding(.vertical, 10)
                        .padding(.leading, 0)
                }
                .buttonStyle(.plain)
                .hoverEffect(.lift)
                .popoverTip(InstantMixTip())
            }
        }
        .padding(8)
        .contentShape([.hoverMenuInteraction, .dragPreview], .rect(cornerRadius: 12))
        .hoverEffect(.highlight)
        .draggable(track) {
            TrackPreview(track: track)
        }
        .contextMenu {
            TrackMenu(track: track, album: album, deleteCallback: deleteCallback, addToPlaylistSheetPresented: $addToPlaylistSheetPresented)
        } preview: {
            TrackPreview(track: track)
        }
        .padding(-8)
        .sheet(isPresented: $addToPlaylistSheetPresented) {
            PlaylistAddSheet(track: track)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            PlayNextButton(track: track)
        }
        .swipeActions(edge: .leading) {
            PlayLastButton(track: track)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            FavoriteButton(track: track)
        }
        .swipeActions(edge: .trailing) {
            AddToPlaylistButton(track: track, addToPlaylistSheetPresented: $addToPlaylistSheetPresented)
        }
    }
}

internal extension TrackListRow {
    struct TrackPreview: View {
        let track: Track
        
        var body: some View {
            HStack(spacing: 8) {
                ItemImage(cover: track.cover)
                    .frame(width: 44)
                
                VStack(alignment: .leading) {
                    Text(track.name)
                    
                    if let artistName = track.artistName {
                        Text(artistName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    struct TrackMenu: View {
        @Environment(\.libraryDataProvider) private var dataProvider
        
        let track: Track
        let album: Album?
        
        let deleteCallback: TrackList.DeleteCallback
        
        @Binding var addToPlaylistSheetPresented: Bool
        
        @State private var offlineTracker: ItemOfflineTracker?
        
        var body: some View {
            Button {
                AudioPlayer.current.startPlayback(tracks: [track], startIndex: 0, shuffle: false, playbackInfo: .init(container: nil))
            } label: {
                Label("play", systemImage: "play")
            }
            
            Button {
                Task {
                    try? await track.startInstantMix()
                }
            } label: {
                Label("queue.mix", systemImage: "compass.drawing")
            }
            .disabled(!JellyfinClient.shared.online)
            
            Divider()
            
            PlayNextButton(track: track)
            PlayLastButton(track: track)
            
            Divider()
            
            FavoriteButton(track: track)
            AddToPlaylistButton(track: track, addToPlaylistSheetPresented: $addToPlaylistSheetPresented)
            
            Divider()
            
            if album == nil {
                NavigationLink(value: .albumLoadDestination(albumId: track.album.id)) {
                    Label("album.view", systemImage: "square.stack")
                    
                    if let name = track.album.name {
                        Text(verbatim: name)
                    }
                }
            }
            
            if let artist = track.artists.first {
                NavigationLink(value: .artistLoadDestination(artistId: artist.id)) {
                    Label("artist.view", systemImage: "music.mic")
                }
                .disabled(!dataProvider.supportsArtistLookup)
            }
            
            if let deleteCallback = deleteCallback {
                Divider()
                
                Button(role: .destructive) {
                    deleteCallback(track)
                } label: {
                    Label("playlist.remove", systemImage: "trash.fill")
                }
            }
            
            Divider()
                .onAppear {
                    offlineTracker = track.offlineTracker
                }
            
            if let offlineTracker = offlineTracker, offlineTracker.status == .downloaded {
                Button {
                    try? OfflineManager.shared.update(trackId: track.id)
                } label: {
                    Label("download.update", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(!JellyfinClient.shared.online)
            }
        }
    }
}

private struct PlayNextButton: View {
    let track: Track
    
    var body: some View {
        Button {
            AudioPlayer.current.queueTrack(track, index: 0, playbackInfo: .init(container: nil, queueLocation: .next))
        } label: {
            Label("queue.next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        .tint(.orange)
    }
}
private struct PlayLastButton: View {
    let track: Track
    
    var body: some View {
        Button {
            AudioPlayer.current.queueTrack(track, index: AudioPlayer.current.queue.count, playbackInfo: .init(container: nil, queueLocation: .later))
        } label: {
            Label("queue.last", systemImage: "text.line.last.and.arrowtriangle.forward")
        }
        .tint(.blue)
    }
}

private struct FavoriteButton: View {
    let track: Track
    
    var body: some View {
        Button {
            track.favorite.toggle()
        } label: {
            Label("favorite", systemImage: track.favorite ? "star.slash" : "star")
        }
        .tint(.orange)
    }
}

private struct AddToPlaylistButton: View {
    let track: Track
    @Binding var addToPlaylistSheetPresented: Bool
    
    var body: some View {
        Button {
            addToPlaylistSheetPresented.toggle()
        } label: {
            Label("playlist.add", systemImage: "plus")
        }
        .disabled(!JellyfinClient.shared.online)
        .tint(.green)
    }
}

internal extension TrackListRow {
    static let placeholder: some View = TrackListRow(
        track: .init(
            id: "placeholder",
            name: "Placeholder",
            cover: nil,
            favorite: false,
            album: .init(id: "placeholder", name: "Placerholder", artists: []),
            artists: [],
            lufs: nil,
            index: .init(index: 0, disk: 0),
            runtime: 0,
            playCount: 0,
            releaseDate: nil),
        album: nil,
        disableMenu: true,
        deleteCallback: nil,
        startPlayback: {})
    .redacted(reason: .placeholder)
}

#Preview {
    TrackListRow.placeholder
}
