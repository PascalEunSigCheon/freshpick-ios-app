import Foundation


struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let imageName: String
    let category: Category
    let description: String
    let price: Double
}

enum Category: String, CaseIterable, Codable, Identifiable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case bakery = "Bakery"
    case dairy = "Dairy & Eggs"
    case meat = "Meat & Seafood"
    case frozen = "Frozen Foods"
    case pantry = "Pantry" // Pasta, Rice, Canned goods
    case snacks = "Snacks"
    case beverages = "Beverages"
    case breakfast = "Breakfast"   // Cereal, Oatmeal
    case household = "Household"   // Cleaning supplies
    case personalCare = "Personal Care"
    case pets = "Pet Supplies"
    
    // Conformance to Identifiable so we can loop in SwiftUI
    var id: String { self.rawValue }
}

struct CartItem: Identifiable, Codable {
    var id = UUID()
    let product: Product
    var quantity: Int
}

struct BundleItem: Identifiable, Codable {
    var id = UUID()
    let product: Product
    var quantity: Int
}

struct SavedBundle: Identifiable, Codable {
    var id = UUID()
    var name: String
    var items: [BundleItem]
    var createdAt: Date
}

enum OrderStatus: String, Codable, CaseIterable {
    case processing = "Processing"
    case packing = "Packing"
    case ready = "Ready for Pickup"
    case completed = "Picked Up"
}

struct OrderItem: Identifiable, Codable {
    var id = UUID()
    let product: Product
    let quantity: Int
    let frozenPrice: Double // Stores the price user actually paid
}

struct Order: Identifiable, Codable {
    let id: UUID
    let userName: String
    let storeLocation: String
    let pickupTime: Date
    let date: Date
    var status: OrderStatus
    let totalAmount: Double  // Stored for fast access in "My Orders"
    
    var items: [OrderItem]
}
