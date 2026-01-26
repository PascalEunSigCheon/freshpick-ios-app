import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager // Access the shared cart
    @Environment(\.dismiss) var dismiss // To close the screen
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Large Image
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                // 2. Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(product.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("$\(product.price, specifier: "%.2f") / unit")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    // Display Category with Icon
                    HStack {
                        Text(product.category.rawValue)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 5)
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 3. Add to Cart Button
                Button(action: {
                    cartManager.addToCart(product: product)
                    dismiss() // Close screen after adding
                }) {
                    Text("Add to Cart - $\(product.price, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
