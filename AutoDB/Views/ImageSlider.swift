//
//  ImageSlider.swift
//  AutoDB
//
//

import SwiftUI
import ImageIO
import SDWebImageSwiftUI


struct ImageSlider: View {
    // 1
    @State var auto: Auto
    @State var pageIndex = 0

    @State var images = [AutoImage]()
    
    var body: some View {
        // 2
        VStack {
            if images.isEmpty || images.count < 2 {
                Image(systemName: "livephoto.slash")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            
            else {
                
                ZStack(alignment: .center) {
                    
                    TabView(selection: $pageIndex) {
                        ForEach(Array(images.enumerated()), id: \.element) { index, element in
                            
                            VStack {
                                //3
                               WebImage(url: URL(string: element.url))
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
                            .tag(index)

                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    
                    HStack {
                        
                        Button {
                            print(pageIndex)
                            
                            if pageIndex > 0 {
                                pageIndex = pageIndex - 1
                            }

                        } label: {
                            Image(systemName: "chevron.left")
                                .frame(width:30,height: 30, alignment: .center)
                            .shadow(color: .black, radius: 1)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 35, height: 35)
                                    .shadow(color: .black, radius: 1)
                            )
                        }

                        Spacer()
                        
                        Button {
                            print(pageIndex)
                            if pageIndex < images.count {
                                pageIndex = pageIndex + 1
                            }

                        } label: {
                            Image(systemName: "chevron.right")
                                .frame(width:30,height: 30, alignment: .center)
                            .shadow(color: .black, radius: 1)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 35, height: 35)
                                    .shadow(color: .black, radius: 1)
                            )
                        }


                    }
                    .padding(.leading, 10)
                    .padding(.trailing,10)

                }.frame(maxWidth:.infinity, maxHeight: .infinity)

    
            }
        }
        .onAppear(perform: {
            
            images = auto.images.sorted{$0.url < $1.url}
        })
    }
    
    func processImages(auto: Auto) -> [AutoImage] {
    
        if auto.images.count < 2 {
            
            return []
        }
        
        else {
            return auto.images.sorted{$0.url < $1.url}
        }
        
    }
}




struct ImageSliderSQL: View {
    // 1
    @State var auto: AutoSQL
    @State var pageIndex = 0

    @State var images = [String]()
    
    var body: some View {
        // 2
        VStack {
            if images.isEmpty || images.count < 2 {
                Image("fallback")
                    .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                    .scaledToFit()
            }
            
            else {
                
                ZStack(alignment: .center) {
                    
                    TabView(selection: $pageIndex) {
                        ForEach(Array(images.enumerated()), id: \.element) { index, element in
                            
                            VStack {
                                //3
                               WebImage(url: URL(string: element))
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
                            .tag(index)

                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    

                }.frame(maxWidth:.infinity, maxHeight: .infinity)

    
            }
        }
        .onAppear(perform: {
            images = auto.images.sorted{$0 < $1}
        })
    }
    
    func processImages(auto: Auto) -> [AutoImage] {
    
        if auto.images.count < 2 {
            
            return []
        }
        
        else {
            return auto.images.sorted{$0.url < $1.url}
        }
        
    }
}
