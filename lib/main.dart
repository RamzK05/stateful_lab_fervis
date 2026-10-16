
import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CartScreen(),
      ),
    );

// App colors
const Color teal = Color(0xFF117F87);
const Color darkTeal = Color(0xFF095B63);
const Color pageColor = Color(0xFFF3F8F9);
const Color borderColor = Color(0xFFDCE8EA);

// Model representing a shopping cart item
class CartItem {
  String name;
  double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// Main shopping cart screen
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Cart data and input controllers
  final List<CartItem> _items = [];
  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _priceController =
      TextEditingController();

  // Validation error messages
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();

    // Preload sample shopping items
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(
        name: 'Eggs',
        price: 8.00,
        quantity: 12,
        gotIt: true,
      ),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  // Calculate the total price of all items
  double get _total {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  // Count items marked as got it
  int get _gotItCount =>
      _items.where((item) => item.gotIt).length;

  // Increase quantity, up to a maximum of 99
  void _increase(int index) {
    setState(() {
      if (_items[index].quantity < 99) {
        _items[index].quantity++;
      }
    });
  }

  // Decrease quantity, with a minimum of 1
  void _decrease(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      }
    });
  }

  // Toggle the got-it checkbox
  void _toggle(int index, bool? value) {
    setState(() {
      _items[index].gotIt = value ?? false;
    });
  }

  // Validate and add a new item
  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    setState(() {
      _nameError =
          name.isEmpty ? 'Enter an item name' : null;

      _priceError =
          price == null || price <= 0
              ? 'Enter a price greater than 0'
              : null;
    });

    // Stop if either input is invalid
    if (_nameError != null || _priceError != null) {
      return;
    }

    setState(() {
      _items.add(
        CartItem(
          name: name,
          price: price!,
        ),
      );

      // Clear the fields after adding successfully
      _nameController.clear();
      _priceController.clear();
      _nameError = null;
      _priceError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to your cart.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Remove checked items and give feedback to the user
  void _clearChecked() {
    final checkedCount =
        _items.where((item) => item.gotIt).length;

    if (checkedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No checked items to remove.'),
        ),
      );
      return;
    }

    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$checkedCount checked item(s) removed.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Release both text controllers
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text(
          'Mini Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Shopping cart list
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('Your shopping cart is empty'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return CartItemTile(
                          item: _items[index],
                          onIncrease: () => _increase(index),
                          onDecrease: () => _decrease(index),
                          onToggle: (value) =>
                              _toggle(index, value),
                        );
                      },
                    ),
            ),

            // Cart summary and add-item form
            _buildSummary(),
            _buildAddForm(),
          ],
        ),
      ),
    );
  }

  // Display the number of items and the current total
  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFF0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Items: ${_items.length} • Got it: $_gotItCount',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            'Total: PHP ${_total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: darkTeal,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Form for adding new shopping items
  Widget _buildAddForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Item name input
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameController,
                  onChanged: (value) {
                    if (_nameError != null) {
                      setState(() {
                        _nameError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Price input
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _priceController,
                  onChanged: (value) {
                    if (_priceError != null) {
                      setState(() {
                        _priceError = null;
                      });
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '₱ ',
                    errorText: _priceError,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Add and clear-checked buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearChecked,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: teal,
                    side: const BorderSide(color: teal),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                  child: const Text('Clear checked'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stateless widget for displaying one cart item
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<bool?> onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Checkbox for marking an item as collected
            Checkbox(
              value: item.gotIt,
              activeColor: teal,
              onChanged: onToggle,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.gotIt
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _QuantityButton(
              icon: Icons.remove,
              onPressed: onDecrease,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _QuantityButton(
              icon: Icons.add,
              onPressed: onIncrease,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// Reusable stateless button for quantity changes
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: teal,
          side: const BorderSide(color: teal),
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 17),
      ),
    );
  }
}
