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
    
    private let bundlesKey = "savedBundles_v1"
    private let ordersKey = "pastOrders_v2"
    
    let currentUser = MockUser()
    
    init() {
        loadData()
        if savedBundles.isEmpty {
            createSampleBundles()
        }
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
        
        let newBundle = SavedBundle(name: name, items: bundleItems, createdAt: Date())
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
    func placeOrder(pickupTime: Date, storeLocation: String, itemsTotal: Double, deliveryFee: Double, smallOrderFee: Double, tax: Double, tip: Double, grandTotal: Double) {
        
        let orderItems = cartItems.map {
            OrderItem(
                product: $0.product,
                quantity: $0.quantity,
                frozenPrice: $0.product.price
            )
        }
        
        let newOrder = Order(
            id: UUID(),
            userName: currentUser.name,
            storeLocation: storeLocation,
            pickupTime: pickupTime,
            date: Date(),
            status: .processing,
            
            itemsTotal: itemsTotal,
            deliveryFee: deliveryFee,
            smallOrderFee: smallOrderFee,
            tax: tax,
            tip: tip,
            grandTotal: grandTotal,
            
            items: orderItems
        )
        
        pastOrders.insert(newOrder, at: 0)
        cartItems.removeAll()
        saveOrdersToDisk()
        
        simulateOrderStatus(for: newOrder.id)
    }
    
    private func simulateOrderStatus(for orderID: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.updateStatus(for: orderID, to: .packing)
        }
        
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
    func saveBundlesToDisk() {
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
    
    // MARK: - 7. SAMPLE BUNDLES (Mock Data)
    private func createSampleBundles() {
        let products = ProductDatabase.products
        
        func findProduct(_ name: String) -> Product? {
            return products.first { $0.name.localizedCaseInsensitiveContains(name) }
        }
        
        var studySnacksItems: [BundleItem] = []
        if let apples = findProduct("Apple") { studySnacksItems.append(BundleItem(product: apples, quantity: 3)) }
        if let bananas = findProduct("Banana") { studySnacksItems.append(BundleItem(product: bananas, quantity: 2)) }
        if let chocolate = findProduct("Chocolate") { studySnacksItems.append(BundleItem(product: chocolate, quantity: 1)) }
        
        if !studySnacksItems.isEmpty {
            let studySnacks = SavedBundle(name: "Study Snacks", items: studySnacksItems, createdAt: Date())
            savedBundles.append(studySnacks)
        }
        
        var tacoItems: [BundleItem] = []
        if let cheese = findProduct("Cheese") { tacoItems.append(BundleItem(product: cheese, quantity: 1)) }
        if let avocado = findProduct("Avocado") { tacoItems.append(BundleItem(product: avocado, quantity: 2)) }
        if let meat = findProduct("Beef") { tacoItems.append(BundleItem(product: meat, quantity: 1)) }
        
        if !tacoItems.isEmpty {
            let tacoNight = SavedBundle(name: "Taco Night", items: tacoItems, createdAt: Date())
            savedBundles.append(tacoNight)
        }
        
        saveBundlesToDisk()
    }
}
