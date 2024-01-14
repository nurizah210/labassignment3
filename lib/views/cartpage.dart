import 'dart:convert';
import 'package:bookbytes/shared/mydrawer.dart';
import 'package:bookbytes/models/cart.dart';
import 'package:bookbytes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared/myserverconfig.dart';

class CartPage extends StatefulWidget {
  final User userdata;

  const CartPage({super.key, required this.userdata});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Cart> cartList = <Cart>[];
  double total = 0.0;
  String title = "";

  @override
  void initState() {
    super.initState();
    loadUserCart(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 126, 171),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("My Cart")],
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearchDialog();
              },
              icon: const Icon(Icons.search))
        ],
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      drawer: MyDrawer(
        page: "cart",
        userdata: widget.userdata,
      ),
      body: cartList.isEmpty
          ? const Center(
              child: Text("No Data"),
            )
          : Column(children: [
              Expanded(
                child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        background: Container(
                          color: Colors.red,
                          child: Row(children: [
                            IconButton(
                                onPressed: () {
                                  removeFromCart(index);
                                },
                                icon: const Icon(Icons.delete)),
                            IconButton(
                                onPressed: () {
                                  updateQuantity(index);
                                },
                                icon: const Icon(Icons.update))
                          ]),
                        ),
                        key: Key(cartList[index].bookId.toString()),
                        child: ListTile(
                            title: Text(cartList[index].bookTitle.toString()),
                            onTap: () async {},
                            subtitle: Text("RM ${cartList[index].bookPrice}"),
                            leading: const Icon(Icons.sell),
                            trailing: Text(" ${cartList[index].cartQty} unit")),
                        onDismissed: (direction) {
                          if (cartList[index].cartQty != 0) {
                            removeFromCart(index);
                          }
                        },
                      );
                    }),
              ),
              Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*Text(
                        "SUBTOTAL RM ${calculateTotalPrice(cartList).toStringAsFixed(2)}",
                       style: const TextStyle(
                           fontSize: 20, fontWeight: FontWeight.bold),
                      ),*/
                      ElevatedButton(
                          onPressed: () {}, child: const Text("Pay Now"))
                    ],
                  )),
              Text(
                "Total Items in Cart: ${calculateTotalItems()}",
                style: const TextStyle(fontSize: 16),
              ),
            ]),
    );
  }

  void loadUserCart(String title) {
    String userid = widget.userdata.userid.toString();
    http
        .get(
      Uri.parse(
          "${MyServerConfig.server}/bookbytes/php/load_cart.php?userid=$userid"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          cartList.clear();
          var totalperitem;
          data['data']['carts'].forEach((v) {
            cartList.add(Cart.fromJson(v));
            totalperitem =
                double.parse(v['book_price'] * int.parse(v['cart_qty'])) +
                    10.0; // Add delivery charge
          });
          return totalperitem;
        } else {
          Navigator.of(context).pop();
        }
      }
    }).timeout(const Duration(seconds: 5), onTimeout: () {
      print("Timeout");
      setState(() {});
    });
  }

  void showSearchDialog() {
    TextEditingController searchctlr = TextEditingController();
    title = searchctlr.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Search Title",
              style: TextStyle(),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchctlr,
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    loadUserCart(searchctlr.text);
                  },
                  child: const Text("Search"),
                )
              ],
            ));
      },
    );
  }

  void removeFromCart(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove from Cart"),
          content: const Text(
              "Are you sure you want to remove this item from your cart?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                http
                    .get(Uri.parse(
                        "${MyServerConfig.server}/bookbytes/php/remove_from_cart.php"))
                    .then((response) {
                  if (response.statusCode == 200) {
                    var data = jsonDecode(response.body);
                    if (data['status'] == "success") {
                      setState(() {
                        cartList.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item removed from cart")),
                      );
                    }
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  void updateQuantity(int index) {
  
  }

  int calculateTotalItems() {
    int totalItems = 0;
    for (var cartItem in cartList) {
      totalItems = cartItem.cartQty as int;
    }
    return totalItems;
  }

double calculateTotalPrice(List<Cart> cartItems) {
  double totalPrice = 0.0;
  // Map to store total price for each seller
  Map<String, double> sellerTotal = {};
for (var cartItem in cartList) {
    // Calculate total price for each item (considering quantity and item price)
    double itemTotal = cartItem.bookPrice * cartItem.cartQty;

    // Add delivery charge for each seller (assuming RM10 each)
    double totalWithDelivery = itemTotal + (cartItem.deliveryCharge * cartItem.cartQty);

    // Add the total for the current item to the overall total
    totalPrice += totalWithDelivery;
}

}

