//
//  MCManager.swift
//  Find Nearby
//
//  Created by Norah w on 2023/8/7.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

class MCManager: NSObject, ObservableObject {

    let defaults = UserDefaults.standard
    
    let serviceType = "Subog"
    var profile: Profile
    var peerID: MCPeerID
    var session: MCSession
    var serviceAdvertiser: MCNearbyServiceAdvertiser
    var serviceBrowser: MCNearbyServiceBrowser
    
    @Published var foundPeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var notConnectedPeers: [MCPeerID] = []
    @Published var profiles: [MCPeerID : Profile] = [:]
    @Published var messages: [MCPeerID : String] = [:]
    @Published var images: [MCPeerID : UIImage] = [:]
    @Published var files: [MCPeerID : URL] = [:]
    @Published var mStatus: [MCPeerID : Bool] = [:]
    @Published var iStatus: [MCPeerID : Bool] = [:]
    @Published var fStatus: [MCPeerID : Bool] = [:]
    
    override init() {
        profile = Profile.default
        peerID = MCPeerID(displayName: defaults.string(forKey: "Name") ?? UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        super.init()
        loadMC()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func loadMC() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        
        foundPeers.removeAll()
        connectedPeers.removeAll()
        notConnectedPeers.removeAll()
        
        profile = readFromDefaults()
        peerID = MCPeerID(displayName: profile.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                      discoveryInfo: ["show": profile.isAdvertising ? "Yes" : "No"],
                                                      serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        isBrowsing = defaults.bool(forKey: "isBrowsing")
    }
    
    var isBrowsing = false {
        didSet {
            if isBrowsing {
                serviceBrowser.startBrowsingForPeers()
            } else {
                serviceBrowser.stopBrowsingForPeers()
            }
            defaults.set(isBrowsing, forKey: "isBrowsing")
        }
    }
    
    func saveToDefaults(profile: Profile) {
        self.profile = profile
        defaults.set(profile.name, forKey: "Name")
        defaults.set(profile.avatar, forKey: "Avatar")
        defaults.set(profile.email, forKey: "Email")
        defaults.set(profile.isAdvertising, forKey: "isAdvertising")
        loadMC()
    }
    
    func readFromDefaults() -> Profile {
        return Profile(name: defaults.string(forKey: "Name") ?? "Default",
                       avatar: defaults.data(forKey: "Avatar") ?? UIImage(named: "Test")!.pngData()!,
                       email: defaults.string(forKey: "Email") ?? "default@multipeer.com",
                       isAdvertising: defaults.bool(forKey: "isAdvertising"))
    }
    
    enum DataType: Codable {
        case message
        case image
        case profile
    }
    
    struct MCData: Codable {
        var type: DataType
        var data: Data
    }
    
    func send(_ data: Data, with type: DataType, toPeer peerID: MCPeerID) {
        if session.connectedPeers.contains(peerID) {
            do {
                let encodedData = try JSONEncoder().encode(MCData(type: type, data: data))
                try session.send(encodedData, toPeers: [peerID], with: .reliable)
            } catch {
                print("Error when sending data to \(peerID.displayName)")
            }
        }
    }
    
    func sendResource(at fileURL: URL, toPeer peerID: MCPeerID) {
        if session.connectedPeers.contains(peerID) {
            session.sendResource(at: fileURL, withName: fileURL.lastPathComponent, toPeer: peerID)
        }
    }

}

extension MCManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
        
        switch state {
        case .connected:
            // Exchange profiles
            send(profile.data()!, with: .profile, toPeer: peerID)
            // Remove from notConnectedPeers
            if self.notConnectedPeers.contains(peerID) {
                DispatchQueue.main.async {
                    self.notConnectedPeers.removeAll(where: { $0.isEqual(peerID) })
                }
            }
            // Remove from foundPeers
            if self.foundPeers.contains(peerID) {
                DispatchQueue.main.async {
                    self.foundPeers.removeAll(where: { $0.isEqual(peerID) })
                }
            }
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            // Add to notConnectedPeers
            if !self.notConnectedPeers.contains(peerID) {
                DispatchQueue.main.async {
                    self.notConnectedPeers.append(peerID)
                }
            }
            print("Not connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let decodedData = try? JSONDecoder().decode(MCData.self, from: data) {
            switch decodedData.type {
            case .message:
                DispatchQueue.main.async {
                    self.messages[peerID] = String(data: decodedData.data, encoding: .utf8)
                    self.mStatus[peerID] = true
                }
            case .image:
                DispatchQueue.main.async {
                    self.images[peerID] = UIImage(data: decodedData.data)
                    self.iStatus[peerID] = true
                }
            case .profile:
                DispatchQueue.main.async {
                    self.profiles[peerID] = try? JSONDecoder().decode(Profile.self, from: decodedData.data)
                }
            }
        } else {
            print("Error when receiving data from \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Start receiving \"\(resourceName)\" from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Finish receiving \"\(resourceName)\" from \(peerID.displayName)")
        guard let tmpURL = localURL else { return }
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(resourceName) else { return }
        do {
            try FileManager.default.copyItem(at: tmpURL, to: documentURL)
        } catch {
            print("Failed to copy item to documentURL")
        }
        DispatchQueue.main.async {
            self.files[peerID] = documentURL
            self.fStatus[peerID] = true
        }
    }

}

extension MCManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }
        let title = "Session Invitation"
        let message = "\(peerID.displayName) invites you to a chat session, would you like to accept?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            invitationHandler(true, self.session)
        })
        window.rootViewController?.present(alertController, animated: true)
    }

}

extension MCManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !foundPeers.contains(peerID) && info?["show"] == "Yes" {
            foundPeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if foundPeers.contains(peerID) {
            foundPeers.removeAll(where: { $0.isEqual(peerID) })
        }
    }

}
