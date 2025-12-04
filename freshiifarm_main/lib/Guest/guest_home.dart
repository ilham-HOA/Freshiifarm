import 'package:flutter/material.dart';
//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//PAGES
import 'package:freshiifarm_main/Guest/product_detail_guest.dart';
import 'package:freshiifarm_main/Guest/profile_guest.dart';

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

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('FarmerOrSeller')
        .snapshots()
        .asyncMap((farmerSnapshot) async {
      List<Product> allProducts = [];

      for (var farmerDoc in farmerSnapshot.docs) {
        try {
          var productsSnapshot = await farmerDoc.reference
              .collection('Products')
              .orderBy('timestamp', descending: true)
              .get();

          var products = productsSnapshot.docs
              .map((doc) {
                try {
                  DateTime? timestampDate;
                  if (doc['timestamp'] != null) {
                    timestampDate = (doc['timestamp'] as Timestamp).toDate();
                  }

                  String imageUrl = '';
                  try {
                    imageUrl = doc['imageUrl'] ?? '';
                  } catch (e) {
                    print('ImageUrl field not found in document ${doc.id}: $e');
                    imageUrl = '';
                  }

                  return Product(
                    name: doc['nameOfproduct'] ?? '',
                    price: doc['price'] ?? '',
                    desc: doc['desc'] ?? '',
                    categories: doc['categories'] ?? '',
                    timestamp: timestampDate,
                    imageUrl: imageUrl,
                  );
                } catch (e) {
                  print('Error processing document ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .toList();

          allProducts.addAll(products);
        } catch (e) {
          print('Error processing farmer ${farmerDoc.id}: $e');
        }
      }

      allProducts.sort((a, b) => (b.timestamp ?? DateTime.now())
          .compareTo(a.timestamp ?? DateTime.now()));

      return allProducts;
    });
  }

  // Fetch all products from all users
  // Stream<List<Product>> getAllProducts() {
  //   return _firestore
  //       .collection('FarmerOrSeller')
  //       .snapshots()
  //       .asyncMap((farmerSnapshot) async {
  //     List<Product> allProducts = [];

  //     for (var farmerDoc in farmerSnapshot.docs) {
  //       // Get products for this farmer
  //       var productsSnapshot = await farmerDoc.reference
  //           .collection('Products')
  //           .orderBy('timestamp', descending: true)
  //           .get();

  //       var products = productsSnapshot.docs.map((doc) {
  //         DateTime? timestampDate;
  //         if (doc['timestamp'] != null) {
  //           timestampDate = (doc['timestamp'] as Timestamp).toDate();
  //         }

  //         return Product(
  //           name: doc['nameOfproduct'] ?? '',
  //           price: doc['price'] ?? '',
  //           desc: doc['desc'] ?? '',
  //           categories: doc['categories'] ?? '',
  //           timestamp: timestampDate,
  //           imageUrl: doc['imageUrl'] ?? '',
  //         );
  //       }).toList();

  //       allProducts.addAll(products);
  //     }

  //     allProducts.sort((a, b) => (b.timestamp ?? DateTime.now())
  //         .compareTo(a.timestamp ?? DateTime.now()));

  //     return allProducts;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6E9),

      //header
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Today trending Section
              Row(
                children: const [
                  Text(
                    'Best Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              StreamBuilder<List<Product>>(
                stream: getAllProducts(),
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
                    return const Center(
                      child: Text('Something when wrong'),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No product available.'),
                      ),
                    );
                  }

                  //display only 1 product
                  final trendingProduct = products.first;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
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
                                //Price
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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

                                //Product Name
                                Text(
                                  trendingProduct.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                //Rating Star
                                Row(
                                  children: [
                                    ...List.generate(
                                        5,
                                        (index) => const Icon(Icons.star,
                                            color: Colors.amber, size: 18)),
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
                    'List Product',
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
                stream: getAllProducts(),
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
                      itemCount: bestSellingProducts.length +
                          1, // Added +1 for the "..." button
                      itemBuilder: (context, index) {
                        // Check if this is the last item (the "..." button)
                        if (index == bestSellingProducts.length) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailGuestScreen(),
                                ),
                              );
                            },
                            child: Container(
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
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '...',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8080D0),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF8080D0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // Original product card code
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

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailGuestScreen()),
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
}
