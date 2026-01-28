import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    // Pickup details
    @State private var pickupName: String = ""
    @State private var pickupDate: Date = Date()
    
    @State private var showOrderConfirmation: Bool = false
    
    // Simple flat service fee to match the mock
    private let serviceFee: Double = 2.50
    
    private var itemsTotal: Double {
        cartManager.cartTotal
    }
    
    private var subtotal: Double {
        itemsTotal + (itemsTotal > 0 ? serviceFee : 0)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // MARK: - Items Header
                            HStack {
                                Text("Items (\(cartManager.cartItems.reduce(0) { $0 + $1.quantity }))")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                            
                            // MARK: - Cart Items
                            VStack(spacing: 12) {
                                ForEach(cartManager.cartItems) { item in
                                    CartItemRow(cartItem: item)
                                        .environmentObject(cartManager)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Summary Card
                            summaryCard
                                .padding(.horizontal)
                            
                            // MARK: - Pickup Details
                            pickupDetailsCard
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                        }
                    }
                    
                    // MARK: - Bottom Place Order Bar
                    bottomBar
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Order Placed", isPresented: $showOrderConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your order is being processed and will be ready for pickup soon.")
            }
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Items Total")
                    .foregroundColor(.secondary)
                Spacer()
                Text(itemsTotal, format: .currency(code: "USD"))
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Service Fee")
                    .foregroundColor(.secondary)
                Spacer()
                Text(itemsTotal > 0 ? serviceFee : 0, format: .currency(code: "USD"))
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            HStack {
                Text("Subtotal")
                    .font(.headline)
                Spacer()
                Text(subtotal, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Pickup Details Card
    private var pickupDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pickup Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                // Pickup name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pickup Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                        TextField("Who's picking this up?", text: $pickupName)
                            .textInputAutocapitalization(.words)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Pickup schedule
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pickup Schedule")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        // Date
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            DatePicker(
                                "",
                                selection: $pickupDate,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                        }
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Time
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            DatePicker(
                                "",
                                selection: $pickupDate,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                        }
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 8) {
            Button(action: placeOrder) {
                HStack {
                    Text("Place Order")
                        .font(.headline)
                    Spacer()
                    Text(subtotal, format: .currency(code: "USD"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(cartManager.cartItems.isEmpty ? Color.gray : Color.green)
                .cornerRadius(18)
            }
            .disabled(cartManager.cartItems.isEmpty)
            .padding(.horizontal)
            .padding(.top, 6)
            .padding(.bottom, 8)
        }
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Actions
    private func placeOrder() {
        guard !cartManager.cartItems.isEmpty else { return }
        
        let name = pickupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = name.isEmpty ? "Guest" : name
        
        cartManager.placeOrder(
            userName: finalName,
            pickupTime: pickupDate,
            storeLocation: "FreshPick Market"
        )
        
        pickupName = ""
        pickupDate = Date()
        showOrderConfirmation = true
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let cartItem: CartItem
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            Image(cartItem.product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(14)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(cartItem.product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("$\(cartItem.product.price, specifier: "%.2f") / unit")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity Controls
            HStack(spacing: 12) {
                quantityButton(systemName: "minus") {
                    let newQuantity = cartItem.quantity - 1
                    cartManager.updateQuantity(cartItemID: cartItem.id, newQuantity: newQuantity)
                }
                
                Text("\(cartItem.quantity)")
                    .font(.headline)
                    .frame(minWidth: 22)
                
                quantityButton(systemName: "plus") {
                    let newQuantity = cartItem.quantity + 1
                    cartManager.updateQuantity(cartItemID: cartItem.id, newQuantity: newQuantity)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    private func quantityButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 32, height: 32)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

