//
//  Sitting.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import SwiftUI
struct Sitting: View {
    @State private var isPopupVisible = false
    @State private var isSheetPresented = false
    @State private var navigationActive = false
    var body: some View {
        ZStack {
            // Your main content goes here
            Image("back")
                .resizable()
                .padding(.top, -20.0)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            
            // Popup overlay
            if isPopupVisible {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Close the popup when tapped outside
                        isPopupVisible.toggle()
                    }

                // Popup content with increased size
                VStack {
                    Image("set")
                        .padding()

                    // Add your popup content here

                    Button(action: {
                        self.isSheetPresented.toggle()
                    }) {
                        Image("x")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .position(x: 30)
                    }

                    VStack(spacing: 20) {
                        // "Music" button
                        Button(action: {
                            print("Music button tapped!")
                        }) {
                            Image("music")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80) // Adjust the height as needed
                        }
                        .frame(width: 150) // Adjust the width as needed

                        // "خروج" button
                        
                        
                    
                    NavigationLink(destination:  onBoarding() ) {
                      
                            Image("out")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                                .navigationBarTitle("")
                                .navigationBarHidden(true) // Adjust the height as needed
                        }
                        .alignmentGuide(.top) { _ in 100 } // Adjust the value as needed
                    }
                }
                .frame(width: 300, height: 350) // Adjust the frame size as needed
                .background(Color.white)
                .cornerRadius(16)
                .padding()
            }
        }
        .onAppear {
            // Open the popup when the view appears
            isPopupVisible.toggle()
        }
    }
}
struct Sitting_Previews: PreviewProvider {
    static var previews: some View {
        Sitting()
    }
}
