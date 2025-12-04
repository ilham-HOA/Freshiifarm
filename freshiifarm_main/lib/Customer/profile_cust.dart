import 'package:flutter/material.dart';
//PAGES
import 'package:freshiifarm_main/Customer/cust_home.dart';
import 'package:freshiifarm_main/Customer/cart_cust.dart';
import 'package:freshiifarm_main/Customer/product_detail_cust.dart';
//PAGES - PROFILE PAGES
import 'package:freshiifarm_main/Customer/profile_cust/fav_cust_screen.dart';
import 'package:freshiifarm_main/Customer/profile_cust/my_order_cust.dart';
import 'package:freshiifarm_main/Customer/profile_cust/my_cust_profile.dart';
import 'package:freshiifarm_main/Farmer/profile_pages/setting.dart';
import 'package:freshiifarm_main/login.dart';

class ProfileCustScreen extends StatefulWidget {
  const ProfileCustScreen({super.key});

  @override
  State<ProfileCustScreen> createState() => _ProfileCustScreenState();
}

class _ProfileCustScreenState extends State<ProfileCustScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),

      //body
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Menu Options
            // Update these lines in your ProfileScreen
            _buildMenuItem(Icons.person, 'My Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyCustProfileScreen()),
              );
            }),
            _buildMenuItem(Icons.favorite, 'Favorites', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesCustScreen()),
              );
            }),
            _buildMenuItem(Icons.shopping_cart, 'My Orders', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyOrdersCustScreen()),
              );
            }),
            _buildMenuItem(Icons.settings, 'Settings', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigate to LoginScreen and remove all previous routes
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      //footer
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartCustPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailCustScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileCustScreen()),
            );
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustHome()),
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

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
