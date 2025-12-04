import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProduct extends StatefulWidget {
  final String productId;
  final String productName;
  final String productPrice;
  final String productDesc;
  final String productCategory;
  final String productImageUrl;

  const EditProduct({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productDesc,
    required this.productCategory,
    required this.productImageUrl,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _existingImageUrl;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _categoriesController;

  bool _isSubmitting = false;
  bool _imageChanged = false;

  // Color scheme
  final Color primaryColor = const Color(0xFF1976D2); // Primary blue
  final Color accentColor = const Color(0xFF42A5F5); // Lighter blue
  final Color textColor = const Color(0xFF0D47A1); // Dark blue for text

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values
    _nameController = TextEditingController(text: widget.productName);
    _priceController = TextEditingController(text: widget.productPrice);
    _descController = TextEditingController(text: widget.productDesc);
    _categoriesController = TextEditingController(text: widget.productCategory);

    // Store existing image URL
    _existingImageUrl = widget.productImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  // Image picker function
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageChanged = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _existingImageUrl;

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showErrorDialog('Error uploading image: $e');
      return null;
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image Source",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Success'),
            ],
          ),
          content: Text('Product updated successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Return to product list
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // void _confirmDelete() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Icon(Icons.delete, color: Colors.red),
  //           SizedBox(width: 10),
  //           Text('Delete Product'),
  //         ],
  //       ),
  //       content: Text('Are you sure you want to delete this product?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel', style: TextStyle(color: Colors.grey)),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context); // Close dialog

  //             // Delete the product
  //             try {
  //               setState(() {
  //                 _isSubmitting = true;
  //               });

  //               User? user = FirebaseAuth.instance.currentUser;
  //               if (user != null) {
  //                 await _firestore
  //                     .collection('FarmerOrSeller')
  //                     .doc(user.uid)
  //                     .collection('Products')
  //                     .doc(widget.productId)
  //                     .delete();

  //                 setState(() {
  //                   _isSubmitting = false;
  //                 });

  //                 // Return to previous screen with deletion info
  //                 Navigator.pop(context, 'deleted');
  //               }
  //             } catch (e) {
  //               setState(() {
  //                 _isSubmitting = false;
  //               });
  //               _showErrorDialog('Error deleting product: $e');
  //             }
  //           },
  //           child: Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill in all required fields correctly.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Upload image if changed
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null && _imageChanged) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) throw Exception('Failed to upload image');
      }

      final productData = {
        'nameOfproduct': _nameController.text,
        'price': _priceController.text,
        'desc': _descController.text,
        'categories': _categoriesController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Update existing product
      await _firestore
          .collection('FarmerOrSeller')
          .doc(user.uid)
          .collection('Products')
          .doc(widget.productId)
          .update(productData);

      _showSuccessDialog();

      // Return updated product data to the caller
      Navigator.pop(context, productData);
    } catch (e) {
      _showErrorDialog('Error updating product: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
          'Edit Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.delete, color: Colors.white),
        //     onPressed: _confirmDelete,
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerModal,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_existingImageUrl != null && !_imageChanged)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                primaryColor),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Failed to load image',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 60,
                                      color: primaryColor.withOpacity(0.7)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to change product image',
                                    style: TextStyle(
                                        color: primaryColor.withOpacity(0.7),
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product Details
              _buildInputField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: _nameController,
                prefixIcon: Icons.shopping_bag,
              ),

              _buildInputField(
                label: 'Price (RM)',
                hint: 'Enter product price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),

              _buildInputField(
                label: 'Description',
                hint: 'Enter product description',
                controller: _descController,
                maxLines: 3,
                prefixIcon: Icons.description,
              ),

              _buildInputField(
                label: 'Categories',
                hint: 'Enter product categories (e.g., Fruits, Vegetables)',
                controller: _categoriesController,
                prefixIcon: Icons.category,
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Update Product',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: primaryColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
