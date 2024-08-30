//
//  ErrorView.swift
//  Music
//
//  Created by Rasmus Krämer on 08.09.23.
//

import SwiftUI

internal struct ErrorView: View {
    var body: some View {
        ScrollView {
            ZStack {
                Spacer()
                    .containerRelativeFrame([.horizontal, .vertical])
                
                ContentUnavailableView("error.unavailable.title", systemImage: "xmark.circle", description: Text("error.unavailable.text"))
            }
        }
    }
}

#Preview {
    ErrorView()
}
