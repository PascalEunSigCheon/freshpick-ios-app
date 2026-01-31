import SwiftUI

struct BundlesView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var newBundleName: String = ""

    var body: some View {
        NavigationStack {
            List {
                if !cartManager.savedBundles.isEmpty {
                    Section("Saved Bundles") {
                        ForEach(cartManager.savedBundles) { bundle in
                            bundleRow(for: bundle)
                        }
                        .onDelete(perform: cartManager.deleteBundle)
                    }
                }

                Section("Create from Cart") {
                    if cartManager.cartItems.isEmpty {
                        Text("Add items to your cart to save a bundle.")
                            .foregroundColor(.secondary)
                    } else {
                        TextField("Bundle Name", text: $newBundleName)
                        Button("Save Bundle") {
                            let trimmed = newBundleName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let name = trimmed.isEmpty ? "My Bundle" : trimmed
                            cartManager.createBundleFromCart(name: name)
                            newBundleName = ""
                        }
                    }
                }
            }
            .navigationTitle("Bundles")
        }
    }

    private func bundleRow(for bundle: SavedBundle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(bundle.name)
                    .font(.headline)
                Spacer()
                Text("\(bundle.items.count) items")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Est. \(formatMoney(estimatedPrice(for: bundle)))")
                    .foregroundColor(.secondary)
                Spacer()
                Button("Add to Cart") {
                    cartManager.addBundleToCart(bundle)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private func estimatedPrice(for bundle: SavedBundle) -> Double {
        bundle.items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    private func formatMoney(_ value: Double) -> String {
        let rounded = (value * 100).rounded() / 100
        return String(format: "$%.2f", rounded)
    }
}

#Preview {
    BundlesView()
        .environmentObject(CartManager())
}
