//
//  Collapsible.swift
//  AutoDB
//
//

import SwiftUI

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

