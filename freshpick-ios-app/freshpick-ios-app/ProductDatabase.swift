import Foundation

class ProductDatabase {
    static let products: [Product] = [
        // MARK: - Fruits
        Product(id: UUID(), name: "Fuji Apple", imageName: "apple", category: .fruits, description: "Crisp and sweet Fuji apple, perfect for snacking.", price: 0.89),
        Product(id: UUID(), name: "Organic Bananas", imageName: "banana", category: .fruits, description: "Sweet and creamy organic bananas. Price per bunch.", price: 0.69),
        Product(id: UUID(), name: "Fresh Lemon", imageName: "lemon", category: .fruits, description: "Bright and zesty lemons, great for cooking or drinks.", price: 0.59),
        Product(id: UUID(), name: "Strawberries", imageName: "strawberry", category: .fruits, description: "Fresh, juicy strawberries. 1lb container.", price: 3.49),

        // MARK: - Vegetables
        Product(id: UUID(), name: "Broccoli", imageName: "broccoli", category: .vegetables, description: "Fresh broccoli crowns, rich in vitamins.", price: 1.89),
        Product(id: UUID(), name: "Carrots", imageName: "carrot", category: .vegetables, description: "Crunchy organic carrots, 1lb bag.", price: 1.49),
        Product(id: UUID(), name: "Cucumber", imageName: "cucumber", category: .vegetables, description: "Cool and crisp cucumber, individually sold.", price: 0.99),
        Product(id: UUID(), name: "Red Bell Pepper", imageName: "pepper", category: .vegetables, description: "Sweet and crunchy red bell pepper.", price: 1.29),
        Product(id: UUID(), name: "Russet Potato", imageName: "potato", category: .vegetables, description: "Classic Russet potato, great for baking or frying.", price: 0.79),
        Product(id: UUID(), name: "Baby Spinach", imageName: "spinach", category: .vegetables, description: "Pre-washed fresh baby spinach, 10oz bag.", price: 2.99),
        Product(id: UUID(), name: "Vine Tomato", imageName: "tomato", category: .vegetables, description: "Ripe red tomatoes on the vine.", price: 0.89),

        // MARK: - Bakery
        Product(id: UUID(), name: "Bagels (4 Pack)", imageName: "bagels", category: .bakery, description: "Freshly baked plain bagels.", price: 3.99),
        Product(id: UUID(), name: "Sliced Bread", imageName: "bread", category: .bakery, description: "Whole wheat sliced bread loaf.", price: 2.99),
        Product(id: UUID(), name: "Butter Croissant", imageName: "croissant", category: .bakery, description: "Flaky, buttery, authentic croissant.", price: 2.49),
        
        // MARK: - Dairy & Eggs
        Product(id: UUID(), name: "Cheddar Cheese", imageName: "cheese", category: .dairy, description: "Sharp cheddar cheese block, 8oz.", price: 4.49),
        Product(id: UUID(), name: "Large Brown Eggs", imageName: "eggs", category: .dairy, description: "Farm fresh large brown eggs, dozen.", price: 4.19),
        Product(id: UUID(), name: "Whole Milk", imageName: "milk", category: .dairy, description: "Gallon of fresh whole milk.", price: 3.29),
        Product(id: UUID(), name: "Fruit Yogurt", imageName: "yogurt", category: .dairy, description: "Strawberry flavored greek yogurt cup.", price: 1.29),

        // MARK: - Meat & Seafood
        Product(id: UUID(), name: "Ground Beef", imageName: "beef", category: .meat, description: "Lean ground beef, 1lb pack.", price: 6.49),
        Product(id: UUID(), name: "Chicken Breast", imageName: "chicken", category: .meat, description: "Boneless skinless chicken breast, 1lb.", price: 5.99),
        Product(id: UUID(), name: "Salmon Fillet", imageName: "salmon", category: .meat, description: "Fresh Atlantic salmon fillet.", price: 10.99),

        // MARK: - Pantry
        Product(id: UUID(), name: "Cooking Oil", imageName: "oil", category: .pantry, description: "Vegetable oil for cooking and frying.", price: 3.99),
        Product(id: UUID(), name: "Dried Pasta", imageName: "pasta", category: .pantry, description: "Classic penne pasta, 16oz box.", price: 1.29),
        Product(id: UUID(), name: "White Rice", imageName: "rice", category: .pantry, description: "Long grain white rice, 2lb bag.", price: 2.99),

        // MARK: - Snacks
        Product(id: UUID(), name: "Roasted Almonds", imageName: "almonds", category: .snacks, description: "Salted roasted almonds, healthy snack.", price: 6.99),
        Product(id: UUID(), name: "Potato Chips", imageName: "chips", category: .snacks, description: "Classic salted potato chips, party size.", price: 3.99)
    ]
}
