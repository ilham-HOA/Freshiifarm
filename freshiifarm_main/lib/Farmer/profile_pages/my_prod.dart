import 'package:flutter/material.dart';
// FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//PAGES
import 'package:freshiifarm_main/Farmer/profile_pages/new_Prod.dart';
import 'package:freshiifarm_main/Farmer/profile_pages/edit_Prod.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String desc;
  final String categories;
  final DateTime? timestamp;
  final String? imageUrl; // Added to support images

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.categories,
    this.timestamp,
    this.imageUrl,
  });
}

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({super.key});

  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryColor = const Color(0xFF1976D2); // Primary blue color

  //fetch the product
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('FarmerOrSeller')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Products')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((farmerSnapshot) {
      return farmerSnapshot.docs.map((doc) {
        DateTime? timestampDate;
        if (doc['timestamp'] != null) {
          timestampDate = (doc['timestamp'] as Timestamp).toDate();
        }

        return Product(
          id: doc.id,
          name: doc['nameOfproduct'],
          price: doc['price'],
          desc: doc['desc'],
          categories: doc['categories'],
          timestamp: timestampDate,
          imageUrl: doc['imageUrl'], // Get image URL if available
        );
      }).toList();
    });
  }

  // Method to handle adding a new product
  Future<void> _addNewProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewProduct()),
    );

    // If we got product data back, add it to Firestore
    if (result != null) {
      await _firestore
          .collection('FarmerOrSeller')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Products')
          .add({
        'nameOfproduct': result['nameOfproduct'],
        'price': result['price'],
        'desc': result['desc'],
        'categories': result['categories'],
        'imageUrl': result['imageUrl'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  // Method to handle editing a product
  Future<void> _editProduct(Product product) async {
    // Navigate to dedicated edit page with current product data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProduct(
          productId: product.id,
          productName: product.name,
          productPrice: product.price,
          productDesc: product.desc,
          productCategory: product.categories,
          productImageUrl: product.imageUrl ?? '',
        ),
      ),
    );

    // Check if product was updated or deleted
    if (result == 'deleted') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (result != null) {
      // No need to update Firestore here as the EditProduct class handles that
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  // Method to handle deleting a product with confirmation
  Future<void> _deleteProduct(Product product) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Product'),
          ],
        ),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (confirmDelete == true) {
      await _firestore
          .collection('FarmerOrSeller')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Products')
          .doc(product.id)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6E9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with count of products
          StreamBuilder<List<Product>>(
              stream: getProducts(),
              builder: (context, snapshot) {
                int productCount = snapshot.data?.length ?? 0;
                return Container(
                  color: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        '$productCount Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Manage your inventory',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }),

          // Main product list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: StreamBuilder<List<Product>>(
                stream: getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    print("Error fetching products: ${snapshot.error}");
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Error loading products.'),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first product using the + button',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      // Enhanced product card
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product header with category badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      product.categories,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Product content
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image - now displays actual image if available
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: product.imageUrl != null &&
                                            product.imageUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 32,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                              size: 32,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16),

                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'RM ${product.price}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: primaryColor,
                                              ),
                                            ),
                                            Spacer(),
                                            if (product.timestamp != null)
                                              Text(
                                                'Added: ${_formatDate(product.timestamp!)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          product.desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action buttons
                            Padding(
                              padding: EdgeInsets.only(right: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Edit button
                                  TextButton.icon(
                                    onPressed: () => _editProduct(product),
                                    icon: Icon(Icons.edit, color: primaryColor),
                                    label: Text(
                                      'Edit',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  // Delete button
                                  TextButton.icon(
                                    onPressed: () => _deleteProduct(product),
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    label: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
