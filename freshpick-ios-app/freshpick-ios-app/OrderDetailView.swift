import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order #\(order.id.uuidString.prefix(4))")
                        .font(.title2).bold()
                    
                    Text("Placed on \(order.date.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Status:")
                        Text(order.status.rawValue.capitalized)
                            .bold()
                            .foregroundColor(statusColor)
                    }
                    
                    StatusProgressBar(status: order.status)
                        .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("Items") {
                ForEach(order.items) { item in
                    HStack {
                        Text("\(item.quantity)x")
                            .font(.headline)
                            .frame(width: 30)
                            .foregroundColor(.gray)
                        
                        Text(item.product.name)
                        
                        Spacer()
                        

                        Text("$\(item.frozenPrice * Double(item.quantity), specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("$\(order.totalAmount, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            if order.status == .ready {
                Section {
                    Button(action: {
                        completeOrder()
                    }) {
                        HStack {
                            Spacer()
                            Text("I'm Here / Pick Up Order")
                                .bold()
                            Spacer()
                        }
                    }
                    .tint(.green)
                    .listRowBackground(Color.green.opacity(0.1))
                }
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusColor: Color {
        switch order.status {
        case .ready: return .green
        case .completed: return .gray
        default: return .blue
        }
    }
    
    private func completeOrder() {
        if let index = cartManager.pastOrders.firstIndex(where: { $0.id == order.id }) {
            withAnimation {
                cartManager.pastOrders[index].status = .completed
            }
            dismiss() // Go back to profile after pickup
        }
    }
}
