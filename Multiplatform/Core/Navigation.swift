//
//  NavigationRoot+Navigation.swift
//  iOS
//
//  Created by Rasmus Krämer on 21.11.23.
//

import Foundation

struct Navigation {
    static let navigateNotification = NSNotification.Name("io.rfk.ampfin.navigation")
    
    static let navigateAlbumNotification = NSNotification.Name("io.rfk.ampfin.navigation.album")
    static let navigateArtistNotification = NSNotification.Name("io.rfk.ampfin.navigation.artist")
    static let navigatePlaylistNotification = NSNotification.Name("io.rfk.ampfin.navigation.playlist")
}

extension Navigation {
    struct AlbumLoadDestination: Hashable {
        let albumId: String
    }
    
    struct ArtistLoadDestination: Hashable {
        let artistId: String
    }
    
    struct PlaylistLoadDestination: Hashable {
        let playlistId: String
    }
}
