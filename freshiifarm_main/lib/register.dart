import 'package:flutter/material.dart';

//FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class registerScreen extends StatefulWidget {
  const registerScreen({super.key});

  @override
  State<registerScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  final TextEditingController fullnameCotroller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> TypeOfUsers = [
    'Customer/Buyer',
    'Farmer/Seller',
  ];

  String? selectedUserType;
  bool _obscurePassword = true; // Added for password visibility toggle

  Future<void> registerUser(BuildContext context) async {
    if (fullnameCotroller.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedUserType == null) {
      _showSnackBar(context, 'Please fill in all the fields!', Colors.red);
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userData = {
        'Full Name': fullnameCotroller.text.trim(),
        'Email': emailController.text.trim(),
        'Password': passwordController.text.trim(),
        'Type of User': selectedUserType,
      };

      if (selectedUserType == 'Farmer/Seller') {
        await FirebaseFirestore.instance
            .collection('FarmerOrSeller')
            .doc(userCredential.user!.uid)
            .set(userData);

        _showSnackBar(
            context, 'Signup farmer/Seller successful!', Colors.green);
      } else {
        await FirebaseFirestore.instance
            .collection('CustomerOrBuyer')
            .doc(userCredential.user!.uid)
            .set(userData);

        _showSnackBar(
            context, 'Signup Customer/Buyer successful!', Colors.green);
      }
    } catch (e) {
      _showSnackBar(context, 'Signup failed!: $e', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //full name
              TextField(
                controller: fullnameCotroller,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),

              //email
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'email'),
              ),

              //password with eye toggle
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),

              SizedBox(height: 20), // Added space between password and dropdown

              //select type of user
              DropdownButton(
                  hint: const Text('Select User Type'),
                  value: selectedUserType,
                  isExpanded: true,
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  items: TypeOfUsers.map((String userType) {
                    return DropdownMenuItem<String>(
                      value: userType,
                      child: Text(userType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUserType = newValue;
                    });
                  }),

              SizedBox(height: 20),

              //register button
              ElevatedButton(
                onPressed: () => registerUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
