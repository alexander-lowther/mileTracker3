//
//  LocationManager.swift
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
class LocationManager: NSObject, ObservableObject {
    let userID = Auth.auth().currentUser?.uid
    @IBOutlet weak var mapView: MKMapView!
      var startLocation: CLLocation!
      var lastLocation: CLLocation!
    var defaultRegion = MKCoordinateRegion()
     @EnvironmentObject var me2: UserModel2
      var startDate: Date!
      var traveledDistance: Double = 0
        @State var locationManager = CLLocationManager()
        @Published var location: CLLocation?
        override init() {
            super.init()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            
        }
    }
extension LocationManager: CLLocationManagerDelegate {
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let location = locations.last
     //   print("Traveled Distance:",  traveledDistance)
           DispatchQueue.main.async {
                self.location = location
            }
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
                * 0.000621371
          //  print("Traveled Distance:",  traveledDistance)
         //   print("Straight Distance:", startLocation.distance(from: locations.last!))
        }
           lastLocation = locations.last
          let db = Firestore.firestore()
          let userID = Auth.auth().currentUser?.uid
        db.collection("users").document(userID!)
               .updateData(["userLoca": GeoPoint(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude),
                        ])
       }
}
extension MKCoordinateRegion {
    static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 41.33, longitude: -95.393), latitudinalMeters: 100, longitudinalMeters: 100)
    }
    
}


