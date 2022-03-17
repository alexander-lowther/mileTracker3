//
//  ContentView.swift
//  mileTracker3
//
//  Created by Alexander Lowther on 6/24/21.
//
import SwiftUI
import MapKit
import Combine
import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseFirestoreSwift
import CoreGraphics
import SSSwiftUIGIFView
struct TargetHit : View {
    @State var showAnimation = true
    var body: some View {
        if showAnimation {
            ZStack {
                SwiftUIGIFPlayerView(gifName: "boom").frame(width: 25, height: 25, alignment: .center)
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showAnimation = false
                }
            }
        }
    }
}
struct MySub: View {
    var body: some View {
        Image("submarine")
            .resizable()
            .scaledToFit()
            .frame(width: 45, height: 45, alignment: .center)
            //.foregroundColor(Color(hue: 0.2833, saturation: 0.1, brightness: 0.48))
    }
}
struct SubBlip: View, Identifiable {
    var id = UUID()
    let db = Firestore.firestore()
    @State var animate = false
    @State var color: Color
    @State var bPoint: CGPoint
    //used to be = CGP()
    @State var name: String?
    @State var didHit: Bool?
    @EnvironmentObject var me2: UserModel2
    var body: some View {
    ZStack {
        Circle()
            .fill(color.opacity(0.35))
            .frame(width: 50, height: 44, alignment: .center)
            .scaleEffect(self.animate ? 1 : 0)
            
        Circle()
            .fill(color.opacity(0.45))
            .frame(width: 25, height: 25, alignment: .center)
            .scaleEffect(self.animate ? 1 : 0)
        
        Circle()
            .fill(color.opacity(0.55))
            .frame(width: 12, height: 12, alignment: .center)
            .scaleEffect(self.animate ? 1 : 0)
            
    }
    .onAppear {
            self.animate.toggle()
        }
    .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
    }
}
struct Missile: View {
    var body: some View {
        Image(systemName: "airplane").foregroundColor(Color.gray)
    }
}
struct AnnotatedItem: View, Identifiable {
    let id = UUID()
    var name: String
    let db = Firestore.firestore()
    @State var coordinate: CLLocationCoordinate2D 
    var colr: Color
    var body: some View {
            Circle()
            .strokeBorder(self.colr, lineWidth: 4)
            .frame(width: 44, height: 44, alignment: .center)
    }
    
}

struct UserMainPage: View {
    //maybe have usermodel var of enemy closest to current user
let db = Firestore.firestore()
@ObservedObject private var locationManager = LocationManager()
//  @State private var region = MKCoordinateRegion.defaultRegion
@State private var cancellable: AnyCancellable?
@EnvironmentObject var me2: UserModel2
@State var launchReady = false
@State var myPosCG = CGPoint()
@State var enemyCGS = [CGPoint]()
@State var shoot = false
@State var enemyBlips = [SubBlip]()
@State var enemyCLLocs = [CLLocationCoordinate2D]()
@State var water = true
@State var degrees = ""
@State var didLaunch = false
@State var a = UIScreen.main.bounds.size.width * 0.5
@State var b = UIScreen.main.bounds.size.height * 0.5
@State var enemyPosCG = CGPoint()
@State var torpedoDistance = 0.0
@State var torpedoRange = 100.0
@State var didHit = false
@State var explosionCGCoord = CGPoint()
let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
@State var index = 0
@available(iOS 14.0, *)
var body: some View {
if locationManager.location != nil {
            ZStack {
               Map(coordinateRegion: $me2.pReg, interactionModes: .all, showsUserLocation: true, userTrackingMode: nil, annotationItems: me2.annptations, annotationContent: { loc in
                   MapAnnotation(coordinate: loc.coordinate, content: {
                            ZStack {
                                GeometryReader { geo in
                                    loc.position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        .onAppear {
                                            enemyPosCG.x = geo.frame(in: .global).midX
                                            enemyPosCG.y = geo.frame(in: .global).midY
                                            if(enemyPosCG.x != 0.0) {
                                                print(enemyPosCG)
                                                enemyCGS.append(enemyPosCG)
                                                enemyBlips.append(SubBlip(color: loc.colr, bPoint: enemyPosCG, name: loc.name))
                                                print("loca")
                                                print(enemyBlips.count)
                                            }
                                        }
                                }//geo reader
                            }//Zstack
                    }//mapann content
                    )//mapann
                })//map    .onAppear  .
                    .zIndex(0)
    .edgesIgnoringSafeArea(.all)
    .onAppear
    {
       // delay(secs: 3)
        setCurrentLocation()
    }
        ZStack {
         //   OverLays(blips: enemyBlips, myPoint: CGPoint(x: a, y: b))
            MySub()
            ForEach (enemyBlips) {
                blip in
                blip.position(x: blip.bPoint.x, y: blip.bPoint.y)
            }
                    if $shoot.wrappedValue {
                        //torpedoView
                        VStack {
                            Text("Choose the trajectory in degrees where north is zero")
                            TextField("0", text: $degrees)
                                .padding()
                                .keyboardType(.decimalPad)
                            Button(action: {
                                didLaunch.toggle()
                                shoot = false
                                launchReady = true
                                print(degrees)
                            }, label: {
                                Text("Launch")
                            })
                        }
                        .frame(width: 150, height: 200)
                        .background(Color.red)
                        .offset(y: 50)
                        .foregroundColor(Color.white)
                        //vstack
                    }//wrappedValue
            if launchReady {
                ZStack {
                GeometryReader { geo in
                    Missile()
                        .rotationEffect(.degrees(270.0 + Double(degrees)!))
                        .frame(width: 10, height: 10, alignment: .center)
                        .animation(Animation.linear(duration: 3).repeatCount(1, autoreverses: false))
                        .offset(x: CGFloat(a), y: CGFloat(b))
                        .onAppear {
                            myPosCG = CGPoint(x: CGFloat(a), y: CGFloat(b))
                            for blip in enemyBlips {
                                torpedoDistance = myPosCG.distanceToPoint(otherPoint: blip.bPoint)
                                let angle = myPosCG.angle(to: blip.bPoint)
                                print(angle)
                                //check if chosen angle is within 2 degrees
                                if(Double(degrees)! > angle - 2
                                    && Double(degrees)! < angle + 2
                                     && torpedoDistance < 100 ) {
                                    torpedoRange = torpedoDistance
                                    setHits(enemyEmail: blip.name!)
                                    print("we hit\(blip.name)")
                                    explosionCGCoord = blip.bPoint
                                    print(explosionCGCoord)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                                        didHit = true
                                    }
                                }
                            }
                            a += (sin(Double(degrees)! * 0.017)) * torpedoRange
                            b += -(cos(Double(degrees)! * 0.017)) * torpedoRange
                        }
                    }
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3
                    ) {
                            launchReady = false
                    }
                }
                //ifdidHit true then show hit animation
            }
            if didHit {
                    TargetHit().position(x: explosionCGCoord.x, y: explosionCGCoord.y)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(water ? Color(hue: 0.5833, saturation: 1, brightness: 0.66) : .clear)
        .edgesIgnoringSafeArea(.all)
            .onAppear {
                //  delay(secs: 4)
                print(enemyCGS.count)
        }
    HStack {
        Button(action: {
            water.toggle()
        }, label: {
            Text("test").bold()
        }).foregroundColor(Color.green)
        Button(action: {
            //shoot enemy
            shoot.toggle()
        }, label: {
            Text("Torpedo").bold()
        }).foregroundColor(Color.green)
    }.offset(x: -125, y: 400)
                CompassView().scaleEffect(0.5)
                    .offset(x: 100, y: 350)
            } .onReceive(timer, perform: { _ in
                updateAnnotations()
                index += 1
            })
        }
    }
    func updateAnnotations() {
            me2.annptations.removeAll()
            enemyBlips.removeAll()
        db.collectionGroup("users").getDocuments { (querySnapshot, error) in
                     if let querySnapshot = querySnapshot {
                         //querySnapshot
                         for document in querySnapshot.documents {
                             let e = document.get("email") as? String
                             let h = document.get("hits") as? Int
                             let geo = document.get("userLoca") as? GeoPoint
                             
                             if me2.userEmail != e! {
                                 var col = Color.green
                                 print("------hits-- \(h)")
                             if h == 0 {
                                 col = Color.green
                             } else if h == 1 {
                                 col = Color.orange
                             } else if h == 2 {
                                    col = Color.red
                             } else if h ?? 0 >= 3 {
                                 col = Color.black
                             }
                                 me2.annptations.append(AnnotatedItem(name: e!, coordinate: CLLocationCoordinate2D(latitude: geo!.latitude, longitude: geo!.longitude), colr: col))
                             }
                         }
                     }
        }
    }
    //funcion similiar to wait() for 1.5 seconds main thread
    func delay(secs: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
        }
    }
   func getDistance () -> String {
       return String (locationManager.traveledDistance)
   }
   func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
           let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
           let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
           return from.distance(from: to) * 0.000621371
       }
      func setCurrentLocation()  {
        cancellable = locationManager.$location.sink {
            location in me2.pReg = MKCoordinateRegion(center: location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: 50000, longitudinalMeters: 50000)
          //  location in region = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: 50000, longitudinalMeters: 50000)
       }
      }
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    func getAngleCLLDegrees(from:CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let dLon = (to.longitude - from.longitude);
        let y = sin(dLon) * cos(to.latitude);
        let x = cos(from.latitude) * sin(to.latitude) - sin(from.latitude)
        * cos(to.latitude) * cos(dLon);
        var brng = atan2(y, x);
        brng = rad2deg(brng);
        brng = (brng + 360).truncatingRemainder(dividingBy: 360)
        brng = 360 - brng; // count degrees counter-clockwise - remove to make clockwise
        return brng;
    }
    func getAngleScreenDeg(from: CGPoint, to: CGPoint) -> Double {
        let long = (to.y - from.y)
        let y = sin(long) * cos(to.x)
        let x = cos(from.x) * sin(to.x) - sin(from.x) * cos(to.x) * cos(long);
        var angle = atan2(y, x)
        return angle
    }
    //add one to enemies hits
    func setHits(enemyEmail: String) {
        db.collectionGroup("users").getDocuments { (querySnapshot, error) in
                 if let querySnapshot = querySnapshot {
                     //querySnapshot
                     for document in querySnapshot.documents {
                        // let fid = document.documentID
                      //   let id = document.documentID
                     //    let f = document.get("userLoca") as? GeoPoint
                         let e = document.get("email") as? String
                         let h = document.get("hits") as? Int
                         if enemyEmail == e! {
                             document.reference.updateData(
                                ["hits" : (h ?? 0) + 1])
                         }
                         print(h as Any)
                     }
                 }
          }
    }
}
class UserModel2: ObservableObject, Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
     let db = Firestore.firestore()
     var userID = Auth.auth().currentUser?.uid
     var userEmail: String?
     var userPassword: String?
     var enemiesLoc = [CLLocationCoordinate2D]()
     var myLoc: GeoPoint?
     var myLocCLL = CLLocationCoordinate2D()
     var coord = CLLocationCoordinate2D()
     var mkp = MKMapPoint ()
     var enemies = [UserModel2]()
//     var enemy = UserModel2()
     @Published var pReg = MKCoordinateRegion()
     @Published var annptations = [AnnotatedItem]()
     var hits: Int?
    var colorHex: String?
    private enum CodingKeys: String, CodingKey {
        case id
        case userID
        case myLoc = "userLoca"
        case userEmail = "email"
        case userPassword = "password"
        case hits = "hits"
        case colorHex = "color"
    }
    required init() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(userID!)
           docRef.getDocument { [self] (document, error) in
               if let document = document, document.exists {
                let property0 = document.get("email")
                let property1 = document.get("password")
                let property2 = document.get("userLoca")
                   self.myLoc = (property2 as? GeoPoint)
                   self.userEmail = (property0 as? String)!
                   self.userPassword = (property1 as? String)!
                
               } else {
                   print("Document does not exist")
               }
           }
        db.collectionGroup("users").getDocuments { [self] (querySnapshot, error) in
                 if let querySnapshot = querySnapshot {
                     //querySnapshot
                     for document in querySnapshot.documents {
                        // let fid = document.documentID
                         let id = document.documentID
                         let f = document.get("userLoca") as? GeoPoint
                         let e = document.get("email")
                         let h = document.get("hits") as? Int
                         let pass = document.get("password") as? String
                         self.enemiesLoc.append(CLLocationCoordinate2D(latitude: f!.latitude, longitude: f!.longitude))
                         coord.latitude = f!.latitude
                         coord.longitude = f!.longitude
                         if(id == userID) {
                             myLocCLL = coord
                         } else {
                             var color = Color.black
                         /*    if h == 0 {
                                 color = Color.green
                             } else if h == 1 {
                                 color = Color.orange
                             } else if h == 2 {
                                 color = Color.red
                             } else if h ?? 0 >= 3 {
                                 color = Color.black
                             }
                            annptations.append(AnnotatedItem(name: e as! String, coordinate: coord, color: color)) */
                         }
                         pReg = MKCoordinateRegion.init(center: myLocCLL, latitudinalMeters: 150000, longitudinalMeters: 150000)
                         mkp = MKMapPoint (myLocCLL);
                        
                     }
                 }
          }
    }
    func colorFromHex(hex: Int) -> Color {
    return Color(
    red: Double((hex & 0xFF0000) >> 16) / 255.0,
    green: Double((hex & 0x00FF00) >> 8) / 255.0,
    blue: Double(hex & 0x0000FF) / 255.0
    )}
}
/*
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} */
extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
struct ContentView: View {
    let db = Firestore.firestore()
    var userID = Auth.auth().currentUser?.uid
    @StateObject var me2 = UserModel2()
    @State var rerender = false
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @State var index = 0
    var body: some View {
        UserMainPage()//.environmentObject(me2)
  // Authen().environmentObject(me2)
           
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserModel2())
    }
}
/*  func setCurrentLocation()  {
    cancellable = locationManager.$location.sink {
      location in region = MKCoordinateRegion(center: location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: 50000, longitudinalMeters: 50000)
      //  location in region = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: 50000, longitudinalMeters: 50000)
      
   } */

extension CGPoint  {
    static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    static func angleBetweenThreePoints(center: CGPoint, firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
        let secondAnlge = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
        var angleDiff = firstAngle - secondAnlge
        
        if angleDiff < 0 {
            angleDiff *= -1
        }
        
        return angleDiff
    }
    
    func angleBetweenPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        return CGPoint.angleBetweenThreePoints(center: self, firstPoint: firstPoint, secondPoint: secondPoint)
    }
    
    func angleToPoint(pointOnCircle: CGPoint) -> CGFloat {
        
        let originX = pointOnCircle.x - self.x
        let originY = pointOnCircle.y - self.y
        var radians = atan2(originY, originX)
        
        while radians < 0 {
            radians += CGFloat(2 * Double.pi)
        }
        
        return radians
    }
    
    static func pointOnCircleAtArcDistance(center: CGPoint,
                                           point: CGPoint,
                                           radius: CGFloat,
                                           arcDistance: CGFloat,
                                           clockwise: Bool) -> CGPoint {
        
        var angle = center.angleToPoint(pointOnCircle: point);
        
        if clockwise {
            angle = angle + (arcDistance / radius)
        } else {
            angle = angle - (arcDistance / radius)
        }
        
        return self.pointOnCircle(center: center, radius: radius, angle: angle)
        
    }
    
    func distanceToPoint(otherPoint: CGPoint) -> CGFloat {
        return sqrt(pow((otherPoint.x - x), 2) + pow((otherPoint.y - y), 2))
    }
    
    static func CGPointRound(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: CoreGraphics.round(point.x), y: CoreGraphics.round(point.y))
    }
    func angleDouble(to comparisonPoint: CGPoint) -> Double {
          let originX = comparisonPoint.x - x
          let originY = comparisonPoint.y - y
          let bearingRadians = atan2f(Float(originY), Float(originX))
          var bearingDegrees = bearingRadians * 180 / .pi
          bearingDegrees += 90
          return Double(bearingDegrees)
    }
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
          let originX = comparisonPoint.x - x
          let originY = comparisonPoint.y - y
          let bearingRadians = atan2f(Float(originY), Float(originX))
          var bearingDegrees = CGFloat(bearingRadians) * 180 / .pi
          bearingDegrees += 90
          return bearingDegrees
    }
    
    static func intersectingPointsOfCircles(firstCenter: CGPoint, secondCenter: CGPoint, firstRadius: CGFloat, secondRadius: CGFloat ) -> (firstPoint: CGPoint?, secondPoint: CGPoint?) {
        
        let distance = firstCenter.distanceToPoint(otherPoint: secondCenter)
        let m = firstRadius + secondRadius
        var n = firstRadius - secondRadius
        
        if n < 0 {
            n = n * -1
        }
        
        //no intersection
        if distance > m {
            return (firstPoint: nil, secondPoint: nil)
        }
        
        //circle is inside other circle
        if distance < n {
            return (firstPoint: nil, secondPoint: nil)
        }
        
        //same circle
        if distance == 0 && firstRadius == secondRadius {
            return (firstPoint: nil, secondPoint: nil)
        }
        
        let a = ((firstRadius * firstRadius) - (secondRadius * secondRadius) + (distance * distance)) / (2 * distance)
        let h = sqrt(firstRadius * firstRadius - a * a)
        
        var p = CGPoint.zero
        p.x = firstCenter.x + (a / distance) * (secondCenter.x - firstCenter.x)
        p.y = firstCenter.y + (a / distance) * (secondCenter.y - firstCenter.y)
        
        //only one point intersecting
        if distance == firstRadius + secondRadius {
            return (firstPoint: p, secondPoint: nil)
        }
        
        var p1 = CGPoint.zero
        var p2 = CGPoint.zero
        
        p1.x = p.x + (h / distance) * (secondCenter.y - firstCenter.y)
        p1.y = p.y - (h / distance) * (secondCenter.x - firstCenter.x)
        
        p2.x = p.x - (h / distance) * (secondCenter.y - firstCenter.y)
        p2.y = p.y + (h / distance) * (secondCenter.x - firstCenter.x)
        
        //return both points
        return (firstPoint: p1, secondPoint: p2)
    }
}
struct Line: Shape {
    var start, end: CGPoint
    func path(in rect: CGRect) -> Path {
        let p =
        Path { p in
            p.move(to: start)
            p.addLine(to: end)
        }
        return p
    }
}
extension Line {
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
}
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
