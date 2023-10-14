//
//  ErrorView.swift
//  Music
//
//  Created by Rasmus Krämer on 08.09.23.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        ContentUnavailableView("Content unavailable", systemImage: "xmark.circle", description: Text("Please ensure that you are connected to the internet"))
    }
}

#Preview {
    ErrorView()
}
