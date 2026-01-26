import Foundation
import SwiftUI
import Combine

@MainActor
class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var savedBundles: [SavedBundle] = []
    @Published var pastOrders: [Order] = []
    
    private let bundlesKey = "savedBundles_v1"
    private let ordersKey = "pastOrders_v1"
    
    init() {
        loadData()
    }
    
    /// Adds a product to the cart. If it exists, increases quantity.
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(product: product, quantity: quantity))
        }
    }
    
    /// Removes items from the cart list (swipe to delete)
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    /// Updates the quantity of a specific item (for the Stepper +/-)
    func updateQuantity(cartItemID: UUID, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItemID }) {
            if newQuantity > 0 {
                cartItems[index].quantity = newQuantity
            } else {
                // Optional: Remove if quantity goes to 0
                cartItems.remove(at: index)
            }
        }
    }
    
    /// Calculates the total price of everything in the active cart
    var cartTotal: Double {
        cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    /// Saves the CURRENT cart as a new Bundle
    func createBundleFromCart(name: String) {
        guard !cartItems.isEmpty else { return }
        
        // Convert CartItems -> BundleItems
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
    
    /// The "Killer Feature": Adds an entire bundle to the cart
    func addBundleToCart(_ bundle: SavedBundle) {
        for item in bundle.items {
            addToCart(product: item.product, quantity: item.quantity)
        }
    }
    
    func deleteBundle(at offsets: IndexSet) {
        savedBundles.remove(atOffsets: offsets)
        saveBundlesToDisk()
    }
    
    /// Moves items from Cart -> Order History and starts the timer
    func placeOrder(userName: String, pickupTime: Date, storeLocation: String) {
        // 1. Snapshot the items (Freeze the price!)
        let orderItems = cartItems.map {
            OrderItem(
                product: $0.product,
                quantity: $0.quantity,
                frozenPrice: $0.product.price
            )
        }
        
        // 2. Create the Order
        var newOrder = Order(
            id: UUID(),
            userName: userName,
            storeLocation: storeLocation,
            pickupTime: pickupTime,
            date: Date(),
            status: .processing,
            totalAmount: cartTotal,
            items: orderItems
        )
        
        // 3. Save to history and clear cart
        pastOrders.insert(newOrder, at: 0) // Add to top of list
        cartItems.removeAll()
        saveOrdersToDisk()
        
        // 4. Start the Simulation (The "Fake" Server)
        simulateOrderStatus(for: newOrder.id)
    }
    
    
    private func simulateOrderStatus(for orderID: UUID) {
        // After 5 seconds -> PACKING
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.updateStatus(for: orderID, to: .packing)
        }
        
        // After 10 seconds -> READY
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.updateStatus(for: orderID, to: .ready)
        }
    }
    
    private func updateStatus(for orderID: UUID, to status: OrderStatus) {
        if let index = pastOrders.firstIndex(where: { $0.id == orderID }) {
            pastOrders[index].status = status
            saveOrdersToDisk() // Save the new status
        }
    }
    
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
        // Load Bundles
        if let data = UserDefaults.standard.data(forKey: bundlesKey),
           let decoded = try? JSONDecoder().decode([SavedBundle].self, from: data) {
            savedBundles = decoded
        }
        
        // Load Orders
        if let data = UserDefaults.standard.data(forKey: ordersKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            pastOrders = decoded
        }
    }
}
