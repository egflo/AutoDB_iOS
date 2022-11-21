//
//  AutoView.swift
//  AutoDB
//
//

import SwiftUI
import ImageIO
import SDWebImageSwiftUI


struct DealerRow: View {
    
    @State var dealer: DealerSQL?
    
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
            .frame(maxWidth: .infinity, maxHeight: 70, alignment: .leading)
            //.frame(width: 170, height: 70, alignment: .leading)
            
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



struct CollapseView: View {
    
    @State var auto: AutoSQL
    @State var columnsText = [
        GridItem(.adaptive(minimum: 100, maximum: 200))
    ]
    
    
    var body: some View {
        
        VStack {
            
                Group {
                    
                    
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
                                ForEach(auto.options, id: \.self) { option in
                                    Text(option)
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

                                
                                Text("\(auto.vin)")
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


                                 Text(auto.report.theftTitle)
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

            
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        
    }
    
    func formatBool(bool: Bool) -> String {
        
        if bool {
            return "Yes"
        }
        
        return "No"
        
    }
    
}

struct AutoView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    //var id: String
    
    @State var auto: AutoSQL?
    
    
    @State var columns = [
        GridItem(.adaptive(minimum: 250, maximum: 290))
    ]
    

    var body: some View {
        
        ScrollView {
            if let auto = auto {
                
                Group {
                    
                    ZStack {
                        ImageSliderSQL(auto: auto)
                        
                        BookmarkIcon(auto: auto)
                        .offset(x: -150, y: -95)
                        
                        
                    } .frame(width: width, height: 290, alignment: .center)


                    
                    Text("\(String(auto.year)) \(auto.make) \(auto.model)")
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

                        FeatureView(name: "engine", description: "Engine", value: String(auto.engine.engineType))

                        FeatureView(name: "drivetrain", description: "Drivetrain", value: String(auto.drivetrain.wheelSystemDisplay))

                        FeatureView(name: "transmission", description: "Transmission", value: String(auto.transmission.transmissionDisplay))

                        FeatureView(name: "fuel", description: "Fuel", value: String(auto.fuelType))

                        FeatureView(name: "mpg", description: "MPG", value: "\(20) Combined")

                        FeatureView(name: "exterior", description: "Exterior", value: "\(String(auto.exteriorColor))")

                        FeatureView(name: "seats", description: "Seating", value: "\(auto.maximumSeating)")


            
                    }
                    .padding(.leading, 10)
                    .padding(.trailing,10)
                    
                    
                    CollapseView(auto: auto)

                    
                }
                

                
            }
            else {
                ProgressView()
            }
            
        }
        .navigationBarTitle("Listing", displayMode: .inline)

        
        .onAppear(perform: {
            //self.getAuto()
        })
    }
    
    func formatPrice(price: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let value = formatter.string(from: price as NSNumber)
        
        return value!
    }
    

    
    func getAuto() {
        let URL = "/auto/\(1252)"
        
        NetworkManager.shared.getRequest(of: AutoSQL.self, url: URL) { (result) in
            switch result {
            case .success(let auto):
                DispatchQueue.main.async {
                    self.auto = auto
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error \(error.localizedDescription)")
                    
                }
            }
        }
    }

}


