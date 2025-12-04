import 'package:flutter/material.dart';
//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCustProfileScreen extends StatefulWidget {
  const MyCustProfileScreen({super.key});

  @override
  State<MyCustProfileScreen> createState() => _MyCustProfileScreenState();
}

class _MyCustProfileScreenState extends State<MyCustProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? name;
  String? email;
  String? password;
  String? TypeOfUsers;
  bool isPasswordVisible = false;
  bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('CustomerOrBuyer').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['Full Name'];
            email = userDoc['Email'];
            password = userDoc['Password'];
            TypeOfUsers = userDoc['Type of User'];

            _nameController.text = name ?? '';
            _passwordController.text = password ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        // Update password in Firebase Auth if it changed
        await user.updatePassword(_passwordController.text);

        // Update profile in Firestore
        await _firestore.collection('FarmerOrSeller').doc(user.uid).update({
          'Full Name': _nameController.text,
        });

        // Hide loading indicator
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isEditing = false;
          name = _nameController.text;
        });
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Profile'),
        actions: [
          // Add edit/save button
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),

      //body
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/farmer_person.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name ?? 'Farmer Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    TypeOfUsers ?? 'Farmer',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Non-editable Email Field
            _buildNonEditableTextField('Email', email ?? ''),

            // Editable Name Field
            _buildEditableTextField('Full Name', _nameController, isEditing),

            // Editable Password Field
            _buildPasswordTextField('Password', _passwordController, isEditing),

            // Add Cancel button when editing
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                  ),
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      _loadUserProfile(); // Reset to original values
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Non-editable TextField (for Email)
  Widget _buildNonEditableTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  // Editable TextField (for Name)
  Widget _buildEditableTextField(
      String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !isEditing,
          fillColor: !isEditing ? Colors.grey[200] : null,
        ),
      ),
    );
  }

  // Password TextField with visibility toggle
  Widget _buildPasswordTextField(
      String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        readOnly: !isEditing,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: isEditing
              ? IconButton(
                  icon: Icon(isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
          filled: !isEditing,
          fillColor: !isEditing ? Colors.grey[200] : null,
        ),
      ),
    );
  }
}
