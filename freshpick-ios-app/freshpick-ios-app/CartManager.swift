import Foundation
import SwiftUI
import Combine

// MARK: - 1. THE MOCK USER (Scrooge)
struct MockUser: Codable {
    var name = "Scrooge McDuck"
    var email = "profit@moneybin.duckburg"
    var phone = "(555) NUM-1-DIME"
    var memberID = "RICHEST-DUCK-001"
}

@MainActor
class CartManager: ObservableObject {
    
    // MARK: - 2. SHARED STATE
    @Published var cartItems: [CartItem] = []
    @Published var savedBundles: [SavedBundle] = []
    @Published var pastOrders: [Order] = []
    
    // Keys for persistence
    private let bundlesKey = "savedBundles_v1"
    private let ordersKey = "pastOrders_v1"
    
    // The "Logged In" User
    let currentUser = MockUser()
    
    init() {
        loadData()
    }
    
    // MARK: - 3. CART ACTIONS
    
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(product: product, quantity: quantity))
        }
    }
    
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    func updateQuantity(cartItemID: UUID, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItemID }) {
            if newQuantity > 0 {
                cartItems[index].quantity = newQuantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    var cartTotal: Double {
        cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    // MARK: - 4. BUNDLE ACTIONS
    
    func createBundleFromCart(name: String) {
        guard !cartItems.isEmpty else { return }
        
        let bundleItems = cartItems.map {
            BundleItem(product: $0.product, quantity: $0.quantity)
        }
        
        let newBundle = SavedBundle(
            name: name,
            items: bundleItems,
            createdAt: Date()
        )
        
        savedBundles.append(newBundle)
        saveBundlesToDisk()
    }
    
    func addBundleToCart(_ bundle: SavedBundle) {
        for item in bundle.items {
            addToCart(product: item.product, quantity: item.quantity)
        }
    }
    
    func deleteBundle(at offsets: IndexSet) {
        savedBundles.remove(atOffsets: offsets)
        saveBundlesToDisk()
    }
    
    // MARK: - 5. ORDER & SIMULATION LOGIC
    
    func placeOrder(pickupTime: Date, storeLocation: String) {
        
        // 1. Snapshot items
        let orderItems = cartItems.map {
            OrderItem(
                product: $0.product,
                quantity: $0.quantity,
                frozenPrice: $0.product.price
            )
        }
        
        // 2. Create Order (Always uses Current User)
        var newOrder = Order(
            id: UUID(),
            userName: currentUser.name,
            storeLocation: storeLocation,
            pickupTime: pickupTime,
            date: Date(),
            status: .processing,
            totalAmount: cartTotal,
            items: orderItems
        )
        
        // 3. Save & Clear
        pastOrders.insert(newOrder, at: 0)
        cartItems.removeAll()
        saveOrdersToDisk()
        
        // 4. Start Simulation
        simulateOrderStatus(for: newOrder.id)
    }
    
    private func simulateOrderStatus(for orderID: UUID) {
        // Step 1: Wait 5 seconds -> PACKING
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.updateStatus(for: orderID, to: .packing)
        }
        
        // Step 2: Wait 15 seconds -> READY
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.updateStatus(for: orderID, to: .ready)
        }
    }
    
    private func updateStatus(for orderID: UUID, to status: OrderStatus) {
        if let index = pastOrders.firstIndex(where: { $0.id == orderID }) {
            withAnimation {
                pastOrders[index].status = status
            }
            saveOrdersToDisk()
        }
    }
    
    // MARK: - 6. PERSISTENCE
    private func saveBundlesToDisk() {
        if let encoded = try? JSONEncoder().encode(savedBundles) {
            UserDefaults.standard.set(encoded, forKey: bundlesKey)
        }
    }
    
    private func saveOrdersToDisk() {
        if let encoded = try? JSONEncoder().encode(pastOrders) {
            UserDefaults.standard.set(encoded, forKey: ordersKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: bundlesKey),
           let decoded = try? JSONDecoder().decode([SavedBundle].self, from: data) {
            savedBundles = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: ordersKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            pastOrders = decoded
        }
    }
}
