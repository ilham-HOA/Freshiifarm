import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? imageUrl;

  String? name;
  String? price;
  String? desc;
  String? categories;
  bool _isSubmitting = false;

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
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

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
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt, size: 24),
                    SizedBox(width: 12),
                    Text('Take Photo', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Row(
                  children: [
                    Icon(Icons.photo_library, size: 24),
                    SizedBox(width: 12),
                    Text('Choose from Gallery', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Successfully add product!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _imageFile = null;
      name = null;
      price = null;
      desc = null;
      categories = null;
    });
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill in all required fields correctly.');
      return;
    }

    if (_imageFile == null) {
      _showErrorDialog('Please select a product image.');
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

      // Upload image first
      final String? imageUrl = await _uploadImage();
      if (imageUrl == null) throw Exception('Failed to upload image');

      await _firestore
          .collection('FarmerOrSeller')
          .doc(user.uid)
          .collection('Products')
          .doc(name)
          .set({
        'nameOfproduct': name,
        'price': price,
        'desc': desc,
        'categories': categories,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Error submitting product: $e');
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
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Add Product Image',
                                  style: TextStyle(color: Colors.grey)),
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
                onChanged: (value) => name = value,
                prefixIcon: Icons.shopping_bag,
              ),

              _buildInputField(
                label: 'Price',
                hint: 'Enter product price',
                onChanged: (value) => price = value,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),

              _buildInputField(
                label: 'Description',
                hint: 'Enter product description',
                onChanged: (value) => desc = value,
                maxLines: 3,
                prefixIcon: Icons.description,
              ),

              _buildInputField(
                label: 'Categories',
                hint: 'Enter product categories (e.g., Fruits, Vegetables)',
                onChanged: (value) => categories = value,
                prefixIcon: Icons.category,
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
    required Function(String) onChanged,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8BC34A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8BC34A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
            ),
            errorStyle: const TextStyle(color: Colors.red),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
