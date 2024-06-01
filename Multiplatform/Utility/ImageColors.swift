//
//  ImageColors.swift
//  iOS
//
//  Created by Rasmus Krämer on 02.01.24.
//

import Foundation
import SwiftUI
import UIImageColors
import AmpFinKit

@Observable
internal class ImageColors {
    var background: Color
    var primary: Color
    var secondary: Color
    var detail: Color
    var isLight: Bool
    
    init() {
        background = .gray.opacity(0.1)
        primary = .gray.opacity(0.75)
        secondary = .primary.opacity(0.6)
        detail = .primary
        
        isLight = UITraitCollection.current.userInterfaceStyle == .light
    }
}

extension ImageColors {
    internal func update(cover: Cover?) async {
        await self.extractColors(cover: cover)
    }
    
    internal func update(saturation: CGFloat, luminance: CGFloat) {
        background = Self.update(color: background, saturation: saturation, luminance: luminance)
        primary = Self.update(color: primary, saturation: saturation, luminance: luminance)
        secondary = Self.update(color: secondary, saturation: saturation, luminance: luminance)
        detail = Self.update(color: detail, saturation: saturation, luminance: luminance)
    }
    
    private static func update(color: Color, saturation: CGFloat, luminance: CGFloat) -> Color {
        var hue: CGFloat = .zero
        var saturation: CGFloat = .zero
        var brightness: CGFloat = .zero
        var alpha: CGFloat = .zero
        
        UIColor(color).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: hue, saturation: max(saturation, saturation), brightness: min(brightness, luminance), opacity: alpha)
    }
    
    private func extractColors(cover: Cover?) async {
        guard let cover = cover, let data = try? Data(contentsOf: cover.url), let image = UIImage(data: data), let colors = image.getColors(quality: .high) else {
            return
        }
        
        guard !Task.isCancelled else {
            return
        }
        
        withAnimation(.spring) {
            self.background = Color(colors.background)
            self.primary = Color(colors.primary)
            self.secondary = Color(colors.secondary)
            self.detail = Color(colors.detail)
            self.isLight = self.background.isLight()
        }
    }
}
