//
//  Winner.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import SwiftUI
import AVFoundation

struct Winner: View {
    @State private var isSoundOn = true
    @State private var animate:Bool=false
    @State private var isSittingSheetPresented = false
    @State private var isSheetPresented = false
    @State private var navigationActive = false
    var body: some View {
        ZStack {
            Image("back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
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
            VStack {
                Spacer()
                Spacer()
                // ... other Spacer() and content ...
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
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                Image("winner")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 211, height: 270)
                    .shadow(radius: 10)
                    .rotation3DEffect(Angle(degrees: animate ? 180 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
                    .onAppear {
                        withAnimation(.interpolatingSpring(stiffness: 30, damping: 3).repeatForever()) {
                            animate.toggle()
                            
                        }

                        }

                Spacer()

                Image("winnerRed")
                    .resizable()
                    .frame(width: 400, height: 200)
                    .position(x: 220,y: 35)
                   
                Spacer()

                // Play sound automatically on view appear
                Spacer()
                .onAppear {
                    print("Playing sound automatically!")
                    SoundManager.playSound(sound: "Notification - correct answer", type: "mp3")
                }

                NavigationLink(destination:  onBoarding() ) {
                        Image("نلعب")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }

                Spacer()

                Button(action: {
                    print("Exit tapped!")
                }) {
                    Image("خروج")
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
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
            }
        }
        .onDisappear {
            SoundManager.stopAudio()  // Stop the audio when the view disappears
        }
    }
}

// Your SoundManager class or structure
class SoundManager {
    static var audioPlayer: AVAudioPlayer?

    static func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }

    static func stopAudio() {
        audioPlayer?.stop()
    }
}

#if DEBUG
struct Winner_Previews: PreviewProvider {
    static var previews: some View {
        Winner()
    }
}

#endif
