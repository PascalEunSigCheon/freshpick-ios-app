import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        TabView {
            //Tab 1: The Store
            HomeView()
                .tabItem {
                    Label("Shop", systemImage: "storefront")
                }
            
            //Tab 2: Bundles (We will build this next)
            Text("Bundles Screen") // Placeholder
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            //Tab 3: Cart (We will build this last)
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .badge(cartManager.cartItems.reduce(0) { $0 + $1.quantity })
        }
        .accentColor(.green) // Main app color
    }
}

#Preview {
    ContentView()
}
