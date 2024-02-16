//
//  Loser.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import SwiftUI
import AVFoundation
struct Loser: View {
    @State private var animate:Bool=false
    @State private var isSittingSheetPresented = false
    @State private var isSoundOn = true
    var body: some View {
        
        ZStack{
            
            Image("back2")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            VStack{
                
                
                
                
                Button(action: {
                    isSittingSheetPresented.toggle()
                }) {
               
                    
                    Image("settings")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .position(x: 350, y: 50) }
                .sheet(isPresented: $isSittingSheetPresented) {
                    Sitting()
                }
              
              //  Image("السبوق")
             
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
             //   Image("السبوق")
                   // .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                  //  .frame(width: 100,height: 40)
                   // .aspectRatio(contentMode: .fit)
               
                   // .resizable()
                  Spacer()
                  Spacer()
                  Spacer()
                  Spacer()
                  Spacer()
              
                Image("loser")
                
               
                                  .resizable()
                                  .aspectRatio(contentMode: .fit)
                                  .frame(width: 231, height: 290)
                                  .scaledToFill()
                                  .frame(width: 300, height: 300)
                                  .shadow(radius: 10)
                                  .rotation3DEffect(Angle(degrees: animate ? 180 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
                                  .onAppear {
                                      withAnimation(.interpolatingSpring(stiffness: 30, damping: 3).repeatForever()) {
                                          animate.toggle()
                                          
                                      }
    
                                      }
                
                Image("لاعب")
                
                
                
                Spacer()
                   
             
                Spacer()
                    
                    .onAppear {
                                          print("Playing sound automatically!")
                                          SoundManager.playSound(sound: "loser", type: "mp3")
                                      }
                                  
                
                
                
                
                Button(action: {
                          
                              print("Button tapped!")
                          }) {
                    Image("نلعب")
            
                    .resizable()
                                 // .position(x:220,y:180)
                                //  .frame(width: 370, height: 190)
                              
                                  .aspectRatio(contentMode: .fit)
                                  .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                          }
                
             
                    Button(action: {
                        
                        print("Button tapped!")
                    }) {
                        Image("خروج")
                    
                            .aspectRatio(contentMode: .fit)
                        
                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        
                    }
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
             
                
            }
        }
    }
}

#Preview {
    Loser()
}
