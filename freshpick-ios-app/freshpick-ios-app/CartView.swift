import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    @State private var pickupDate: Date = Date()
    @State private var selectedFulfillment: FulfillmentMethod = .pickup
    @State private var selectedTipPercent: Double = 0.0
    @State private var showOrderConfirmation: Bool = false
    
    @State private var lastOrderTotal: Double = 0.0
    
    @State private var deliveryAddress: String = ""
    @State private var selectedStore: String = "Campus Main Branch"
    let storeLocations = ["Campus Main Branch", "Science Library Kiosk", "Dorm A Lobby"]
    
    enum FulfillmentMethod: String, CaseIterable {
        case pickup = "Pickup"
        case delivery = "Delivery"
    }
    
    // MARK: - Price Calculations
    private var itemsTotal: Double { cartManager.cartTotal }
    
    private var deliveryFee: Double {
        selectedFulfillment == .delivery ? 5.99 : 0.0
    }
    
    private var serviceFee: Double {
        itemsTotal > 0 ? 2.50 : 0.0
    }
    
    private var smallOrderFee: Double {
        (itemsTotal > 0 && itemsTotal < 15.0) ? 1.99 : 0.0
    }
    
    private var tax: Double {
        itemsTotal * 0.08
    }
    
    private var tip: Double {
        itemsTotal * selectedTipPercent
    }
    
    private var grandTotal: Double {
        itemsTotal + deliveryFee + serviceFee + smallOrderFee + tax + tip
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // MARK: - Items Header
                            HStack {
                                Text("Items (\(cartManager.cartItems.reduce(0) { $0 + $1.quantity }))")
                                    .font(.headline).foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal).padding(.top, 12)
                            
                            // MARK: - Cart Items List
                            VStack(spacing: 12) {
                                ForEach(cartManager.cartItems) { item in
                                    CartItemRow(cartItem: item)
                                        .environmentObject(cartManager)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Fulfillment Details
                            fulfillmentDetailsCard.padding(.horizontal)
                            
                            // MARK: - Summary Card
                            summaryCard.padding(.horizontal).padding(.bottom, 16)
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
                Text("Total charged: \(lastOrderTotal.formatted(.currency(code: "USD")))")
            }
        }
    }
    
    // MARK: - Subviews
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                HStack { Text("Items Total").foregroundColor(.secondary); Spacer(); Text(formatMoney(itemsTotal)) }
                
                if deliveryFee > 0 {
                    HStack { Text("Delivery Fee").foregroundColor(.secondary); Spacer(); Text(formatMoney(deliveryFee)) }
                }
                
                if serviceFee > 0 {
                    HStack { Text("Service Fee").foregroundColor(.secondary); Spacer(); Text(formatMoney(serviceFee)) }
                }
                
                if smallOrderFee > 0 {
                    HStack { Text("Small Order Fee").foregroundColor(.secondary); Spacer(); Text(formatMoney(smallOrderFee)) }
                }
                
                HStack { Text("Tax (8%)").foregroundColor(.secondary); Spacer(); Text(formatMoney(tax)) }
                
                if tip > 0 {
                    HStack { Text("Tip").foregroundColor(.secondary); Spacer(); Text(formatMoney(tip)) }
                }
            }
            
            Divider().padding(.vertical, 4)
            
            HStack {
                Text("Total").font(.headline)
                Spacer()
                Text(formatMoney(grandTotal)).font(.headline).foregroundColor(.green)
            }
        }
        .padding(18).background(Color.white).cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var fulfillmentDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Details").font(.headline).foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Method").font(.caption).foregroundColor(.secondary)
                    Picker("Fulfillment", selection: $selectedFulfillment) {
                        Text("Pickup").tag(FulfillmentMethod.pickup)
                        Text("Delivery").tag(FulfillmentMethod.delivery)
                    }
                    .pickerStyle(.segmented)
                }
                
                if selectedFulfillment == .delivery {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Delivery Address").font(.caption).foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "mappin.and.ellipse").foregroundColor(.red)
                            TextField("Enter your address", text: $deliveryAddress)
                        }
                        .padding(12).background(Color(.secondarySystemBackground)).cornerRadius(12)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Store").font(.caption).foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "building.2.fill").foregroundColor(.blue)
                            Picker("Store", selection: $selectedStore) {
                                ForEach(storeLocations, id: \.self) { store in
                                    Text(store).tag(store)
                                }
                            }
                            .labelsHidden()
                            Spacer()
                        }
                        .padding(8).background(Color(.secondarySystemBackground)).cornerRadius(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Contact Name").font(.caption).foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "person.fill").foregroundColor(.green)
                        Text(cartManager.currentUser.name).bold()
                        Spacer()
                        Image(systemName: "lock.fill").font(.caption).foregroundColor(.secondary)
                    }
                    .padding(12).background(Color(.secondarySystemBackground)).cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedFulfillment == .delivery ? "Estimated Arrival" : "Pickup Time")
                        .font(.caption).foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "clock").foregroundColor(.gray)
                        DatePicker("", selection: $pickupDate, displayedComponents: [.hourAndMinute]).labelsHidden()
                    }
                    .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Driver Tip").font(.caption).foregroundColor(.secondary)
                    Picker("Tip", selection: $selectedTipPercent) {
                        Text("0%").tag(0.0)
                        Text("10%").tag(0.10)
                        Text("15%").tag(0.15)
                        Text("20%").tag(0.20)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .padding(18).background(Color.white).cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var bottomBar: some View {
        VStack {
            Button(action: placeOrder) {
                HStack {
                    Text(selectedFulfillment == .delivery ? "Place Delivery" : "Place Pickup")
                        .font(.headline)
                    Spacer()
                    Text(formatMoney(grandTotal)).font(.headline)
                }
                .foregroundColor(.white).padding().frame(maxWidth: .infinity)
                .background(placeOrderDisabled ? Color.gray : Color.green)
                .cornerRadius(18)
            }
            .disabled(placeOrderDisabled)
            .padding(.horizontal).padding(.top, 6).padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea(edges: .bottom))
    }
    
    // MARK: - Actions
    private var placeOrderDisabled: Bool {
        if cartManager.cartItems.isEmpty { return true }
        if selectedFulfillment == .delivery && deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - FIXED PLACE ORDER FUNCTION
    private func placeOrder() {
        guard !placeOrderDisabled else { return }
        
        lastOrderTotal = grandTotal
        
        let locationString = selectedFulfillment == .delivery ? "Delivery: \(deliveryAddress)" : "Pickup: \(selectedStore)"
        
        cartManager.placeOrder(
            pickupTime: pickupDate,
            storeLocation: locationString,
            itemsTotal: itemsTotal,
            deliveryFee: deliveryFee,
            smallOrderFee: smallOrderFee,
            tax: tax,
            tip: tip,
            grandTotal: grandTotal
        )
        
        showOrderConfirmation = true
    }
    
    private func formatMoney(_ value: Double) -> String {
        return value.formatted(.currency(code: "USD"))
    }
}

// MARK: - Cart Item Row
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
