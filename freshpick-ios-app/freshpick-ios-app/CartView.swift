import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    @State private var pickupDate: Date = Date()
    @State private var selectedFulfillment: FulfillmentMethod = .pickup
    @State private var selectedTipPercent: Double = 0.0
    private let taxRate: Double = 0.08
    
    @State private var showOrderConfirmation: Bool = false
    
    private var itemsTotal: Double {
        cartManager.cartTotal
    }
    
    private var breakdown: PriceBreakdown {
        PricingEngine.calculate(
            itemsTotal: itemsTotal,
            fulfillment: selectedFulfillment,
            tipPercent: selectedTipPercent,
            taxRate: taxRate
        )
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
                            
                            // MARK: - Cart Items List
                            VStack(spacing: 12) {
                                ForEach(cartManager.cartItems) { item in
                                    CartItemRow(cartItem: item)
                                        .environmentObject(cartManager)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Pickup Details (Locked to Scrooge)
                            pickupDetailsCard
                                .padding(.horizontal)
                            
                            // MARK: - Summary Card
                            summaryCard
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                        }
                    }
                    
                    // MARK: - Bottom Bar
                    bottomBar
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Order Placed", isPresented: $showOrderConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Total charged: \(grandTotal.formatted(.currency(code: "USD")))")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Items Total")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatMoney(breakdown.itemsTotal))
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Delivery Fee")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatMoney(breakdown.deliveryFee))
                    .foregroundColor(.primary)
            }

            HStack {
                Text("Service Fee")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatMoney(breakdown.serviceFee))
                    .foregroundColor(.primary)
            }

            if breakdown.smallOrderFee > 0 {
                HStack {
                    Text("Small Order Fee")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatMoney(breakdown.smallOrderFee))
                        .foregroundColor(.primary)
                }
            }

            HStack {
                Text("Tax")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatMoney(breakdown.tax))
                    .foregroundColor(.primary)
            }

            HStack {
                Text("Tip")
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatMoney(breakdown.tip))
                    .foregroundColor(.primary)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(formatMoney(breakdown.grandTotal))
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var pickupDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pickup Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                // Fulfillment Method
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fulfillment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Fulfillment", selection: $selectedFulfillment) {
                        Text("Pickup").tag(FulfillmentMethod.pickup)
                        Text("Delivery").tag(FulfillmentMethod.delivery)
                    }
                    .pickerStyle(.segmented)
                }

                // Tip
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Tip", selection: $selectedTipPercent) {
                        Text("0%").tag(0.0)
                        Text("10%").tag(0.10)
                        Text("15%").tag(0.15)
                        Text("20%").tag(0.20)
                    }
                    .pickerStyle(.segmented)
                }

                // Pickup name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pickup Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Time picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Pickup Time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    
                    DatePicker("", selection: $pickupDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var bottomBar: some View {
        VStack {
            Button(action: placeOrder) {
                HStack {
                    Text("Place Order")
                        .font(.headline)
                    Spacer()
                    Text(formatMoney(breakdown.grandTotal))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(placeOrderDisabled ? Color.gray : Color.green)
                .cornerRadius(18)
            }
            .disabled(placeOrderDisabled)
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
    private var placeOrderDisabled: Bool {
        let name = pickupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return cartManager.cartItems.isEmpty || name.isEmpty
    }

    private func placeOrder() {
        guard !cartManager.cartItems.isEmpty else { return }
        
        cartManager.placeOrder(
            pickupTime: pickupDate,
            storeLocation: "FreshPick Market"
        )
        
        showOrderConfirmation = true
    }

    private func formatMoney(_ value: Double) -> String {
        let rounded = (value * 100).rounded() / 100
        return String(format: "$%.2f", rounded)
    }
}

// MARK: - Cart Item Row Helper
struct CartItemRow: View {
    let cartItem: CartItem
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(cartItem.product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(cartItem.product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("$\(cartItem.product.price, specifier: "%.2f") / unit")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    cartManager.updateQuantity(cartItemID: cartItem.id, newQuantity: cartItem.quantity - 1)
                }) {
                    Image(systemName: "minus")
                        .frame(width: 30, height: 30)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .clipShape(Circle())
                }
                
                Text("\(cartItem.quantity)")
                    .font(.headline)
                    .frame(minWidth: 20)
                
                Button(action: {
                    cartManager.updateQuantity(cartItemID: cartItem.id, newQuantity: cartItem.quantity + 1)
                }) {
                    Image(systemName: "plus")
                        .frame(width: 30, height: 30)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
