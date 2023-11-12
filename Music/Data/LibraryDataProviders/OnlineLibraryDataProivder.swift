//
//  OnlineLibraryDataProivder.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation

struct OnlineLibraryDataProvider: LibraryDataProvider {
    var supportsArtistLookup: Bool = true
    var supportsFavoritesLookup: Bool = true
    var supportsAdvancedFilters: Bool = true
    
    func getAllTracks(sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Track] {
        try await JellyfinClient.shared.getAllTracks(sortOrder: sortOrder, ascending: ascending)
    }
    func getFavoriteTracks(sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Track] {
        try await JellyfinClient.shared.getFavoriteTracks(sortOrder: sortOrder, ascending: ascending)
    }
    
    func getRecentAlbums() async throws -> [Album] {
        // this is a great place to sync playbacks (async)
        PlaybackReporter.syncPlaysToJellyfinServer()
        
        return try await JellyfinClient.shared.getAlbums(limit: 20, sortOrder: .added, ascending: false)
    }
    func getAlbumTracks(id: String) async throws -> [Track] {
        try await JellyfinClient.shared.getAlbumTracks(id: id)
    }
    func getAlbumById(_ albumId: String) async throws -> Album? {
        try await JellyfinClient.shared.getAlbumById(albumId)
    }
    func getAlbums(limit: Int, sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Album] {
        try await JellyfinClient.shared.getAlbums(limit: limit, sortOrder: sortOrder, ascending: ascending)
    }
    
    
    func getArtists(albumOnly: Bool) async throws -> [Artist] {
        try await JellyfinClient.shared.getArtists(albumOnly: albumOnly)
    }
    func getArtistById(_ artistId: String) async throws -> Artist? {
        try await JellyfinClient.shared.getArtistById(artistId)
    }
    func getArtistAlbums(id: String, sortOrder: JellyfinClient.ItemSortOrder, ascending: Bool) async throws -> [Album] {
        try await JellyfinClient.shared.getArtistAlbums(artistId: id, sortOrder: sortOrder, ascending: ascending)
    }
    
    func searchTracks(query: String) async throws -> [Track] {
        try await JellyfinClient.shared.searchTracks(query: query)
    }
    func searchAlbums(query: String) async throws -> [Album] {
        try await JellyfinClient.shared.searchAlbums(query: query)
    }
}
