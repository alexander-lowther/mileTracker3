//
//  mileTracker3App.swift
//  mileTracker3
//
//  Created by Alexander Lowther on 6/24/21.
//

import SwiftUI
import Firebase

@main
struct mileTracker3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    @State var index = 0
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserModel2())
        }
    }
}
