//
//  ContentView.swift
//  AutoDB
//
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedTab = 1
    @StateObject var meta = Meta()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    

    private var items: FetchedResults<Item>

    init() {
        if #available(iOS 15, *) {
            let appear = UIToolbarAppearance()
            appear.configureWithDefaultBackground()
            appear.shadowImage = UIImage()
            appear.backgroundImage =
            UIImage()
                .sd_blurredImage(withRadius: 20)
                
            UIToolbar.appearance().standardAppearance = appear
            UIToolbar.appearance().compactAppearance = appear
            UIToolbar.appearance().scrollEdgeAppearance = appear
            UIToolbar.appearance().isTranslucent = true
            
            let tb = UIToolbar()
            tb.isTranslucent = true
            tb.sizeToFit()

        }
    }
    
    
    
    var body: some View {
        
        VStack {
            VStack {
                
                TabView(selection: $selectedTab) {
                    
                    VStack{
                        NavigationView {
                            HomeView(selectTab: $selectedTab)
                            
                        }
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(1)
                    
                    VStack{
                        NavigationView {
                            SearchView()
                            
                        }
                    }
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(2)
                    
                    
                    VStack{
                        NavigationView {
                            FavoritesView(selectTab: $selectedTab)
                        }
                    }
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
                    .tag(3)
                    
                    VStack{
                        NavigationView {
                            UserView(selectTab: $selectedTab)
                        }
                    }
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                    .tag(4)
                    
                }
            }
        }


        .environmentObject(meta)
        .toastView(toast: $meta.toast)

    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
