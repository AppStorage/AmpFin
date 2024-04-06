//
//  AlbumHeader.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI
import UIImageColors
import AFBase

extension AlbumView {
    struct Header: View {
        let album: Album
        
        @Binding var toolbarBackgroundVisible: Bool
        @Binding var imageColors: ImageColors
        
        let startPlayback: (_ shuffle: Bool) -> ()
        
        var body: some View {
            ZStack(alignment: .top) {
                GeometryReader { reader in
                    let offset = reader.frame(in: .global).minY
                    
                    if offset > 0 {
                        Rectangle()
                            .foregroundStyle(imageColors.background)
                            .offset(y: -offset)
                            .frame(height: offset)
                    }
                    
                    Color.clear
                        .onChange(of: offset) {
                            withAnimation {
                                toolbarBackgroundVisible = offset < -350
                            }
                        }
                }
                .frame(height: 0)
                
                ViewThatFits(in: .horizontal) {
                    // HStack for iPad
                    HStack {
                        ItemImage(cover: album.cover)
                            .shadow(color: .black.opacity(0.25), radius: 20)
                            .frame(width: 275)
                            .padding()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Spacer()
                            Text(album.name)
                                .padding(.top)
                                .lineLimit(1)
                                .font(.title)
                                .bold()
                                .foregroundStyle(imageColors.isLight ? .black : .white)
                            
                            // fuck navigation links
                            if album.artists.count > 0 {
                                HStack {
                                    Text(album.artistName)
                                        .lineLimit(1)
                                        .font(.title2)
                                        .foregroundStyle(imageColors.detail)
                                }
                            }
                            
                            HStack {
                                if let releaseDate = album.releaseDate {
                                    Text(releaseDate, format: Date.FormatStyle().year())
                                }
                                
                                Text(album.genres.joined(separator: String(localized: "genres.separator")))
                                    .lineLimit(1)
                            }
                            .font(.caption)
                            .foregroundStyle(imageColors.isLight ? Color.black.tertiary : Color.white.tertiary)
                            .padding(.bottom)
                            
                            Spacer()
                            
                            HStack {
                                Group {
                                    Label("queue.play", systemImage: "play.fill")
                                        .frame(maxWidth: .infinity)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            startPlayback(false)
                                        }
                                    Label("queue.shuffle", systemImage: "shuffle")
                                        .frame(maxWidth: .infinity)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            startPlayback(true)
                                        }
                                }
                                .padding(.vertical, 12)
                                .foregroundColor(imageColors.secondary)
                                .background(imageColors.primary.opacity(0.25))
                                .bold()
                                .cornerRadius(7)
                            }
                            .padding()
                        }
                    }
                    // VStack for iPhone
                    VStack {
                        ItemImage(cover: album.cover)
                            .shadow(color: .black.opacity(0.25), radius: 20)
                            .frame(width: 275)
                        
                        Text(album.name)
                            .padding(.top)
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundStyle(imageColors.isLight ? .black : .white)
                        
                        // fuck navigation links
                        if album.artists.count > 0 {
                            HStack {
                                Text(album.artistName)
                                    .lineLimit(1)
                                    .font(.callout)
                                    .foregroundStyle(imageColors.detail)
                            }
                        }
                        
                        HStack {
                            if let releaseDate = album.releaseDate {
                                Text(releaseDate, format: Date.FormatStyle().year())
                            }
                            
                            Text(album.genres.joined(separator: String(localized: "genres.separator")))
                                .lineLimit(1)
                        }
                        .font(.caption)
                        .foregroundStyle(imageColors.isLight ? Color.black.tertiary : Color.white.tertiary)
                        .padding(.bottom)
                        
                        HStack {
                            Group {
                                // why not buttons? because swiftui does not like having mulitpe buttons in the same row in a VStack
                                // Doing so will trigger the button randomly and not the one you clicking.
                                // Have to use Label as a workaround
                                Label("queue.play", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        startPlayback(false)
                                    }
                                Label("queue.shuffle", systemImage: "shuffle")
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        startPlayback(true)
                                    }
                            }
                            .padding(.vertical, 12)
                            .foregroundColor(imageColors.secondary)
                            .background(imageColors.primary.opacity(0.25))
                            .bold()
                            .cornerRadius(7)
                        }
                    }
                }
                .padding(.top, 100)
                .padding(.bottom)
                .padding(.horizontal)
            }
            .background(imageColors.background)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
