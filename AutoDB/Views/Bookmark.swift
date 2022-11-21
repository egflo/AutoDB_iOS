//
//  Bookmark.swift
//  AutoDB
//
//

import Alamofire
import SwiftUI
import AlertToast

struct BookmarkIcon: View {
    @EnvironmentObject var meta: Meta

    @State var auto: AutoSQL
    @State var bookmark: Bookmark? = nil
    @State var selected = false
    
    var body: some View {
        
        VStack {
            
            if let bookmark = bookmark {
                
                Button {
                    print("Bookmark")
                    deleteBookmark(id: bookmark.id)
                } label: {
                    Image(systemName: "heart")
                        .resizable()
                        .foregroundColor(self.selected ? .red : .blue )
                        .frame(width: 25, height: 25)

                }
            }
            
            else {
              
                Button {
                    print("Bookmark")
                    updateBookmark(id: auto.id)
                } label: {
                    Image(systemName: "heart")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 25, height: 25)

                }

            }

        }
        .onAppear(perform: {
            getBookmark(id: auto.id)
        })
        

        
    }
    
    func updateBookmark(id: String) {
        
        let parameters: Parameters = [
            "id": "0",
            "autoId": id,
        ]
        
        let URL = "/bookmark/"
        NetworkManager.shared.postRequest(of: Response<Bookmark>.self, url: URL, parameters: parameters) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.bookmark = response.data
                    self.selected = true
                    meta.toast = Toast(type: .success, headline: "Updated", subtitle: response.message)

                }
            case .failure(let error):
                DispatchQueue.main.async {
                    meta.toast = Toast(type: .error, headline: "Update Error", subtitle: error.localizedDescription)
                }
            }
        }
        
    }
    
    
    func deleteBookmark(id: String) {
        let URL = "/bookmark/\(id)"
        NetworkManager.shared.deleteRequest(of: Response<Bookmark>.self, url: URL) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.bookmark = nil
                    self.selected = false
                    meta.toast = Toast(type: .success, headline: "Deleted", subtitle: response.message)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    meta.toast = Toast(type: .error, headline: "Delete Error", subtitle: error.localizedDescription)
                    
                }
            }
        }
        
    }
    
    func getBookmark(id: String) {
        let URL = "/bookmark/exists/\(id)"
        print(URL)
        NetworkManager.shared.getRequest(of: Response<Bookmark>.self, url: URL, auth: true) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.bookmark = response.data
                    self.selected = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    meta.toast = Toast(type: .error, headline: "Get Error", subtitle: error.localizedDescription)
                    
                }
            }
        }
    }
    
    

}

