//
//  AppDelegate.swift
//  Music
//
//  Created by Rasmus Krämer on 21.09.23.
//

import UIKit
import Intents

class AppDelegate: NSObject, UIApplicationDelegate {
    private var backgroundCompletionHandler: (() -> Void)? = nil
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Task { @MainActor in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler else {
                return
            }
            
            backgroundCompletionHandler()
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("a")
        return true
    }
    
    func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
        print("b")
    }
    
    // I would love to put this in an app extension, but it does not fucking work... This is s incredibly stupid, i think i lose some IQ points over this
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        print("c")
        
        switch intent {
        case is INPlayMediaIntent:
            return PlayMediaHandler()
        default:
            return nil
        }
    }
}
