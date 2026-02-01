import SwiftUI

struct CreateBundleView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    
    let bundle: SavedBundle?
    
    @State private var bundleName: String = ""
    @State private var selectedProducts: [Product] = []
    @State private var productQuantities: [UUID: Int] = [:]
    
    init(bundle: SavedBundle? = nil) {
        self.bundle = bundle
    }
    
    // MARK: - Sorted Products Logic (Fixed for Compiler)
    var sortedProducts: [Product] {
        return ProductDatabase.products.sorted { p1, p2 in
            let q1 = productQuantities[p1.id] ?? 0
            let q2 = productQuantities[p2.id] ?? 0
            
            let isP1Selected = q1 > 0
            let isP2Selected = q2 > 0
            
            if isP1Selected && !isP2Selected { return true }
            if !isP1Selected && isP2Selected { return false }
            
            return p1.name < p2.name
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section("Bundle Name") {
                        TextField("Enter bundle name", text: $bundleName)
                    }
                    
                    Section("Add Products") {
                        ForEach(sortedProducts) { product in
                            ProductSelectionRow(
                                product: product,
                                quantity: productQuantities[product.id] ?? 0,
                                onQuantityChange: { newQuantity in
                                    updateQuantity(for: product, quantity: newQuantity)
                                }
                            )
                            .listRowBackground(backgroundFor(product.id))
                        }
                    }
                }
                
                Button(action: saveBundle) {
                    Text(bundle == nil ? "Create Bundle" : "Update Bundle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSave)
                .padding()
            }
            .navigationTitle(bundle == nil ? "New Bundle" : "Edit Bundle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                loadBundleData()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func backgroundFor(_ id: UUID) -> Color {
        if (productQuantities[id] ?? 0) > 0 {
            return Color.green.opacity(0.1)
        }
        return Color.white
    }
    
    private func loadBundleData() {
        if let bundle = bundle {
            bundleName = bundle.name
            
            var newQuantities: [UUID: Int] = [:]
            var newSelected: [Product] = []
            
            for item in bundle.items {
                if let liveProduct = ProductDatabase.products.first(where: { $0.name == item.product.name }) {
                    newQuantities[liveProduct.id] = item.quantity
                    newSelected.append(liveProduct)
                }
            }
            
            self.productQuantities = newQuantities
            self.selectedProducts = newSelected
        }
    }
    
    private func updateQuantity(for product: Product, quantity: Int) {
        if quantity > 0 {
            productQuantities[product.id] = quantity
            if !selectedProducts.contains(where: { $0.id == product.id }) {
                selectedProducts.append(product)
            }
        } else {
            productQuantities.removeValue(forKey: product.id)
            selectedProducts.removeAll { $0.id == product.id }
        }
    }
    
    private var canSave: Bool {
        !bundleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedProducts.isEmpty
    }
    
    private func saveBundle() {
        guard canSave else { return }
        
        let bundleItems = selectedProducts.compactMap { product -> BundleItem? in
            guard let quantity = productQuantities[product.id], quantity > 0 else { return nil }
            return BundleItem(product: product, quantity: quantity)
        }
        
        if let existingBundle = bundle {
            if let index = cartManager.savedBundles.firstIndex(where: { $0.id == existingBundle.id }) {
                var updatedBundle = cartManager.savedBundles[index]
                updatedBundle.name = bundleName
                updatedBundle.items = bundleItems
                cartManager.savedBundles[index] = updatedBundle
                cartManager.saveBundlesToDisk()
            }
        } else {
            let newBundle = SavedBundle(
                name: bundleName,
                items: bundleItems,
                createdAt: Date()
            )
            cartManager.savedBundles.append(newBundle)
            cartManager.saveBundlesToDisk()
        }
        
        dismiss()
    }
}

// MARK: - Product Selection Row (The Missing Component)
struct ProductSelectionRow: View {
    let product: Product
    let quantity: Int
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack {
            Image(product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    onQuantityChange(max(0, quantity - 1))
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(quantity > 0 ? .green : .gray)
                        .font(.title3)
                }
                
                Text("\(quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: {
                    onQuantityChange(quantity + 1)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
