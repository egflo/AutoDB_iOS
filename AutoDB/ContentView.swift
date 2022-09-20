//
//  ContentView.swift
//  AutoDB
//
//  Created by Emmanuel Flores on 9/13/22.
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

    var body: some View {
        

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
        .environmentObject(meta)

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
