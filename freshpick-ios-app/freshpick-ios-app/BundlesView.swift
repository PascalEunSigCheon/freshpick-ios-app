import SwiftUI

enum BundleSheetType: Identifiable {
    case new
    case edit(SavedBundle)
    
    var id: String {
        switch self {
        case .new: return "new"
        case .edit(let bundle): return bundle.id.uuidString
        }
    }
}

struct BundlesView: View {
    @EnvironmentObject var cartManager: CartManager
    
    @State private var activeSheet: BundleSheetType? = nil
    
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
                                                activeSheet = .edit(bundle)
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
            
            .sheet(item: $activeSheet) { sheetType in
                switch sheetType {
                case .new:
                    CreateBundleView(bundle: nil)
                        .environmentObject(cartManager)
                case .edit(let bundle):
                    CreateBundleView(bundle: bundle)
                        .environmentObject(cartManager)
                }
            }
        }
    }
    
    // MARK: - Create Bundle Button
    private var createBundleButton: some View {
        Button(action: {
            activeSheet = .new
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

// MARK: - Bundle Card (No changes needed here, just context)
struct BundleCard: View {
    let bundle: SavedBundle
    let onEdit: () -> Void
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
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
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 12) {
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
                
                Text(bundle.itemsPreview)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Add All to Cart Button
                Button(action: {
                    withAnimation {
                        cartManager.addBundleToCart(bundle)
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
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
