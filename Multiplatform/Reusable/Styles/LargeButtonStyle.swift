//
//  LargeButtonStyle.swift
//  Music
//
//  Created by Rasmus Krämer on 05.09.23.
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 45)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .font(.headline)
            .cornerRadius(7)
    }
}

#Preview {
    Button {
        
    } label: {
        Label(String("Command :)"), systemImage: "command")
    }
    .buttonStyle(LargeButtonStyle())
}
