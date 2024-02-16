//
//  Sharing.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import SwiftUI
import MultipeerConnectivity

class MultipeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
        func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
            
        }
        
        func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
            
        }
        
        func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
            
        }
        
        @Published var receivedGameData: String = ""
        @Published var connectedPeers: [MCPeerID] = []
        @Published var isSelectingPeers = false
        @Published var isGameStarted = false
        @Published var selectedPeers: [MCPeerID] = []
        
        var myPeerID = MCPeerID(displayName: UIDevice.current.name)
        var session: MCSession?
        var advertiser: MCNearbyServiceAdvertiser?
        var browser: MCNearbyServiceBrowser?
        
        override init() {
            super.init()
            session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
            session?.delegate = self
            startAdvertising()
            startBrowsing()
        }
        
        func startAdvertising() {
            advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "Players")
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
        }
        
        func startBrowsing() {
            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "Players")
            browser?.delegate = self
            browser?.startBrowsingForPeers()
        }
        
        func sendPlayerName(playerName: String, toPeer peer: MCPeerID) {
            guard let session = session else { return }
            
            do {
                let data = "\(playerName)".data(using: .utf8)!
                try session.send(data, toPeers: [peer], with: .reliable)
            } catch {
                print("Error sending player name: \(error.localizedDescription)")
            }
        }
        
        func handleGameUpdate(_ data: String) {
            // Implement logic to handle game-related data
        }
        
        // MARK: - MCSessionDelegate
        
        func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            print("Connection state changed with peer \(peerID.displayName). New state: \(state.rawValue)")
            
            if state == .connected {
                connectedPeers.append(peerID)
            } else if state == .notConnected, let index = connectedPeers.firstIndex(of: peerID) {
                connectedPeers.remove(at: index)
            }
        }
        
        func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            if let receivedString = String(data: data, encoding: .utf8) {
                print("Received data from \(peerID.displayName): \(receivedString)")
                
                DispatchQueue.main.async {
                    self.receivedGameData = receivedString
                }
                
                handleGameUpdate(receivedString)
            }
        }
        
        // MARK: - MCNearbyServiceAdvertiserDelegate
        
        func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            invitationHandler(true, self.session)
        }
        
        // MARK: - MCNearbyServiceBrowserDelegate
        
        func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
            browser.invitePeer(peerID, to: self.session!, withContext: nil, timeout: 30)
        }
        
        func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            // Handle when a nearby peer is lost
        }
    }
    
    struct PeerListView: View {
        @ObservedObject var multipeerManager: MultipeerManager
        
        var body: some View {
            List {
                ForEach(multipeerManager.connectedPeers, id: \.self) { peer in
                    Text(peer.displayName)
                }
            }
        }
    }
struct ReceivedGameDataView: View {
    @ObservedObject var multipeerManager: MultipeerManager

    var body: some View {
        HStack {
            Image("أسماء اللاعبين") // Replace "yourPlayersImageName" with the actual name of your image in the assets
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140) // Adjust the size as neede
                 // Adjust the trailing padding as needed

            Text("\(multipeerManager.receivedGameData)")
                .padding()
        }
    }
}

    
    struct Sharing: View {
        @ObservedObject var multipeerManager = MultipeerManager()
        @State private var playerName = ""
        @State private var isSittingSheetPresented = false
        var body: some View {
            VStack {
                
                
                Button(action: {
                    isSittingSheetPresented.toggle()
                }) {
               
                    
                    Image("settings")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .position(x: 335) }
                .sheet(isPresented: $isSittingSheetPresented) {
                    Sitting()
                }
              Image("dvice")
                    .padding()
                
                
                PeerListView(multipeerManager: multipeerManager)
                    .frame(width: 300, height: 300) // Adjust the size as needed
                                        .background(Color.white) // Set the background color to white
                                        .cornerRadius(10)
                ReceivedGameDataView(multipeerManager: multipeerManager)
                
                TextField("أدخل اسمك واسماء اصحابك", text: $playerName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                
                if !multipeerManager.isSelectingPeers && !multipeerManager.isGameStarted {
                    Button(action: {
                        multipeerManager.isSelectingPeers = true
                    }) {
                        Image("اصحابك") // Replace "yourButtonImageName" with the actual name of your button image in the assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 50) // Adjust the size as needed
                    }
                    

                }
                
                if multipeerManager.isSelectingPeers && !multipeerManager.isGameStarted {
                    
                    
                    // Image("") // Remove this line if you don't want an image here
                    
                    PeerListViewForSelection(multipeerManager: multipeerManager)
                    
                    Button(action: {
                        multipeerManager.selectedPeers.forEach { selectedPeer in
                            multipeerManager.sendPlayerName(playerName: playerName, toPeer: selectedPeer)
                        }
                        multipeerManager.isSelectingPeers = false
                        multipeerManager.isGameStarted = true
                    }) {
                        NavigationLink(destination:
                                        Timer1() ) {
                            Image("ابدا")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 50)
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                        }
                    }
                }
                                if multipeerManager.isGameStarted {
                   
                }
            }
            .padding()
            
    .background(
               Image("back") // قم بتغيير "yourBackgroundImageName" باسم صورتك
                   .resizable()
                   .scaledToFill()
                   .edgesIgnoringSafeArea(.all)
           )
           
   }
}
    struct PeerListViewForSelection: View {
        @ObservedObject var multipeerManager: MultipeerManager
        
        var body: some View {
            List {
                ForEach(multipeerManager.connectedPeers, id: \.self) { peer in
                    let isSelected = multipeerManager.selectedPeers.contains(peer)
                    
                    Button(action: {
                        if isSelected {
                            if let index = multipeerManager.selectedPeers.firstIndex(of: peer) {
                                multipeerManager.selectedPeers.remove(at: index)
                            }
                        } else {
                            multipeerManager.selectedPeers.append(peer)
                        }
                    }) {
                        Text(peer.displayName)
                            .foregroundColor(isSelected ? .blue : .black)
                    }
                    
                }
            }
        }
    }

    
struct Sharing_Previews: PreviewProvider {
    static var previews: some View {
        Sharing()
    
        
    }
    
}

