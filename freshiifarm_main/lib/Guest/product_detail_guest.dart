import 'package:flutter/material.dart';
//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//PAGES
import 'package:freshiifarm_main/Guest/guest_home.dart';
import 'package:freshiifarm_main/Guest/profile_guest.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String desc;
  final String categories;
  final String sellerName;
  final DateTime? timestamp;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.categories,
    required this.sellerName,
    this.timestamp,
  });
}

class ProductDetailGuestScreen extends StatefulWidget {
  const ProductDetailGuestScreen({super.key});

  @override
  State<ProductDetailGuestScreen> createState() =>
      _ProductDetailGuestScreenState();
}

class _ProductDetailGuestScreenState extends State<ProductDetailGuestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all products from all users
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('FarmerOrSeller')
        .snapshots()
        .asyncMap((farmerSnapshot) async {
      List<Product> allProducts = [];

      for (var farmerDoc in farmerSnapshot.docs) {
        // Skip if it's the current user's products
        if (farmerDoc.id == FirebaseAuth.instance.currentUser?.uid) continue;

        // Get the farmer's name
        String sellerName = farmerDoc.data()['Full Name'] ?? 'Unknown Seller';

        // Get products for this farmer
        var productsSnapshot = await farmerDoc.reference
            .collection('Products')
            .orderBy('timestamp', descending: true)
            .get();

        var products = productsSnapshot.docs.map((doc) {
          DateTime? timestampDate;
          if (doc['timestamp'] != null) {
            timestampDate = (doc['timestamp'] as Timestamp).toDate();
          }

          return Product(
            id: doc.id,
            name: doc['nameOfproduct'] ?? '',
            price: doc['price'] ?? '',
            desc: doc['desc'] ?? '',
            categories: doc['categories'] ?? '',
            sellerName: sellerName,
            timestamp: timestampDate,
          );
        }).toList();

        allProducts.addAll(products);
      }

      allProducts.sort((a, b) => (b.timestamp ?? DateTime.now())
          .compareTo(a.timestamp ?? DateTime.now()));

      return allProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'All Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Product>>(
          stream: getAllProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Error fetching products: ${snapshot.error}");
              return const Center(child: Text('Something went wrong.'));
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return const Center(child: Text('No products available.'));
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Seller: ${product.sellerName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Price: RM${product.price}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('Description: ${product.desc}'),
                        Text('Category: ${product.categories}'),
                        if (product.timestamp != null)
                          Text(
                            'Posted: ${_formatDate(product.timestamp!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GuestHome()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileGuestScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
