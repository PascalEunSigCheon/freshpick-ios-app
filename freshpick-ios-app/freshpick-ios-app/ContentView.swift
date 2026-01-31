import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Shop", systemImage: "storefront")
                }
            
            Text("Bundles Screen")
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .badge(cartManager.cartItems.reduce(0) { $0 + $1.quantity })
            
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
