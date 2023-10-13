import 'package:flutter/material.dart';

void main() {
  runApp(ShoppingCardWidget());
}

class Product {
  String name;
  double price;
  int quantity;

  Product(this.name, this.price, this.quantity);
}

class Customer {
  String name;

  Customer(this.name);
}

class ShoppingCardWidget extends StatefulWidget {
  @override
  _ShoppingCardWidgetState createState() => _ShoppingCardWidgetState();
}

class _ShoppingCardWidgetState extends State<ShoppingCardWidget> {
  String selectedCustomer = 'Default';
  List<Customer> customers = [
    Customer('Default'),
    Customer('Microsoft'),
    Customer('Amazon'),
    Customer('Facebook'),
  ];

  List<Product?> cart = [];

  Product? findProductInCart(String productName) {
    return cart.firstWhere(
      (item) => item?.name == productName,
      orElse: () => null,
    );
  }

  void addToCart(Product product) {
    setState(() {
      var existingProduct = findProductInCart(product.name);
      if (existingProduct != null) {
        existingProduct.quantity++;
      } else {
        product.quantity = 1;
        cart.add(product);
      }
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      var existingProduct = findProductInCart(product.name);
      if (existingProduct != null) {
        if (existingProduct.quantity > 1) {
          existingProduct.quantity--;
        } else {
          cart.remove(existingProduct);
        }
      }
    });
  }

  // double calculateTotal() {
  //   double total = 0;
  //   for (var product in cart) {
  //     total += product!.price * product.quantity;
  //   }
  //   return total;
  // }

  double calculateTotal() {
    double total = 0;
    for (var product in cart) {
      double productPrice = product!.price;
      int productQuantity = product.quantity;

      // Apply pricing rules based on the selected customer
      if (selectedCustomer == 'Microsoft' && product.name == 'Small Pizza') {
        // 3 for 2 deal for Microsoft on Small Pizzas
        productQuantity = (productQuantity ~/ 3) * 2 + (productQuantity % 3);
      } else if (selectedCustomer == 'Amazon' &&
          product.name == 'Large Pizza') {
        // Discounted price for Amazon on Large Pizza
        productPrice = 19.99;
      } else if (selectedCustomer == 'Facebook' &&
          product.name == 'Medium Pizza') {
        // 5 for 4 deal for Facebook on Medium Pizzas
        productQuantity = (productQuantity ~/ 5) * 4 + (productQuantity % 5);
      }

      total += productPrice * productQuantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Shopping Cart'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: selectedCustomer,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCustomer = newValue ?? 'Default';
                  });
                  calculateTotal();
                  setState(() {});
                },
                items: customers.map((Customer customer) {
                  return DropdownMenuItem<String>(
                    value: customer.name,
                    child: Text(customer.name),
                  );
                }).toList(),
              ),
              Text(
                'Selected Customer: $selectedCustomer',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Products',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              for (var product in [
                Product('Small Pizza', 11.99, 0),
                Product('Medium Pizza', 15.99, 0),
                Product('Large Pizza', 21.99, 0),
              ])
                ProductItem(
                  product: product,
                  addToCart: addToCart,
                  removeFromCart: removeFromCart,
                  cart: cart,
                ),
              SizedBox(height: 20),
              Text(
                'Total: \$${calculateTotal().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final Product product;
  final List<Product?> cart;
  final Function(Product) addToCart;
  final Function(Product) removeFromCart;

  ProductItem({
    required this.product,
    required this.addToCart,
    required this.removeFromCart,
    required this.cart,
  });

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    int getTotalProductCountInCart(Product product) {
      int totalCount = 0;
      for (var cartProduct in widget.cart) {
        if (cartProduct?.name == product.name) {
          totalCount += cartProduct!.quantity;
        }
      }
      return totalCount;
    }

    return Column(
      children: <Widget>[
        Text(
          '${widget.product.name} - \$${widget.product.price.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                widget.removeFromCart(widget.product);
                setState(() {});
              },
            ),
            Text(
              getTotalProductCountInCart(widget.product)?.toString() ?? '0',
              style: TextStyle(fontSize: 18),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                widget.addToCart(widget.product);
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }
}
