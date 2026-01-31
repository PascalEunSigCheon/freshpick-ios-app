import SwiftUI

struct BundlesView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCreateBundle = false
    @State private var editingBundle: SavedBundle? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: - Create New Bundle Button
                            createBundleButton
                                .padding(.horizontal)
                                .padding(.top, 12)
                            
                            // MARK: - Section Header
                            HStack {
                                Text("Your Saved Bundles")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Bundle Cards
                            if cartManager.savedBundles.isEmpty {
                                emptyStateView
                                    .padding(.top, 40)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(cartManager.savedBundles) { bundle in
                                        BundleCard(
                                            bundle: bundle,
                                            onEdit: {
                                                editingBundle = bundle
                                                showCreateBundle = true
                                            }
                                        )
                                        .environmentObject(cartManager)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Smart Bundles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateBundle) {
                if let bundle = editingBundle {
                    CreateBundleView(bundle: bundle)
                        .environmentObject(cartManager)
                        .onDisappear {
                            editingBundle = nil
                        }
                } else {
                    CreateBundleView()
                        .environmentObject(cartManager)
                }
            }
        }
    }
    
    // MARK: - Create Bundle Button
    private var createBundleButton: some View {
        Button(action: {
            editingBundle = nil
            showCreateBundle = true
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Create New Bundle")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No bundles yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Create your first bundle to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Bundle Card
struct BundleCard: View {
    let bundle: SavedBundle
    let onEdit: () -> Void
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Header
            ZStack(alignment: .topTrailing) {
                // Use first item's image, or a default
                if let firstItem = bundle.items.first {
                    Image(firstItem.product.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 180)
                }
                
                // Edit Icon
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Title and Details
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(bundle.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Text("\(bundle.items.count) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(bundle.totalPrice, format: .currency(code: "USD"))
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                }
                
                // Item List Preview
                Text(bundle.itemsPreview)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Add All to Cart Button
                Button(action: {
                    cartManager.addBundleToCart(bundle)
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 14))
                        Text("Add All to Cart")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - SavedBundle Extensions
extension SavedBundle {
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    var itemsPreview: String {
        let itemNames = items.map { $0.product.name }
        let preview = itemNames.prefix(6).joined(separator: ", ")
        if itemNames.count > 6 {
            return preview + "..."
        }
        return preview
    }
}

// MARK: - Create Bundle View
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section("Bundle Name") {
                        TextField("Enter bundle name", text: $bundleName)
                    }
                    
                    Section("Add Products") {
                        ForEach(ProductDatabase.products) { product in
                            ProductSelectionRow(
                                product: product,
                                quantity: productQuantities[product.id] ?? 0,
                                onQuantityChange: { newQuantity in
                                    if newQuantity > 0 {
                                        productQuantities[product.id] = newQuantity
                                        if !selectedProducts.contains(where: { $0.id == product.id }) {
                                            selectedProducts.append(product)
                                        }
                                    } else {
                                        productQuantities.removeValue(forKey: product.id)
                                        selectedProducts.removeAll { $0.id == product.id }
                                    }
                                }
                            )
                        }
                    }
                }
                
                // Save Button
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let bundle = bundle {
                    bundleName = bundle.name
                    selectedProducts = bundle.items.map { $0.product }
                    productQuantities = Dictionary(uniqueKeysWithValues: bundle.items.map { ($0.product.id, $0.quantity) })
                }
            }
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
            // Update existing bundle - create new instance since SavedBundle is a struct
            if let index = cartManager.savedBundles.firstIndex(where: { $0.id == existingBundle.id }) {
                var updatedBundle = cartManager.savedBundles[index]
                updatedBundle.name = bundleName
                updatedBundle.items = bundleItems
                cartManager.savedBundles[index] = updatedBundle
                cartManager.saveBundlesToDisk()
            }
        } else {
            // Create new bundle
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

// MARK: - Product Selection Row
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
                }
                
                Text("\(quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: {
                    onQuantityChange(quantity + 1)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

