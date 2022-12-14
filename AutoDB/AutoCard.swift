//
//  AutoCard.swift
//  AutoDB
//
//  Created by Emmanuel Flores on 9/5/22.
//

import SwiftUI

struct AutoCard: View {
    @State var auto: Auto
    
    var body: some View {

        VStack {
            
            ZStack {
                
                ImageSlider(auto: auto)
                    .frame(height:175)
                    //.border(.green)
                
                VStack {
                    
                    Button {
                        print("Bookmared")
                    } label: {
                        Image(systemName: "heart")
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 45, height: 45)
                                    .shadow(color: .black, radius: 1)
                            )
                    }
                    
                    .padding(.leading, 10)
                    .padding(.top, 10)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 175, alignment: .leading)
                
            } .frame(maxWidth: .infinity, maxHeight: 175, alignment: .center)
            

            
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

                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)


                HStack {
                    Spacer()

                    VStack {
                        Image("mileage")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 45, maxHeight: 45)
                            .background(
                                Circle()
                                    .stroke(.gray, lineWidth: 1)
                                    .frame(width: 55, height: 55)
                            )

                        Text("\(String(auto.mileage)) miles")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    
                    Spacer()
                    
                    VStack {
                        Image("fuel")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 45, maxHeight: 45)
                            .background(
                                Circle()
                                    .stroke(.gray, lineWidth: 1)
                                    .frame(width: 55, height: 55)
                            )

                        Text("\(String(auto.fuel.type))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    
                    Spacer()

                    VStack {
                        Image("transmission")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 45, maxHeight: 45)
                            .background(
                                Circle()
                                    .stroke(.gray, lineWidth: 1)
                                    .frame(width: 55, height: 55)
                            )

                        Text("\(String(auto.transmission.type == "A" ? "Automatic" : "Manual"))")
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(.black)

                    }
                    Spacer()

                }
                
            }
            .padding(.leading, 10)


            
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
