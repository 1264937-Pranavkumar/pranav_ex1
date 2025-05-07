import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  final String name;
  final String description;
  final double price;
  final String imagePath;

  Item({
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stationery Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEAF4FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const ShoppingScreen(),
    );
  }
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<Item> allItems = [
    Item(name: 'Folder', description: 'Colorful folder', price: 1.5, imagePath: 'assets/images/folders.png'),
    Item(name: 'Notebook', description: 'A5 ruled notebook', price: 2.0, imagePath: 'assets/images/notebooks.png'),
    Item(name: 'Register', description: 'Large register', price: 3.5, imagePath: 'assets/images/registers.png'),
    Item(name: 'Stapler', description: 'Compact stapler', price: 2.8, imagePath: 'assets/images/staplers.png'),
    Item(name: 'Tape', description: 'Clear adhesive tape', price: 0.8, imagePath: 'assets/images/tapes.png'),
    Item(name: 'Paper Clip', description: 'Pack of 100', price: 1.2, imagePath: 'assets/images/paper_clips.png'),
    Item(name: 'Pen', description: 'Gel pens Black', price: 2.0, imagePath: 'assets/images/pens.png'),
    Item(name: 'Pencil', description: 'HB pencils with erasers', price: 1.0, imagePath: 'assets/images/pencils.png'),
    Item(name: 'Envelope', description: 'Pack of 10 envelopes', price: 1.5, imagePath: 'assets/images/envelopes.png'),
    Item(name: 'Printing Paper', description: 'A4 500 sheets', price: 4.5, imagePath: 'assets/images/printing_paper.png'),
  ];

  List<Item> displayedItems = [];
  final List<Item> cart = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedItems = allItems;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      displayedItems = allItems.where((item) =>
      item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query)).toList();
    });
  }

  void addToCart(Item item) {
    setState(() {
      cart.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart')),
    );
  }

  void goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cart: cart, onCheckout: clearCart),
      ),
    );
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stationery Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: goToCart,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: displayedItems.length,
              itemBuilder: (context, index) {
                final item = displayedItems[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(item.imagePath, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.description}\n\$${item.price.toStringAsFixed(2)}'),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () => addToCart(item),
                      child: const Text('Add'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Item> cart;
  final VoidCallback onCheckout;

  const CartScreen({super.key, required this.cart, required this.onCheckout});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total => widget.cart.fold(0, (sum, item) => sum + item.price);

  void checkout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Checkout Complete...\nThank you for shopping.!'),
        content: Text('Total: \$${total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onCheckout();
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: widget.cart.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final item = widget.cart[index];
                return ListTile(
                  leading: Image.asset(item.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFromCart(index),
                  ),
                );
              },
            ),
          ),
          if (widget.cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout'),
                    onPressed: checkout,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
