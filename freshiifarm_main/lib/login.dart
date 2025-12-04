import 'package:flutter/material.dart';
//FIREBASE
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//PAGES
import 'package:freshiifarm_main/Customer/cust_home.dart';
import 'package:freshiifarm_main/Farmer/farmer_home.dart';
import 'package:freshiifarm_main/Guest/guest_home.dart';
import 'package:freshiifarm_main/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;
  bool _obscurePassword = true; // Added for password visibility toggle

  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password';
        return;
      });
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String enteredEmail = emailController.text.trim();
      String enteredPassword = passwordController.text.trim();

      //farmer-------------------------------------------------
      QuerySnapshot farmerSnapshot = await FirebaseFirestore.instance
          .collection('FarmerOrSeller')
          .where('Email', isEqualTo: enteredEmail)
          .get();

      if (farmerSnapshot.docs.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => farmerHome()),
        );
        return;
      }

      //customer-------------------------------------------------
      QuerySnapshot CustSnapshot = await FirebaseFirestore.instance
          .collection('CustomerOrBuyer')
          .where('Email', isEqualTo: enteredEmail)
          .get();

      if (CustSnapshot.docs.isEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustHome()),
      );

      // If not found in either collection
      setState(() {
        isLoading = false;
        errorMessage = 'User account not found';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Login failed';
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          )),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),

                //space
                SizedBox(height: 16),

                //password with eye toggle
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
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

                //space
                SizedBox(height: 30),

                //login button
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: loginUser,
                        child: const Text('Login'),
                      ),

                //space
                SizedBox(height: 20),

                //register button
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => registerScreen()),
                  ),
                  child: const Text('Don\'t have account? Sign Up'),
                ),

                //space
                SizedBox(height: 10),

                //Guest button
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GuestHome()),
                  ),
                  child: const Text('Continue as Guest'),
                ),

                //error message
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child:
                        Text(errorMessage, style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
