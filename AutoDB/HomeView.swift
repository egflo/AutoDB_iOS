//
//  HomeView.swift
//  AutoDB
//
//  Created by Emmanuel Flores on 9/11/22.
//

import SwiftUI


struct BrandView: View {
    @EnvironmentObject var meta: Meta

    
    var label: String
    
    var body: some View {
        
        VStack{
            VStack {
                Image("\(label.lowercased())")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 80, alignment: .center)

                
            }
            .padding(10)
            
        }
        
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: 1)
                .foregroundColor(.black)
            )
    }
    
}



struct IconView: View {
    @EnvironmentObject var meta: Meta

    @Binding var selectTab: Int
    var label: String
    
    var body: some View {
        
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
                .foregroundColor(.black)
            )
    }
    
}


struct HomeView: View {
    
    
    @Binding var selectTab: Int
    @State var columns = [
        GridItem(.adaptive(minimum: 200, maximum: 250))
    ]
    
    
    var body: some View {
        
        
        ScrollView{
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
                BrandView(label:"toyota")
                BrandView(label:"lexus")
                BrandView(label:"dodge")
                BrandView(label:"ford")
                BrandView(label:"jeep")
                BrandView(label:"mercedes-benz")

            }
        }


        Spacer()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectTab: .constant(0))
    }
}
