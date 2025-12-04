import 'package:flutter/material.dart';
//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//PAGES
import 'package:freshiifarm_main/Customer/profile_cust/order_success_cust.dart';

class PaymentCustPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;
  final double totalAmount;

  const PaymentCustPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<PaymentCustPage> createState() => _PaymentCustPageState();
}

class _PaymentCustPageState extends State<PaymentCustPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Payment method selection
  String _selectedPaymentMethod = 'Credit Card';
  bool _isProcessing = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Create a new order in Customer collection
      DocumentReference orderRef = await _firestore
          .collection('CustomerOrBuyer')
          .doc(userId)
          .collection('Orders')
          .add({
        'orderDate': FieldValue.serverTimestamp(),
        'totalAmount': widget.totalAmount,
        'status': 'Paid',
        'paymentMethod': _selectedPaymentMethod,
        'shippingAddress': _addressController.text,
        'contactPhone': _phoneController.text,
        'contactName': _nameController.text,
      });

      // Add order items with images
      for (var item in widget.cartItems) {
        var data = item.data() as Map<String, dynamic>;
        await orderRef.collection('OrderItems').add({
          'productId': data['productId'] ?? '',
          'name': data['name'] ?? '',
          'price': data['price'] ?? '',
          'sellerName': data['sellerName'] ?? '',
          'categories': data['categories'] ?? '',
          'desc': data['desc'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
        });
      }

      // Also create orders for farmers (so they can see incoming orders)
      Map<String, List<QueryDocumentSnapshot>> ordersBySeller = {};

      // Group cart items by seller
      for (var item in widget.cartItems) {
        var data = item.data() as Map<String, dynamic>;
        String sellerName = data['sellerName'] ?? 'Unknown Seller';
        if (ordersBySeller[sellerName] == null) {
          ordersBySeller[sellerName] = [];
        }
        ordersBySeller[sellerName]!.add(item);
      }

      // Create orders in each farmer's collection
      for (var entry in ordersBySeller.entries) {
        String sellerName = entry.key;
        List<QueryDocumentSnapshot> sellerItems = entry.value;

        // Calculate total for this seller
        double sellerTotal = 0;
        for (var item in sellerItems) {
          var data = item.data() as Map<String, dynamic>;
          sellerTotal += double.parse(data['price'].toString());
        }

        // Find farmer by name and create order
        var farmersSnapshot = await _firestore
            .collection('FarmerOrSeller')
            .where('Full Name', isEqualTo: sellerName)
            .get();

        if (farmersSnapshot.docs.isNotEmpty) {
          String farmerId = farmersSnapshot.docs.first.id;

          DocumentReference farmerOrderRef = await _firestore
              .collection('FarmerOrSeller')
              .doc(farmerId)
              .collection('IncomingOrders')
              .add({
            'orderDate': FieldValue.serverTimestamp(),
            'totalAmount': sellerTotal,
            'status': 'New Order',
            'paymentMethod': _selectedPaymentMethod,
            'shippingAddress': _addressController.text,
            'contactPhone': _phoneController.text,
            'contactName': _nameController.text,
            'customerId': userId,
            'customerOrderId': orderRef.id,
          });

          // Add items to farmer's incoming order
          for (var item in sellerItems) {
            var data = item.data() as Map<String, dynamic>;
            await farmerOrderRef.collection('OrderItems').add({
              'productId': data['productId'] ?? '',
              'name': data['name'] ?? '',
              'price': data['price'] ?? '',
              'categories': data['categories'] ?? '',
              'desc': data['desc'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
            });
          }
        }
      }

      // Clear customer's cart
      for (var item in widget.cartItems) {
        await _firestore
            .collection('Customer')
            .doc(userId)
            .collection('Cart')
            .doc(item.id)
            .delete();
      }

      // Navigate to success page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessCustPage(orderId: orderRef.id),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing your payment...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            ...widget.cartItems.map((item) {
                              var data = item.data() as Map<String, dynamic>;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    // Product Image
                                    if (data['imageUrl'] != null &&
                                        data['imageUrl'].toString().isNotEmpty)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            data['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.image,
                                                    size: 30,
                                                    color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Unknown Product',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'Seller: ${data['sellerName'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'RM${data['price'] ?? '0'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'RM${widget.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shipping Information
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Shipping Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Payment Methods
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Payment method selection
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(Icons.credit_card),
                                SizedBox(width: 12),
                                Text('Credit Card'),
                              ],
                            ),
                            value: 'Credit Card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(Icons.account_balance),
                                SizedBox(width: 12),
                                Text('Bank Transfer'),
                              ],
                            ),
                            value: 'Bank Transfer',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(Icons.payments_outlined),
                                SizedBox(width: 12),
                                Text('Cash on Delivery'),
                              ],
                            ),
                            value: 'Cash on Delivery',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Confirm Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _processOrder,
                        child: const Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
