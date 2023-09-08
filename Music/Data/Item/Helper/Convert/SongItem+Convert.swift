//
//  SongItem+Convert.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation

extension SongItem {
    static func convertFromJellyfin(_ item: JellyfinClient.JellyfinSongItem, fallbackIndex: Int = 0) -> SongItem {
        let album = SongItem.Album(
            id: item.AlbumId,
            name: item.Album,
            artists: item.AlbumArtists.map {
                ItemArtist(id: $0.Id, name: $0.Name)
            })
        
        return SongItem(
            id: item.Id,
            name: item.Name,
            cover: ItemCover.convertFromJellyfin(imageTags: item.ImageTags, id: item.Id),
            index: SongItem.Index(index: item.IndexNumber ?? fallbackIndex, disk: item.ParentIndexNumber ?? 1),
            playCount: item.UserData.PlayCount,
            lufs: item.LUFS,
            releaseDate: Date.parseDate(item.PremiereDate),
            album: album,
            artists: item.ArtistItems.map {
                ItemArtist(id: $0.Id, name: $0.Name)
            },
            downloaded: false,
            favorite: item.UserData.IsFavorite)
    }
}
