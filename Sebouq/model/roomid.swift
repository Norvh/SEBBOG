import Foundation

// Model struct for a Room

struct Room {
    var id: UUID
    var name: String
    var capacity: Int
    
    // Custom initializer
    init(name: String, capacity: Int) {
        self.id = UUID()
        self.name = name
        self.capacity = capacity
    }
}

// Example usage:
// Create a room instance
let room = Room(name: "Conference Room", capacity: 6)

// Access properties
// print("Room ID: \(room.id)")
// print("Room Name: \(room.name)")
// print("Room Capacity: \(room.capacity)")
