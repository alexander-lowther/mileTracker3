//
//  AppDelegate.swift
//  mileTracker3
//
//  Created by Alexander Lowther on 1/18/22.
//
import SwiftUI
import MapKit
import Combine
import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseFirestoreSwift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // print("Your code here")
        FirebaseApp.configure()
        return true
    }
}
