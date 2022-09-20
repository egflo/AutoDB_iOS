//
//  FavoritesView.swift
//  AutoDB
//
//

import SwiftUI
import Auth0



struct FavoritesView: View {
    @Binding var selectTab: Int
    @EnvironmentObject var meta: Meta

    
    @State var columns = [
        GridItem(.adaptive(minimum: 275, maximum: 400))
    ]
    
    @State var user: User?
    
    
    @StateObject private var dataSource = ContentDataSource<Bookmark>()
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    
    var body: some View {
        
        VStack {
            
            if credentialsManager.hasValid() {
                    
                    ScrollView {
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(dataSource.items, id: \.id) { bookmark in
                                
                                NavigationLink {
                                    AutoView(auto: bookmark.auto!)
                                    
                                } label: {
                                    AutoCard(auto: bookmark.auto!, selected: true)
                                        .frame(width: 300, height: 320, alignment: .top)

                                    
                                    .onAppear(perform: {
                                        if !self.dataSource.endOfList {
                                            if self.dataSource.shouldLoadMore(item: bookmark) {
                                                self.dataSource.fetch(path: "/bookmark/all", params: [], auth: true)

                                            }
                                        }
                                    })
                                }
                                
                            }
                            
                            if dataSource.isLoadingPage {
                                ProgressView()
                            }

                        }
                        .padding(.top, 25)

                    }
                    
   
                    .onAppear {
                        
                        self.dataSource.fetch(path: "/bookmark/all", params: [], auth: true)

                    }
                
            }
            
            else {
                
                VStack {
                    Text("Login to save and view your favorites.")
                    
                    Button("Login") {
                        print("Button pressed!")
                        login()
                    }
                    .buttonStyle(CustomButton())
                }
                

            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

extension FavoritesView {
    func login() {
        Auth0
            .webAuth()
            .audience("https://carvo/api")
            .start { result in
                switch result {
                case .success(let credentials):
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
                    self.meta.isAuthenticated = false
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
    
    func getBookmarks() {
        
    }
}




struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(selectTab: .constant(3))
            .environmentObject(Meta())
    }
}
