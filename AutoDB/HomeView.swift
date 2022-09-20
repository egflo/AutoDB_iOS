//
//  HomeView.swift
//  AutoDB
//
//

import SwiftUI
import Auth0

struct WatchListRow: View {
    
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    @StateObject private var dataSource = ContentDataSource<Bookmark>()

    var body: some View {
        
        if credentialsManager.hasValid() {
        
            VStack {
                
                Text("Your Favorites")
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,20)
                
                ScrollView(.horizontal) {
                    
                    HStack(spacing: 20) {
                        
                        ForEach(dataSource.items, id: \.id) { bookmark in
                            
   
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
                        
                        if dataSource.isLoadingPage {
                            ProgressView()
                        }

                    }
                    .padding(15)

                    

                }
                

                .onAppear {
                    
                    self.dataSource.fetch(path: "/bookmark/all", params: [], auth: true)

                }
            }
        }
        
    }
}


struct BrandView: View {
    @EnvironmentObject var meta: Meta

    @Binding var selectTab: Int
    var label: String
    
    var body: some View {
        
        Button {
            
        } label: {
            
            VStack{
                VStack {
                    Image("\(label.lowercased())")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 80, alignment: .center)

                    
                }
                .padding(10)
                
            }
            
            .onTapGesture {
                meta.query = "\(label)"
                self.selectTab = 2
            }
            
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
                    .foregroundColor(.gray)

                )
            
        }

    }
    
}



struct IconView: View {
    @EnvironmentObject var meta: Meta

    @Binding var selectTab: Int
    var label: String
    
    var body: some View {
        
        Button {
            
        } label: {
            VStack {
                VStack {
                
                    Image("\(label.lowercased())")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 70, alignment: .center)
                    
                    Text("\(label)")
                        .bold()
                        .foregroundColor(.blue)
                        .font(.headline)
                    
                }
                
                .padding(.bottom,12)
                        
            
            }
            .onTapGesture {
                meta.query = "\(label)"
                self.selectTab = 2
            }
            
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
                    .foregroundColor(.gray)
                )
        }

    }
    
}


struct HomeView: View {
    
    @Binding var selectTab: Int
    @State var columns = [
        GridItem(.adaptive(minimum: 200, maximum: 250))
    ]
    
    
    var body: some View {
        
        VStack {
            
            ScrollView{
                
                WatchListRow()
                
                Text("Browse By Type")
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,20)
                
                //NavigationLink(destination: SearchView(term: "\(label)"))
                
                LazyVGrid(columns: columns, spacing: 20) {
                    IconView(selectTab: $selectTab, label:"Sedan")
                    IconView(selectTab: $selectTab, label:"Truck")
                    IconView(selectTab: $selectTab, label:"Convertible")
                    IconView(selectTab: $selectTab, label:"Van")
                    IconView(selectTab: $selectTab, label: "Coupe")
                    IconView(selectTab: $selectTab, label: "Wagon")

                }
                
                
                Text("Browse By Brand")
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,20)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    BrandView(selectTab: $selectTab,label:"toyota")
                    BrandView(selectTab: $selectTab,label:"lexus")
                    BrandView(selectTab: $selectTab,label:"dodge")
                    BrandView(selectTab: $selectTab,label:"ford")
                    BrandView(selectTab: $selectTab,label:"jeep")
                    BrandView(selectTab: $selectTab,label:"mercedes-benz")

                }
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.automatic)
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectTab: .constant(0))
    }
}
