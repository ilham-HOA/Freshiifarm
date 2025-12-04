import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavProduct {
  final String id;
  final String name;
  final String price;
  final String desc;
  final String categories;
  final String sellerName;
  final DateTime? timestamp;

  FavProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.categories,
    required this.sellerName,
    this.timestamp,
  });
}

class FavoritesCustScreen extends StatefulWidget {
  const FavoritesCustScreen({super.key});

  @override
  State<FavoritesCustScreen> createState() => _FavoritesCustScreenState();
}

class _FavoritesCustScreenState extends State<FavoritesCustScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryColor = Colors.blue;

  // Get all favorited products
  Stream<List<FavProduct>> getFavorites() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('CustomerOrBuyer')
        .doc(userId)
        .collection('Favorites')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        DateTime? timestampDate;
        if (doc['timestamp'] != null) {
          timestampDate = (doc['timestamp'] as Timestamp).toDate();
        }

        return FavProduct(
          id: doc.id,
          name: doc['name'] ?? '',
          price: doc['price'] ?? '',
          desc: doc['desc'] ?? '',
          categories: doc['categories'] ?? '',
          sellerName: doc['sellerName'] ?? 'Unknown Seller',
          timestamp: timestampDate,
        );
      }).toList();
    });
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String docId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await _firestore
          .collection('CustomerOrBuyer')
          .doc(userId)
          .collection('Favorites')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing from favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add to cart
  Future<void> addToCart(FavProduct product) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference cartRef = _firestore
          .collection('CustomerOrBuyer')
          .doc(userId)
          .collection('Cart');

      await cartRef.add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'desc': product.desc,
        'categories': product.categories,
        'sellerName': product.sellerName,
        'addedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
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
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<FavProduct>>(
        stream: getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading favorites: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items you favorite will appear here',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];

              return Dismissible(
                key: Key(product.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  removeFromFavorites(product.id);
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () => removeFromFavorites(product.id),
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
                            'Added to favorites: ${_formatDate(product.timestamp!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => addToCart(product),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_cart),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
