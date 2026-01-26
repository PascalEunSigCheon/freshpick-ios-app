import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cartManager: CartManager
    
    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil // nil means "All"
    
    // Grid Layout: 2 columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Filtering logic
    var filteredProducts: [Product] {
        // Start with all products
        var products = ProductDatabase.products
        
        // Filter by Category (if one is selected)
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        // Filter by Search Text (if not empty)
        if !searchText.isEmpty {
            products = products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return products
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - CATEGORY FILTER ROW
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // "All" Button
                        CategoryPill(title: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                            withAnimation { selectedCategory = nil }
                        }
                        
                        // Dynamic Category Buttons
                        ForEach(Category.allCases) { category in
                            CategoryPill(title: category.rawValue, icon: category.iconName, isSelected: selectedCategory == category) {
                                withAnimation { selectedCategory = category }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
                // MARK: - PRODUCT GRID
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCard(product: product)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("FreshPick")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search groceries..."
            )
        }
    }
}

// MARK: - SUBVIEWS (To keep main code clean)

// The Filter Button Design
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.green : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

// The Product Grid Item Design
struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area (Centered)
            ZStack {
                Color.white
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            }
            
            // Footer (Name/Price on Left, Button on Right)
            HStack(alignment: .bottom) {
                
                // Left Side: Text Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right Side: The Button
                Button(action: {
                    withAnimation {
                        cartManager.addToCart(product: product)
                    }
                }) {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 1, y: 2)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
