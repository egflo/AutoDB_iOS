//
//  UserView.swift
//  AutoDB
//
import SwiftUI
import Auth0


struct ProfileHeader: View {
    var picture: String

    private let size: CGFloat = 100

    var body: some View {
    #if os(iOS)
        AsyncImage(url: URL(string: picture), content: { image in
            image.resizable()
        }, placeholder: {
            //Color.grey
        })
        .frame(width: self.size, height: self.size)
        .clipShape(Circle())
        .padding(.bottom, 24)
    #else
        Text("Profile")
    #endif
    }
}

struct ProfileCell: View {
    var key: String
    var value: String

    private let size: CGFloat = 14

    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: self.size, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(size: self.size, weight: .regular))
            #if os(iOS)
                .foregroundColor(.gray)
            #endif
        }
    //#if os(iOS)
        //.listRowBackground(.red)

    //#endif
    }
}

struct UserView: View {
    @EnvironmentObject var meta: Meta
    
    @Binding var selectTab: Int
    @State var user: User?

    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    var body: some View {
        
        VStack {
            
            if credentialsManager.hasValid() {
                VStack {
                    
                    if let user = self.user {
                        
                        List {
                            Section(header: ProfileHeader(picture: user.picture)) {
                                ProfileCell(key: "ID", value: user.id)
                                ProfileCell(key: "Name", value: user.name)
                                ProfileCell(key: "Email", value: user.email)
                                ProfileCell(key: "Email verified?", value: user.emailVerified)
                                ProfileCell(key: "Updated at", value: user.updatedAt)
                            }                            
    
                                
                            Button("Logout") {
                                logout()
                            }
                            .buttonStyle(CustomButton())
      
                        }
                    }
                    
                    else {
                        
                        ProgressView()
                    
                    }
                }
                
            }
            
            else {
                
                VStack {
                    Text("Login to save and view your profile.")
                    
                    Button("Login") {
                        login()
                    }
                    .buttonStyle(CustomButton())
                }


            }
            
        }
        .onAppear(perform: {
            self.getUser()
        })
        .navigationTitle("Account")
        
    }
}

extension UserView {
    func getUser() {
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        guard credentialsManager.hasValid() else {
            // No renewable credentials exist, present the login page
            //return login()
            
            return
        }
        
        // Retrieve the stored credentials
    
        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                print("Obtained credentials: \(credentials)")
                self.user = User(from: credentials.idToken)
                
            case .failure(let error):
                print("Failed with: \(error)")
            }
        }

    }
    
    func login() {
        Auth0
            .webAuth()
            .audience("https://carvo/api")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    print(credentials)
                    
                    self.user = User(from: credentials.idToken)
                    
                    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
                    let isCredentialsStored = credentialsManager.store(credentials: credentials)
                    
                    if isCredentialsStored {
                      print("Credentials saved: \(credentials.debugDescription)")
                      
                      let isValid = credentialsManager.hasValid()
                      if isValid {
                        print("Valid!")
                      } else {
                        print("Invalid!")
                      }
                      
                    }
                    
                    credentialsManager.credentials { result in
                        switch result {
                        case .success(let credentials):
                            print("Obtained credentials: \(credentials)")
                        case .failure(let error):
                            print("Failed with: \(error)")
                        }
                    }
                    
                    meta.isAuthenticated = true

                    
                case .failure(let error):
                    print("Failed with: \(error)")
                }
                
            }
        
    }

    func logout() {
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .success:
                    self.user = nil
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}

