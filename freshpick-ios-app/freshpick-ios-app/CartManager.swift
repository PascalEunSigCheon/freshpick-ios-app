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
            totalAmount: cartTotal,
            items: orderItems
        )
        
        pastOrders.insert(newOrder, at: 0)
        cartItems.removeAll()
        saveOrdersToDisk()
        
        simulateOrderStatus(for: newOrder.id)
    }
    
    private func simulateOrderStatus(for orderID: UUID) {
        // Step 1: Wait 5 seconds -> PACKING
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.updateStatus(for: orderID, to: .packing)
        }
        
        // Step 2: Wait 30 seconds -> READY
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
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
    
    /// Creates sample bundles matching the design mockup
    private func createSampleBundles() {
        let products = ProductDatabase.products
        
        // Helper to find product by name
        func findProduct(_ name: String) -> Product? {
            return products.first { $0.name.localizedCaseInsensitiveContains(name) }
        }
        
        // Study Snacks Bundle
        var studySnacksItems: [BundleItem] = []
        if let almonds = findProduct("Almonds") { studySnacksItems.append(BundleItem(product: almonds, quantity: 2)) }
        if let apples = findProduct("Apple") { studySnacksItems.append(BundleItem(product: apples, quantity: 3)) }
        if let yogurt = findProduct("Yogurt") { studySnacksItems.append(BundleItem(product: yogurt, quantity: 4)) }
        if let chips = findProduct("Chips") { studySnacksItems.append(BundleItem(product: chips, quantity: 2)) }
        if let bananas = findProduct("Banana") { studySnacksItems.append(BundleItem(product: bananas, quantity: 1)) }
        if let strawberries = findProduct("Strawberry") { studySnacksItems.append(BundleItem(product: strawberries, quantity: 1)) }
        if let cheese = findProduct("Cheese") { studySnacksItems.append(BundleItem(product: cheese, quantity: 1)) }
        
        let studySnacks = SavedBundle(
            name: "Study Snacks",
            items: studySnacksItems,
            createdAt: Date().addingTimeInterval(-86400 * 5)
        )
        
        // Weekly Essentials Bundle
        var weeklyEssentialsItems: [BundleItem] = []
        if let milk = findProduct("Milk") { weeklyEssentialsItems.append(BundleItem(product: milk, quantity: 2)) }
        if let eggs = findProduct("Eggs") { weeklyEssentialsItems.append(BundleItem(product: eggs, quantity: 2)) }
        if let bread = findProduct("Bread") { weeklyEssentialsItems.append(BundleItem(product: bread, quantity: 2)) }
        if let spinach = findProduct("Spinach") { weeklyEssentialsItems.append(BundleItem(product: spinach, quantity: 2)) }
        if let chicken = findProduct("Chicken") { weeklyEssentialsItems.append(BundleItem(product: chicken, quantity: 2)) }
        if let bananas = findProduct("Banana") { weeklyEssentialsItems.append(BundleItem(product: bananas, quantity: 2)) }
        if let apples = findProduct("Apple") { weeklyEssentialsItems.append(BundleItem(product: apples, quantity: 2)) }
        if let tomatoes = findProduct("Tomato") { weeklyEssentialsItems.append(BundleItem(product: tomatoes, quantity: 2)) }
        if let carrots = findProduct("Carrot") { weeklyEssentialsItems.append(BundleItem(product: carrots, quantity: 2)) }
        if let broccoli = findProduct("Broccoli") { weeklyEssentialsItems.append(BundleItem(product: broccoli, quantity: 2)) }
        if let cheese = findProduct("Cheese") { weeklyEssentialsItems.append(BundleItem(product: cheese, quantity: 1)) }
        if let yogurt = findProduct("Yogurt") { weeklyEssentialsItems.append(BundleItem(product: yogurt, quantity: 2)) }
        if let oil = findProduct("Oil") { weeklyEssentialsItems.append(BundleItem(product: oil, quantity: 1)) }
        if let rice = findProduct("Rice") { weeklyEssentialsItems.append(BundleItem(product: rice, quantity: 1)) }
        if let pasta = findProduct("Pasta") { weeklyEssentialsItems.append(BundleItem(product: pasta, quantity: 1)) }
        if let potatoes = findProduct("Potato") { weeklyEssentialsItems.append(BundleItem(product: potatoes, quantity: 2)) }
        if let bagels = findProduct("Bagels") { weeklyEssentialsItems.append(BundleItem(product: bagels, quantity: 1)) }
        if let salmon = findProduct("Salmon") { weeklyEssentialsItems.append(BundleItem(product: salmon, quantity: 1)) }
        
        let weeklyEssentials = SavedBundle(
            name: "Weekly Essentials",
            items: weeklyEssentialsItems,
            createdAt: Date().addingTimeInterval(-86400 * 3) // 3 days ago
        )
        
        // Taco Night Bundle
        var tacoNightItems: [BundleItem] = []
        if let beef = findProduct("Beef") { tacoNightItems.append(BundleItem(product: beef, quantity: 1)) }
        if let cheese = findProduct("Cheese") { tacoNightItems.append(BundleItem(product: cheese, quantity: 1)) }
        if let lemon = findProduct("Lemon") { tacoNightItems.append(BundleItem(product: lemon, quantity: 2)) }
        if let tomatoes = findProduct("Tomato") { tacoNightItems.append(BundleItem(product: tomatoes, quantity: 2)) }
        if let spinach = findProduct("Spinach") { tacoNightItems.append(BundleItem(product: spinach, quantity: 1)) }
        if let peppers = findProduct("Pepper") { tacoNightItems.append(BundleItem(product: peppers, quantity: 2)) }
        if let yogurt = findProduct("Yogurt") { tacoNightItems.append(BundleItem(product: yogurt, quantity: 1)) }
        if let chips = findProduct("Chips") { tacoNightItems.append(BundleItem(product: chips, quantity: 1)) }
        
        let tacoNight = SavedBundle(
            name: "Taco Night",
            items: tacoNightItems,
            createdAt: Date().addingTimeInterval(-86400 * 1)
        )
        
        savedBundles = [studySnacks, weeklyEssentials, tacoNight]
        saveBundlesToDisk()
    }
}
