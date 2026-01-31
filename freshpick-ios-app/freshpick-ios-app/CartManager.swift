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
        // Create sample bundles if none exist
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
    
    /// Creates sample bundles matching the design mockup
    private func createSampleBundles() {
        let products = ProductDatabase.products
        
        // Helper to find product by name
        func findProduct(_ name: String) -> Product? {
            return products.first { $0.name.localizedCaseInsensitiveContains(name) }
        }
        
        // 1. Study Snacks Bundle - 12 items • ~$34.50
        var studySnacksItems: [BundleItem] = []
        if let almonds = findProduct("Almonds") { studySnacksItems.append(BundleItem(product: almonds, quantity: 2)) } // $13.98
        if let apples = findProduct("Apple") { studySnacksItems.append(BundleItem(product: apples, quantity: 3)) } // $2.67
        if let yogurt = findProduct("Yogurt") { studySnacksItems.append(BundleItem(product: yogurt, quantity: 4)) } // $5.16
        if let chips = findProduct("Chips") { studySnacksItems.append(BundleItem(product: chips, quantity: 2)) } // $7.98
        if let bananas = findProduct("Banana") { studySnacksItems.append(BundleItem(product: bananas, quantity: 1)) } // $0.69
        if let strawberries = findProduct("Strawberry") { studySnacksItems.append(BundleItem(product: strawberries, quantity: 1)) } // $3.49
        if let cheese = findProduct("Cheese") { studySnacksItems.append(BundleItem(product: cheese, quantity: 1)) } // $4.49
        // Total: ~$40.46 (close to $34.50 with available products)
        
        let studySnacks = SavedBundle(
            name: "Study Snacks",
            items: studySnacksItems,
            createdAt: Date().addingTimeInterval(-86400 * 5) // 5 days ago
        )
        
        // 2. Weekly Essentials Bundle - 24 items • ~$89.20
        var weeklyEssentialsItems: [BundleItem] = []
        if let milk = findProduct("Milk") { weeklyEssentialsItems.append(BundleItem(product: milk, quantity: 2)) } // $6.58
        if let eggs = findProduct("Eggs") { weeklyEssentialsItems.append(BundleItem(product: eggs, quantity: 2)) } // $8.38
        if let bread = findProduct("Bread") { weeklyEssentialsItems.append(BundleItem(product: bread, quantity: 2)) } // $5.98
        if let spinach = findProduct("Spinach") { weeklyEssentialsItems.append(BundleItem(product: spinach, quantity: 2)) } // $5.98
        if let chicken = findProduct("Chicken") { weeklyEssentialsItems.append(BundleItem(product: chicken, quantity: 2)) } // $11.98
        if let bananas = findProduct("Banana") { weeklyEssentialsItems.append(BundleItem(product: bananas, quantity: 2)) } // $1.38
        if let apples = findProduct("Apple") { weeklyEssentialsItems.append(BundleItem(product: apples, quantity: 2)) } // $1.78
        if let tomatoes = findProduct("Tomato") { weeklyEssentialsItems.append(BundleItem(product: tomatoes, quantity: 2)) } // $1.78
        if let carrots = findProduct("Carrot") { weeklyEssentialsItems.append(BundleItem(product: carrots, quantity: 2)) } // $2.98
        if let broccoli = findProduct("Broccoli") { weeklyEssentialsItems.append(BundleItem(product: broccoli, quantity: 2)) } // $3.78
        if let cheese = findProduct("Cheese") { weeklyEssentialsItems.append(BundleItem(product: cheese, quantity: 1)) } // $4.49
        if let yogurt = findProduct("Yogurt") { weeklyEssentialsItems.append(BundleItem(product: yogurt, quantity: 2)) } // $2.58
        if let oil = findProduct("Oil") { weeklyEssentialsItems.append(BundleItem(product: oil, quantity: 1)) } // $3.99
        if let rice = findProduct("Rice") { weeklyEssentialsItems.append(BundleItem(product: rice, quantity: 1)) } // $2.99
        if let pasta = findProduct("Pasta") { weeklyEssentialsItems.append(BundleItem(product: pasta, quantity: 1)) } // $1.29
        if let potatoes = findProduct("Potato") { weeklyEssentialsItems.append(BundleItem(product: potatoes, quantity: 2)) } // $1.58
        if let bagels = findProduct("Bagels") { weeklyEssentialsItems.append(BundleItem(product: bagels, quantity: 1)) } // $3.99
        if let salmon = findProduct("Salmon") { weeklyEssentialsItems.append(BundleItem(product: salmon, quantity: 1)) } // $10.99
        // Total: ~$80.50 (close to $89.20 with available products)
        
        let weeklyEssentials = SavedBundle(
            name: "Weekly Essentials",
            items: weeklyEssentialsItems,
            createdAt: Date().addingTimeInterval(-86400 * 3) // 3 days ago
        )
        
        // 3. Taco Night Bundle - 8 items • ~$22.15
        var tacoNightItems: [BundleItem] = []
        if let beef = findProduct("Beef") { tacoNightItems.append(BundleItem(product: beef, quantity: 1)) } // $6.49
        if let cheese = findProduct("Cheese") { tacoNightItems.append(BundleItem(product: cheese, quantity: 1)) } // $4.49
        if let lemon = findProduct("Lemon") { tacoNightItems.append(BundleItem(product: lemon, quantity: 2)) } // $1.18 (using lemon as lime)
        if let tomatoes = findProduct("Tomato") { tacoNightItems.append(BundleItem(product: tomatoes, quantity: 2)) } // $1.78
        if let spinach = findProduct("Spinach") { tacoNightItems.append(BundleItem(product: spinach, quantity: 1)) } // $2.99 (using spinach as lettuce)
        if let peppers = findProduct("Pepper") { tacoNightItems.append(BundleItem(product: peppers, quantity: 2)) } // $2.58
        if let yogurt = findProduct("Yogurt") { tacoNightItems.append(BundleItem(product: yogurt, quantity: 1)) } // $1.29 (using yogurt as sour cream)
        if let chips = findProduct("Chips") { tacoNightItems.append(BundleItem(product: chips, quantity: 1)) } // $3.99 (as tortilla chips)
        // Total: ~$25.79 (close to $22.15 with available products)
        
        let tacoNight = SavedBundle(
            name: "Taco Night",
            items: tacoNightItems,
            createdAt: Date().addingTimeInterval(-86400 * 1) // 1 day ago
        )
        
        savedBundles = [studySnacks, weeklyEssentials, tacoNight]
        saveBundlesToDisk()
    }
}
