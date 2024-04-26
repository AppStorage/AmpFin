//
//  SearchView.swift
//  Music
//
//  Created by Rasmus Krämer on 09.09.23.
//

import SwiftUI
import AFBase
import AFPlayback

struct SearchView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var query = ""
    @State private var task: Task<(), Never>? = nil
    
    @State private var tracks = [Track]()
    @State private var albums = [Album]()
    @State private var artists = [Artist]()
    @State private var playlists = [Playlist]()
    
    @State private var library: Tab = UserDefaults.standard.bool(forKey: "searchOnline") ? .online : .offline
    @State private var dataProvider: LibraryDataProvider = UserDefaults.standard.bool(forKey: "searchOnline") ? OnlineLibraryDataProvider() : OfflineLibraryDataProvider()
    
    var body: some View {
        NavigationStack {
            List {
                ProviderPicker(selection: $library)
                
                if !artists.isEmpty {
                    Section("section.artists") {
                        ForEach(artists) { artist in
                            ArtistListRow(artist: artist)
                                .listRowInsets(.init(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                    }
                }
                
                if !albums.isEmpty {
                    Section("section.albums") {
                        ForEach(albums) { album in
                            NavigationLink(destination: AlbumView(album: album)) {
                                AlbumListRow(album: album)
                            }
                            .listRowInsets(.init(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                    }
                }
                
                if !playlists.isEmpty {
                    Section("section.playlists") {
                        ForEach(playlists) { playlist in
                            NavigationLink(destination: PlaylistView(playlist: playlist)) {
                                PlaylistListRow(playlist: playlist)
                            }
                            .listRowInsets(.init(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                    }
                }
                
                if !tracks.isEmpty {
                    Section("section.tracks") {
                        ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
                            TrackListRow(track: track) {
                                AudioPlayer.current.startPlayback(tracks: tracks, startIndex: index, shuffle: false, playbackInfo: .init(container: nil, search: query))
                            }
                            .listRowInsets(.init(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("title.search")
            .modifier(NowPlayingBarSafeAreaModifier())
            .modifier(AccountToolbarButtonModifier(requiredSize: .compact))
            // Query
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "search.placeholder")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: query) {
                fetchSearchResults()
            }
            // Online / Offline
            .onChange(of: library) {
                UserDefaults.standard.set(library == .online, forKey: "searchOnline")
                
                task?.cancel()
                
                tracks = []
                albums = []
                artists = []
                playlists = []
                
                switch library {
                case .online:
                    dataProvider = OnlineLibraryDataProvider()
                case .offline:
                    dataProvider = OfflineLibraryDataProvider()
                }
                
                fetchSearchResults()
            }
            .onAppear(perform: fetchSearchResults)
        }
        .environment(\.libraryDataProvider, dataProvider)
    }
}

extension SearchView {
    private func fetchSearchResults() {
        task?.cancel()
        task = Task.detached {
            // I guess this runs in parallel?
            (tracks, albums, artists, playlists) = (try? await (
                dataProvider.searchTracks(query: query.lowercased()),
                dataProvider.searchAlbums(query: query.lowercased()),
                dataProvider.searchArtists(query: query.lowercased()),
                dataProvider.searchPlaylists(query: query.lowercased())
            )) ?? ([], [], [], [])
        }
    }
}

#Preview {
    SearchView()
}
