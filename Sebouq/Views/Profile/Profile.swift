//
//  Profile.swift
//  Find Nearby
//
//  Created by Norah w on 2023/8/1.
//

import Foundation
import SwiftUI

struct Profile: Codable, Equatable {
    var name = "Subog"
    var avatar = UIImage(named: "sb")!.pngData()!
    var email = "default@subog.com"
    var isAdvertising = false
    
    static let `default` = Profile()
    
    func data() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func equals(profile: Profile) -> Bool {
        if self.name != profile.name { return false }
        if self.avatar != profile.avatar { return false }
        if self.email != profile.email { return false }
        if self.isAdvertising != profile.isAdvertising { return false }
        return true
    }
}
