//import 'dart:convert';
import 'package:bookbytes/models/user.dart';
//import 'package:bookbytes/views/editbookpage.dart';
import 'package:bookbytes/shared/myserverconfig.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookDetails extends StatefulWidget {
  final User user;
  final Book book;

  const BookDetails({super.key, required this.user, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late double screenWidth, screenHeight;
  final f = DateFormat('dd-MM-yyyy hh:mm a');
  bool bookowner = false;

  @override
  Widget build(BuildContext context) {
    if (widget.user.userid == widget.book.userId) {
      bookowner = true;
    } else {
      bookowner = false;
    }
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.bookTitle.toString()),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                enabled: bookowner,
                child: const Text("Update"),
              ),
              PopupMenuItem<int>(
                enabled: bookowner,
                value: 1,
                child: const Text("Delete"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              if (widget.book.userId == widget.book.userId) {
                updateDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Not allowed!!!"),
                  backgroundColor: Colors.red,
                ));
              }
            } else if (value == 1) {
              if (widget.book.userId == widget.book.userId) {
                deleteDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Not allowed!!!"),
                  backgroundColor: Colors.red,
                ));
              }
            } else if (value == 2) {}
          }),

          // Add to Cart Button
        //  if (isUserRegistered()) // Check if the user is registered
            IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                // Implement your "Add to Cart" logic here
                addToCart();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: screenHeight * 0.4,
            width: screenWidth,
            child: Image.network(
                fit: BoxFit.fill,
                "${MyServerConfig.server}/bookbytes/assets/books/${widget.book.bookId}.png"),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            height: screenHeight * 0.6,
            child: Column(children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  widget.book.bookTitle.toString(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                widget.book.bookAuthor.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                  "Date Available ${f.format(DateTime.parse(widget.book.bookDate.toString()))}"),
              Text("ISBN ${widget.book.bookIsbn}"),
              const SizedBox(
                height: 8,
              ),
              Text(widget.book.bookDesc.toString(),
                  textAlign: TextAlign.justify),
              Text(
                "RM ${widget.book.bookPrice}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Quantity Available ${widget.book.bookQty}"),
            ]),
          ),
        ]),
      ),
    );
  }

 // bool isUserRegistered() {
   // return widget.user != null;
  //}

 
  void addToCart() {
    if (widget.book.bookQty != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to Cart"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        //widget.book.bookQty = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book quantity is insufficient'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateDialog() {
    
  }

  void deleteDialog() {
    
  }

  void deleteBook() {
    
  }
}
