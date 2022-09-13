//
//  AutoView.swift
//  AutoDB
//
//  Created by Emmanuel Flores on 8/11/22.
//

import SwiftUI
import ImageIO
import SDWebImageSwiftUI




struct Collapsible<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack {
            Button(
                action: { self.collapsed.toggle() },
                label: {
                    
                    VStack {
                        
                        //Divider()
                        
                        HStack {
                            self.label()
                                .bold()
                            Spacer()
                            Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                                .foregroundColor(.blue)
                            

                        }
                        
                        Divider()
                    }
                    .background(.gray.opacity(0.01))
                }
            )
            .padding()
            .buttonStyle(PlainButtonStyle())
            
            VStack {
                self.content()
            }.border(.green)

            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            //.animation(.easeOut)
           // .transition(.slide)

        }
        //.padding(.leading, 10)
        //.padding(.trailing,10)
    }
}



struct ImageSlider: View {
    // 1
    @State var auto: Auto
    
    var body: some View {
        // 2
        VStack {
            if auto.images.isEmpty {
                Image(systemName: "livephoto.slash")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            
            else {
                TabView {
                    ForEach(processImages(auto: auto), id: \.id) { item in
                         //3
                        WebImage(url: URL(string: item.url))
                        // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                        .onSuccess { image, data, cacheType in
                            // Success
                            // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                        }
                        .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                        .placeholder(Image(systemName: "livephoto.slash")) // Placeholder Image
                        // Supports ViewBuilder as well
                        .placeholder {
                            Rectangle().foregroundColor(.white)
                        }
                        .indicator(.activity) // Activity Indicator
                        .transition(.fade(duration: 0.5)) // Fade Transition with duration
                        .scaledToFit()
                    }
                }
                .tabViewStyle(PageTabViewStyle())            }
        }
        

    }
    
    func processImages(auto: Auto) -> [AutoImage] {
        
        print(auto.id)
        print(auto.images.count)
        
        if auto.images.count < 2 {
            
            return []
        }
        
        else {
            return auto.images.sorted{$0.url < $1.url}
        }
        
    }
}



struct DealerRow: View {
    
    @State var dealer: Dealer?
    
    var body: some View {
        
        VStack {
            if let dealer = dealer {
                
                let url = URL(string: "maps://?saddr=&daddr=\(dealer.latitude),\(dealer.longitude)")

                if UIApplication.shared.canOpenURL(url!) {
                    
                    Button {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)

                    }
                    label:
                    {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("\(dealer.city) \(dealer.postcode)")
                                .bold()
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top,1)
                        .padding(.bottom,1)
                    }
                    

                }
                
                else {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("\(dealer.city) \(dealer.postcode)")
                            .bold()
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top,1)
                    .padding(.bottom,1)
                }
                
            }
            
            else {
                
                Text("No location avaliable")
                    .bold()
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            }
            
        }
        
    }
}


struct FeatureView: View {
    @State var name: String
    @State var description: String
    @State var value: String
    
    var body: some View {
        
        VStack {
            HStack {
                Image("\(name)")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 60, maxHeight: 90)
                    //.border(.green)
                
                VStack {
                    
                    Text("\(description)")
                        .bold()
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(value)")
                        .bold()
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                
                Spacer()
            }
            .frame(width: 170, height: 70, alignment: .leading)
            //.border(.red)
            
        }
    }
    
    func getIconName(description: String) -> String {
        if description.contains("icon") {
            return "Test"
        }
        else {
            return "Test"
        }
    }
}


struct AutoView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    @State var auto: Auto
    
    
    @State var columns = [
        GridItem(.adaptive(minimum: 200, maximum: 270))
    ]
    
    @State var columnsText = [
        GridItem(.adaptive(minimum: 100, maximum: 200))
    ]
    
    var body: some View {
        
        ScrollView {
            if let auto = auto {
                
                
                Group {
                    
                    ZStack {
                        ImageSlider(auto: auto)
                            .border(.green)
                        
                        
                        VStack {
                            
                            
                            Button {
                                print("Bookmared")
                            } label: {
                                Image(systemName: "heart")
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(color: .black, radius: 1)
                                    )
                            }

                            
                            

                            
                            Spacer()
                        }
                        .frame(width: width, height: 290, alignment: .leading)
                        
                    } .frame(width: width, height: 290, alignment: .center)


                    
                    Text("\(String(auto.year)) \(auto.make.name) \(auto.model.name)")
                        .bold()
                        .font(.largeTitle)
                    
                    Text(formatPrice(price: auto.price))
                        .bold()
                        .font(.headline)
                    
                    DealerRow(dealer: auto.dealer)

                }
                
                
                Group {
                    
                    LazyVGrid(columns: columns, spacing: 20)  {
                        

                        FeatureView(name: "mileage", description: "Mileage", value: String(auto.mileage))

                        FeatureView(name: "engine", description: "Engine", value: String(auto.engine.type))

                        FeatureView(name: "drivetrain", description: "Drivetrain", value: String(auto.drivetrain.name))

                        FeatureView(name: "transmission", description: "Transmission", value: String(auto.transmission.description))

                        FeatureView(name: "fuel", description: "Fuel", value: String(auto.fuel.type))

                        FeatureView(name: "mpg", description: "MPG", value: "\(String(auto.cityMpg)) Combine")


                        FeatureView(name: "exterior", description: "Exterior", value: "\(String(auto.exteriorColor))")

                        FeatureView(name: "seats", description: "Seating", value: "\(String(auto.seating)) Seat(s)")


            
                    }
                    .padding(.leading, 10)
                    .padding(.trailing,10)
                    

                    
                }
                
                VStack {

                Collapsible(
                    label: {
                        Text("Seller Description")
                        
                    },
                    content: {
                        HStack {
                            Text("\(auto.description)")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                )
                .frame(maxWidth: .infinity)
                                
                Collapsible(
                    label: {
                        Text("Features")
                        
                    },
                    content: {
                        VStack {
                            ForEach(auto.options, id: \.id) { option in
                                Text(option.description)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                )
                .frame(maxWidth: .infinity)
                
                
                Collapsible(
                    label: {
                        Text("Mechanical")
                        
                    },
                    content: {
                        LazyVGrid(columns: columnsText, spacing: 20)  {
                            
                            VStack {
                                Text("Cylinders")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                
                                Text("\(auto.engine.cylinders)")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }
                            
                            VStack {
                                Text("Displacement")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)


                                Text("\(auto.engine.displacement)")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }

                            VStack {
                                Text("Horsepower")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(auto.engine.horsepower)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }
                                     
                             VStack {
                                Text("Power")
                                     .bold()
                                     .frame(maxWidth: .infinity, alignment: .leading)

                                Text(auto.engine.power)
                                     .frame(maxWidth: .infinity, alignment: .leading)

                             }
                                     
                             VStack {
                                Text("Torque")
                                     .bold()
                                     .frame(maxWidth: .infinity, alignment: .leading)


                                Text(auto.engine.torque)
                                     .frame(maxWidth: .infinity, alignment: .leading)

                                 
                            }

                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                )
                .frame(maxWidth: .infinity)
                
                
                
                if let dealer = auto.dealer {
                    
                    Collapsible(
                        label: {
                            Text("Dealer")
                            
                        },
                        content: {
                            LazyVGrid(columns: columnsText, spacing: 20)  {
                                
                                VStack {
                                    Text("Name")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    
                                    Text("\(dealer.name)")
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                }
                                
                                VStack {
                                    Text("Rating")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)


                                    Text("\(dealer.rating)")
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                }

                                VStack {
                                    Text("City")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(dealer.city)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                }
                                         
                                 VStack {
                                    Text("Postcode")
                                         .bold()
                                         .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(dealer.postcode)
                                         .frame(maxWidth: .infinity, alignment: .leading)

                                 }
                                         
                                 VStack {
                                    Text("Franchise Dealer")
                                         .bold()
                                         .frame(maxWidth: .infinity, alignment: .leading)


                                     Text(formatBool(bool: dealer.franchiseDealer))
                                         .frame(maxWidth: .infinity, alignment: .leading)

                                     
                                }

                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
                
                
                Collapsible(
                    label: {
                        Text("Report")
                        
                    },
                    content: {
                        LazyVGrid(columns: columnsText, spacing: 20)  {
                            
                            VStack {
                                Text("VIN")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                
                                Text("\(auto.report.vin)")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }
                            
                            VStack {
                                Text("Frame Damage")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)


                                Text(formatBool(bool: auto.report.frameDamage))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }

                            VStack {
                                Text("Accidents")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)


                                Text(formatBool(bool: auto.report.hasAccidents))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }
                                     
                             VStack {
                                 Text("Theft Title")
                                     .bold()
                                     .frame(maxWidth: .infinity, alignment: .leading)


                                 Text(formatBool(bool: auto.report.theftTitle))
                                     .frame(maxWidth: .infinity, alignment: .leading)

                             }
                                     
                             VStack {
                                 Text("Salvage")
                                     .bold()
                                     .frame(maxWidth: .infinity, alignment: .leading)


                                 Text(formatBool(bool: auto.report.salvage))
                                     .frame(maxWidth: .infinity, alignment: .leading)

                                 
                            }

                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                )
                .frame(maxWidth: .infinity)
                    
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
            }
            else {
                ProgressView()
            }
            
        }
        .navigationBarTitle("Listing", displayMode: .inline)

        
        .onAppear(perform: {
            self.getAuto()
        })
    }
    
    func formatPrice(price: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let value = formatter.string(from: price as NSNumber)
        
        return value!
    }
    
    func formatBool(bool: Bool) -> String {
        
        if bool {
            return "Yes"
        }
        
        return "No"
        
    }
    
    func getAuto() {
        let URL = "http://10.81.1.123:8080/auto/make/bmw"
        NetworkManager.shared.getRequest(of: Auto.self, url: URL) { (result) in
            switch result {
            case .success(let auto):
                DispatchQueue.main.async {
                    //self.auto = auto
                    print(auto)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }

}


