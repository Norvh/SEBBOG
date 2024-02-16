//
//  Group1.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import Foundation
import SwiftUI

struct Group1: View {
    @State private var isSheetPresented = false
    @State private var navigationActive = false
    @State private var isSittingSheetPresented = false
    var body: some View {
        ZStack {
            Image("back1")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                ZStack {
                    
                    Button(action: {
                        isSittingSheetPresented.toggle()
                    }) {
                        Image("settings")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .position(x: 350, y: 50)
                            .sheet(isPresented: $isSittingSheetPresented) {
                                Sitting()
                            }
                        
                    }
                }
                
                Spacer()
                
                ZStack {
                    Image("camel")
                        .position(x: 70, y: 80)
                }
                
                Spacer()
                VStack {
                    NavigationLink(destination:     DiscoverView()) {
                        Image("مجموعه")
                            .resizable()
                            .frame(width: 350, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)

                    }
                    NavigationLink(destination:  Sharing() ) {
                        Image("مجموعتي")
                            .resizable()
                            .frame(width: 350, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)

                    }
                }
                Spacer()
            }
        }
    }
    
}

struct Group1_Previews: PreviewProvider {
    static var previews: some View {
        Group1()
    }
}

