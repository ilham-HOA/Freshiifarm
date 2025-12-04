import 'package:flutter/material.dart';
//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//PAGES
import 'package:freshiifarm_main/Customer/cart_cust.dart';
import 'package:freshiifarm_main/Customer/cust_home.dart';
import 'package:freshiifarm_main/Customer/profile_cust.dart';
import 'package:freshiifarm_main/Customer/profile_cust/fav_cust_screen.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String desc;
  final String categories;
  final String sellerName;
  final DateTime? timestamp;
  bool isFavorite; // Track favorite status

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.categories,
    required this.sellerName,
    this.timestamp,
    this.isFavorite = false, // Default to not favorited
  });
}

class ProductDetailCustScreen extends StatefulWidget {
  const ProductDetailCustScreen({super.key});

  @override
  State<ProductDetailCustScreen> createState() =>
      _ProductDetailCustScreenState();
}

class _ProductDetailCustScreenState extends State<ProductDetailCustScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _favoritedProductIds = []; // Store IDs of favorited products

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Load user's favorites from Firestore
  Future<void> _loadFavorites() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      var favoritesSnapshot = await _firestore
          .collection('CustomerOrBuyer')
          .doc(userId)
          .collection('Favorites')
          .get();

      setState(() {
        _favoritedProductIds = favoritesSnapshot.docs
            .map((doc) => doc['productId'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

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
            isFavorite:
                _favoritedProductIds.contains(doc.id), // Set favorite status
          );
        }).toList();

        allProducts.addAll(products);
      }

      allProducts.sort((a, b) => (b.timestamp ?? DateTime.now())
          .compareTo(a.timestamp ?? DateTime.now()));

      return allProducts;
    });
  }

  // Add product to cart
  Future<void> addToCart(Product product) async {
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

  // Toggle favorite status for a product
  Future<void> toggleFavorite(Product product) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference favoritesRef = _firestore
          .collection('CustomerOrBuyer')
          .doc(userId)
          .collection('Favorites');

      if (product.isFavorite) {
        // Remove from favorites
        var snapshot =
            await favoritesRef.where('productId', isEqualTo: product.id).get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          _favoritedProductIds.remove(product.id);
          product.isFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        // Add to favorites
        await favoritesRef.add({
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'desc': product.desc,
          'categories': product.categories,
          'sellerName': product.sellerName,
          'timestamp': DateTime.now(),
        });

        setState(() {
          _favoritedProductIds.add(product.id);
          product.isFavorite = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigate to favorites screen
  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritesCustScreen()),
    );
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
          actions: [
            // Favorites button in app bar
            IconButton(
              icon: Icon(Icons.favorite, color: Colors.white),
              onPressed: _navigateToFavorites,
              tooltip: 'View Favorites',
            ),
          ],
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
                              // Favorite button
                              IconButton(
                                icon: Icon(
                                  product.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: product.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => toggleFavorite(product),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                await addToCart(product);
                                Navigator.pop(context);
                              },
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
                MaterialPageRoute(builder: (context) => CustHome()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartCustPage()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileCustScreen()),
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
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
