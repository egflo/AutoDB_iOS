//
//  AutoCard.swift
//  AutoDB
//
//

import SwiftUI




struct AutoCardSQL: View {
    @State var auto: AutoSQL
    var selected: Bool = false
    
    
    let offset: CGFloat = 40
    
    var body: some View {

        VStack {
            
            ZStack {
                
                ImageSliderSQL(auto: auto)
                
                BookmarkIcon(auto: auto)
                .offset(x: -145, y: -40)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 220, alignment: .center)
            
            VStack {
                
                VStack {
                    
                    VStack {
                        
                    
                        Text("\(String(auto.year)) \(auto.make) \(auto.model)")
                            .bold()
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom,2)
                        
                        HStack {
                            
                            Text(formatPrice(price: auto.price))
                                .bold()
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            
                            if let dealer = auto.dealer {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("\(dealer.city) \(dealer.postcode)")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.gray)
                                }
      
                            }

                            Spacer()
                        }

                        
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom,0)
                .padding(.leading,10)


                HStack {
                    Spacer()

                    VStack {
                        Image("mileage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)


                        Text("\(auto.mileage.formatK)")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 70, alignment: .center)

                    
                    VStack {
                        Image("drivetrain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)


                        Text("\(formatMeta(value: auto.drivetrain.wheelSystem))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 70, alignment: .center)
                    
                    VStack {
                        Image("fuel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)


                        Text("\(formatMeta(value: auto.fuelType))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 70, alignment: .center)


                    VStack {
                        Image("transmission")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)


                        Text("\(String(auto.transmission.transmission == "A" ? "Automatic" : "Manual"))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 65, alignment: .center)

                    
                    Spacer()

                }
                
            }
            
            Spacer()
            
        }
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .shadow(color: .gray.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    
    func formatMeta(value: String) -> String {
        
        if value.isEmpty {
            return "N/A"
        }
        
        return value
    }
    
    func formatPrice(price: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let value = formatter.string(from: price as NSNumber)
        
        return value!
    }
    
    
}



struct AutoCard: View {
    @State var auto: Auto
    var selected: Bool = false
    
    var body: some View {

        VStack {
            
            ZStack {
                
                ImageSlider(auto: auto)
                    .frame(height:180)
                    //.border(.green)
                
                VStack {
                    
                    Button {
                        print("Bookmared")
                    } label: {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.selected ? .red : .gray)
                            .frame(width: 30, height: 30)
                            //.shadow(color: .black, radius: 1)
                            //.background(
                           //     Circle()
                            //        .fill(.white)
                            //        .frame(width: 45, height: 45)
                           //         .shadow(color: .black, radius: 1)
                           // )
                    }
                    
                    .padding(.leading, 15)
                    .padding(.top, 15)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 180, alignment: .leading)
                
            } .frame(maxWidth: .infinity, maxHeight: 180, alignment: .center)
            

            
            VStack {
                
                    
                    
                    VStack {
                        
                    
                        Text("\(String(auto.year)) \(auto.make.name) \(auto.model.name)")
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        HStack {
                            
                            Text(formatPrice(price: auto.price))
                                .bold()
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            
                            if let dealer = auto.dealer {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("\(dealer.city) \(dealer.postcode)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                //.padding(.top,1)
                                //.padding(.bottom,1)
                            }

                            Spacer()
                        }

                        
                    }
                    
                    

                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)



                HStack {
                    Spacer()

                    VStack {
                        Image("mileage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                          //  .background(
                          //      Circle()
                          //          .stroke(.gray, lineWidth: 1)
                          //          .frame(width: 55, height: 55)
                          //  )

                        Text("\(String(auto.mileage)) mi")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 70, alignment: .center)

                    
                    
                    VStack {
                        Image("fuel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            //.background(
                            //    Circle()
                            //        .stroke(.gray, lineWidth: 1)
                            //        .frame(width: 55, height: 55)
                           // )

                        Text("\(String(auto.fuel.type))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 70, alignment: .center)


                    VStack {
                        Image("transmission")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                            //.background(
                            //    Circle()
                            //        .stroke(.gray, lineWidth: 1)
                            //        .frame(width: 55, height: 55)
                           // )

                        Text("\(String(auto.transmission.type == "A" ? "Automatic" : "Manual"))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    .frame(width:80, height: 65, alignment: .center)

                    
                    Spacer()

                }
                
            }


            
            Spacer()
            
        }
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .shadow(color: .gray.opacity(0.3), radius: 20, x: 0, y: 10)

        
    }
    
    func formatPrice(price: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let value = formatter.string(from: price as NSNumber)
        
        return value!
    }
    
    
}

//struct AutoCard_Previews: PreviewProvider {
  //  static var previews: some View {
        //AutoCard()
  //  }
//}
