//
//  Login.swift
//  mileTracker3
//
//  Created by Alexander Lowther on 3/11/22.
//
import Firebase
import FirebaseFirestoreSwift
import Foundation
import SwiftUI
struct Login: View {
    @State var signedIn = false
    @State  var name: String = ""
    @State var password: String = ""
    @State var balance: Double = 0.0
    @State var email: String = ""
    @State var color = Color.black.opacity(0.7)
    @State var pass = ""
    @State var visible = false
    @Binding var show : Bool
    @State var alert = false
    @State var error = ""
    @EnvironmentObject var me2: UserModel2
    let db = Firestore.firestore()
    var body: some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
            GeometryReader {_ in
                VStack {
                  //  Image("logo")
                    Text("log in to view your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 35)
                    TextField("Email", text: self.$email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.systemRed) : self.color, lineWidth: 2))
                        .padding(.top, 25)
                HStack(spacing: 15) {
                    VStack {
                        if self.visible {
                            TextField("Password", text: self.$pass)
                        } else {
                            SecureField("Password", text: self.$pass)
                        }
                    }
                    Button(action: {
                    }) {
                        //image here
                        Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(self.color)
                }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.systemRed) : self.color, lineWidth: 2))
                .padding(.top, 25)
                    HStack {
                        Spacer()
                        Button(action: {
                        }) {
                            Text("Forgot password")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 20)
                    Button(action: {
                        self.verify()
                    }) {
                        Text("Log in")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width - 50)
                    }
                    .background(Color(.red))
                    .cornerRadius(10)
                    .padding(.top, 25)
                }
                .padding(.horizontal, 25)
            }
            Button(action: {
                self.show.toggle()
            }) {
                Text("Sign up")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color(.red))
            }
            .padding()
        }
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    func verify() {
        if self.email != "" && self.pass != "" {
            Auth.auth().signIn(withEmail: self.email, password: self.pass) {(res, err) in
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                   // me.userEmail = email
                    return
                }
                print("success")
                let userID = Auth.auth().currentUser?.uid
                let docRef = db.collection("users").document(userID!)
         
                   docRef.getDocument { [self] (document, error) in
                       if let document = document, document.exists {
                        let property1 = document.get("email")
                        let property2 = document.get("password")
                        me2.userEmail = property1 as? String
                        me2.userPassword = property2 as? String
                         print("from db")
                         }   else {
                           print("Document does not exist")
                        
                 
                         me2.userEmail = self.email
                         me2.userPassword = self.pass
                  
                       }
                   }
                me2.userEmail = self.email
                me2.userPassword = self.pass
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        } else {
            self.error = "Please fill all contents"
            self.alert.toggle()
        }
    }
}
struct Authenticated: View {
    var body: some View {
        VStack {
            Text("Logged in")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
           Button(action: {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }) {
                Text("Start betting")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            Button(action: goHome) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Start betting").foregroundColor(Color.blue).bold()
                    Spacer()
                }
            }
            .background(Color(.red))
            .cornerRadius(10)
            .padding(.top, 25)
        }
    }
    public func goHome() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: UserMainPage())
            window.makeKeyAndVisible()
        }
    }
}
struct Authen: View {
    @State var signedIn = false
    @State var show = false
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @EnvironmentObject var me2: UserModel2
    var body: some View {
        NavigationView {
            VStack {
                    ZStack {
                        NavigationLink(
                            destination: SignUp(show: self.$show), isActive: self.$show) {
                            Text("")
                        }
                        .hidden()
                        Login(show: self.$show).environmentObject(me2)
                }
            }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("status"), object: nil, queue: .main) { (_) in
                self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                goHome()
            }
          }
        }
    }
    public func goHome() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: UserMainPage().environmentObject(me2))
            window.makeKeyAndVisible()
        }
    }
}
struct SignUp: View {
    let db = Firestore.firestore()
  //  let userID = Auth.auth().currentUser?.uid
    @State var password: String = ""
    @State var email: String = ""
    @State var balance: Double = 0.0
    @State var color = Color.black.opacity(0.7)
    @State var pass = ""
    @State var visible = false
    @State var repass = ""
    @State var revisible = false
    @Binding var show : Bool
    @State var alert = false
    @State var error = ""
    @EnvironmentObject var me2: UserModel2
    var body: some View{
            ZStack(alignment: .topLeading) {
            GeometryReader {_ in
                VStack {
                  //  Image("logo")
                    Text("Sign up with email")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 35)
                    
                    TextField("Email", text: self.$email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.systemRed) : self.color, lineWidth: 2))
                        .padding(.top, 25)
                    
                HStack(spacing: 15) {
                    VStack {
                        if self.visible {
                            TextField("Password", text: self.$pass)
                        }else {
                            SecureField("Password", text: self.$pass)
                        }
                    }
                    Button(action: {
                        self.visible.toggle()
                    }) {
                        //image here
                        Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(self.color)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.systemRed) : self.color, lineWidth: 2))
                .padding(.top, 25)
                    HStack(spacing: 15) {
                        VStack {
                            if self.revisible {
                                TextField("re-enter Password", text: self.$repass)
                            }else {
                                SecureField("re-enter Password", text: self.$repass)
                            }
                        }
                        Button(action: {
                            self.revisible.toggle()
                        }) {
                            //image here
                            Image(systemName: self.revisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(self.color)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.systemRed) : self.color, lineWidth: 2))
                    .padding(.top, 25)
                    Button(action: {
                        self.register()
                    }) {
                        Text("Sign up")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width - 50)
                    }
                    .background(Color(.red))
                    .cornerRadius(10)
                    .padding(.top, 25)
                }
                .padding(.horizontal, 25)
            }
            Button(action: {
                self.show.toggle()
            }) {
                    Image(systemName: "chevron.left")
                   .font(.title)
                   .foregroundColor(.red)
            }
            .padding()
            if self.alert {
                
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
        .navigationBarHidden(true)
    }
    func register(){
        if self.email != "" {
            if self.pass == self.repass {
                Auth.auth().createUser(withEmail: self.email, password: self.pass) {
                    (res, err) in
                    if err != nil {
                        self.error = err!.localizedDescription
                        self.alert.toggle()
                        return
                    }
                    print("success")
                    UserDefaults.standard.set(true, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                    let userID = Auth.auth().currentUser?.uid
                    let docRef = db.collection("users").document(userID!)
                    let betRef = db.collection("users")
                       docRef.getDocument { [self] (document, error) in
                           let document = document
                               betRef.document(userID!).setData([
                                "email" : self.email as Any? ?? "",
                                "password" : self.pass as Any? ?? "",
                                "userLoca" : nil
                                ?? 0,
                                "hits" : 0
                               ])
                           }
                       
                    }
            } else {
                    self.error = "incorrent password"
                    self.alert.toggle()
            }
                    } else {
                        self.error = "please fill all contents"
                        self.alert.toggle()
                    }
            }
    
}
struct ErrorView: View {
    @State var color = Color.black.opacity(0.7)
    @Binding var alert : Bool
    @Binding var error : String
    var body: some View {
        GeometryReader{_ in
            VStack {
                HStack {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 25)
                Text(self.error)
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    self.alert.toggle()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color(.white))
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(15)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/))
    }
}
