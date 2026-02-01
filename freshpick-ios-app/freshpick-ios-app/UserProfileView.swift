import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var activeOrders: [Order] {
        cartManager.pastOrders.filter { $0.status != .completed }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // SECTION 1: USER ID CARD
                Section {
                    HStack(spacing: 15) {
                        // SCROOGE IMAGE
                        Image("scrooge") // Make sure "scrooge" is in Assets!
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.yellow, lineWidth: 3)) // Gold border
                            .shadow(radius: 3)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(cartManager.currentUser.name)
                                .font(.title3)
                                .bold()
                            Text(cartManager.currentUser.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("ID: \(cartManager.currentUser.memberID)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // SECTION 2: LIVE ORDER TRACKER
                if !activeOrders.isEmpty {
                    Section("Live Orders") {
                        ForEach(activeOrders) { order in
                            // WRAP IN NAVIGATION LINK
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack {
                                        Text("Order #\(order.id.uuidString.prefix(4))")
                                            .bold()
                                        Spacer()
                                        Text(order.storeLocation)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // STATUS BAR VISUALIZER
                                    StatusProgressBar(status: order.status)
                                    
                                    HStack {
                                        Text(order.status.rawValue.capitalized)
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.green)
                                        
                                        Spacer()
                                        
                                        // Item count preview
                                        Text("\(order.items.count) items")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("$\(order.totalAmount, specifier: "%.2f")")
                                            .font(.caption)
                                            .bold()
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                
                // SECTION 3: PREFERRED ITEMS
                Section("Saved Bundles") {
                    if cartManager.savedBundles.isEmpty {
                        Text("No saved favorites yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(cartManager.savedBundles) { bundle in
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text(bundle.name)
                                Spacer()
                                Button(action: {
                                    cartManager.addBundleToCart(bundle)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                // SECTION 4: SETTINGS
                Section("Settings") {
                    Label("Payment Methods", systemImage: "creditcard")
                    Label("Notifications", systemImage: "bell")
                    Label("Log Out", systemImage: "arrow.right.square")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
        
    func completeOrder(_ order: Order) {
        if let index = cartManager.pastOrders.firstIndex(where: { $0.id == order.id }) {
            withAnimation {
                cartManager.pastOrders[index].status = .completed
            }
        }
    }
}

// Helper: Status Bar
struct StatusProgressBar: View {
    let status: OrderStatus
    
    var progress: Double {
        switch status {
        case .processing: return 0.33
        case .packing: return 0.66
        case .ready: return 1.0
        case .completed: return 1.0
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.2))
                
                Capsule()
                    .frame(width: geo.size.width * progress, height: 8)
                    .foregroundColor(status == .ready ? .green : .blue)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 8)
    }
}
