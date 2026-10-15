struct Favorite {
    let imageName: String
    let title: String
    let description: String
}

extension Favorite {
    static let all: [Favorite] = [
        Favorite(imageName: "pizza", title: "Pizza", description: "Thin crust, lots of mozzarella and fresh basil. Perfect for movie night."),
        Favorite(imageName: "sushi", title: "Sushi", description: "Fresh salmon nigiri with a little wasabi and soy sauce."),
        Favorite(imageName: "burger", title: "Burger", description: "Juicy beef patty, cheddar, pickles and a soft brioche bun."),
        Favorite(imageName: "ramen", title: "Ramen", description: "Rich tonkotsu broth, chewy noodles and a soft-boiled egg."),
        Favorite(imageName: "tacos", title: "Tacos", description: "Crispy tortillas with spicy chicken, salsa and a squeeze of lime."),
        Favorite(imageName: "pancakes", title: "Pancakes", description: "A fluffy stack with maple syrup and berries for a slow Sunday."),
        Favorite(imageName: "croissant", title: "Croissant", description: "Buttery and flaky, best with a cup of hot coffee."),
        Favorite(imageName: "steak", title: "Steak", description: "Medium-rare ribeye with garlic butter and rosemary."),
        Favorite(imageName: "icecream", title: "Ice Cream", description: "Vanilla soft serve, the best cure for a hot summer day."),
        Favorite(imageName: "manti", title: "Manti", description: "Steamed dumplings with juicy meat and onions, served with sour cream."),
    ]
}
