//
//  ContentView.swift
//  AutoDB

import SwiftUI
import CoreData
import Auth0
import SimpleKeychain

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    
    @State var selectedTab = 1
    @StateObject var meta = Meta()
    
    @State var user: User?


    var body: some View {
        
        VStack {
            Text("Login to save and view your favorites.")
            
            Button("Login") {
                print("Button pressed!")
                login()
            }
            .buttonStyle(CustomButton())
        }
        
        TabView(selection: $selectedTab) {
            
            VStack{
                HomeView(selectTab: $selectedTab)
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
            .tag(3)

        }
        .environmentObject(meta)


    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension ContentView {
    
    func login() {
        Auth0
            .webAuth()
        
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    print(credentials)
                    
                    self.user = User(from: credentials.idToken)
                    
                    
                    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
                    var isCredentialsStored = credentialsManager.store(credentials: credentials)
                    
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

                    
                case .failure(let error):
                    print("Failed with: \(error)")
                }
                
            }
        
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: "TESSRTSAd", requiringSecureCoding: true) else {
            print("FAIL")
            
            return
        }
        
        let s = SimpleKeychain()
        
        print("-----")
        print(s.setEntry(data, forKey: "test"))
        print("-----")

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
