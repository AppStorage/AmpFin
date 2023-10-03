//
//  ContentView.swift
//  Music
//
//  Created by Rasmus Krämer on 05.09.23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var isAuthorized = JellyfinClient.shared.isAuthorized
    
    var body: some View {
        if isAuthorized {
            NavigationRoot()
                .onAppear {
                    SpotlightDonator.donate()
                    UserContext.updateContext()
                }
        } else {
            LoginView() {
                isAuthorized = true
            }
        }
    }
}

#Preview {
    ContentView()
}
