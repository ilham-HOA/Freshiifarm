import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freshiifarm_main/Farmer/cart_page.dart';
import 'package:freshiifarm_main/Farmer/product_detail_page.dart';
import 'package:freshiifarm_main/Farmer/profile.dart';

class Product {
  final String name;
  final String price;
  final String desc;
  final String categories;
  final DateTime? timestamp;
  final String imageUrl;

  Product({
    required this.name,
    required this.price,
    required this.desc,
    required this.categories,
    this.timestamp,
    required this.imageUrl,
  });
}

class farmerHome extends StatefulWidget {
  const farmerHome({super.key});

  @override
  State<farmerHome> createState() => _farmerHomeState();
}

class _farmerHomeState extends State<farmerHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products from Firestore
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('FarmerOrSeller')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Products')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        DateTime? timestampDate;
        if (doc['timestamp'] != null) {
          timestampDate = (doc['timestamp'] as Timestamp).toDate();
        }

        return Product(
          name: doc['nameOfproduct'],
          price: doc['price'],
          desc: doc['desc'],
          categories: doc['categories'],
          timestamp: timestampDate,
          imageUrl: doc['imageUrl'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6E9),

      // App Bar with Discover title and cart icon
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      // Main body with scrollable content
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 26),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),

              // Today Trending Section--------------------------------------------
              Row(
                children: const [
                  Text(
                    'Latest Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),

              // Today Trending Product Card (showing only 1 product)
              StreamBuilder<List<Product>>(
                stream: getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child:
                            CircularProgressIndicator(color: Color(0xFF8BC34A)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No products available.'),
                      ),
                    );
                  }

                  // Display only the first product for Today Trending
                  final trendingProduct = products.first;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Add spacing before the image to push it right
                        const SizedBox(width: 16),
                        // Product Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: trendingProduct.imageUrl.isNotEmpty
                                ? Image.network(
                                    trendingProduct.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.image,
                                            size: 50, color: Colors.grey),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image,
                                        size: 50, color: Colors.grey),
                                  ),
                          ),
                        ),

                        // Product Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Price Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8080D0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'RM${trendingProduct.price}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Product Name
                                Text(
                                  trendingProduct.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Rating Stars
                                Row(
                                  children: [
                                    ...List.generate(
                                        5,
                                        (index) => const Icon(Icons.star,
                                            color: Colors.amber, size: 18)),
                                    const SizedBox(width: 5),
                                    const Text('(1)',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Best Selling Section--------------------------------------------
              Row(
                children: const [
                  Text(
                    'My Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'This week',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Best Selling Products (showing 3 products horizontally)
              StreamBuilder<List<Product>>(
                stream: getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child:
                            CircularProgressIndicator(color: Color(0xFF8BC34A)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No products available.'),
                      ),
                    );
                  }

                  // Get up to 3 products for Best Selling
                  final bestSellingProducts = products.take(3).toList();

                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: bestSellingProducts.length,
                      itemBuilder: (context, index) {
                        final product = bestSellingProducts[index];

                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Price Tag
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8080D0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'RM${product.price}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Product Image
                              Container(
                                height: 120,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.image,
                                                  size: 40, color: Colors.grey),
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.image,
                                              size: 40, color: Colors.grey),
                                        ),
                                ),
                              ),

                              // Product Details
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Name
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 8),

                                    // Rating Stars
                                    Row(
                                      children: [
                                        ...List.generate(
                                            5,
                                            (starIndex) => Icon(
                                                  Icons.star,
                                                  color: starIndex <
                                                          (index + 3) % 5
                                                      ? Colors.amber
                                                      : Colors.amber
                                                          .withOpacity(0.3),
                                                  size: 16,
                                                )),
                                        const SizedBox(width: 5),
                                        Text('(${(index + 1) * 2})',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Add some bottom spacing
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
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
      ),
    );
  }
}
