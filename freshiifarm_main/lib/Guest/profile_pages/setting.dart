//HARD CODE
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: Text(
            //     'Account Settings',
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Color(0xFF4CAF50),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 10),
            // _buildSettingsItem(
            //   Icons.password,
            //   'Change Password',
            //   'Update your account password',
            //   () => _showChangePasswordDialog(),
            // ),
            // _buildDivider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            _buildSwitchItem(
              Icons.notifications,
              'Push Notifications',
              'Receive notifications about orders and updates',
              notificationsEnabled,
              (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            _buildDivider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Display',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            _buildSwitchItem(
              Icons.dark_mode,
              'Dark Mode',
              'Switch between light and dark themes',
              darkModeEnabled,
              (value) {
                setState(() {
                  darkModeEnabled = value;
                });
                // Here you would implement the actual theme change logic
              },
            ),
            _buildDivider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            _buildSettingsItem(
              Icons.info,
              'App Version',
              '1.0.0',
              () {},
              showArrow: false,
            ),
            _buildSettingsItem(
              Icons.privacy_tip,
              'Privacy Policy',
              'Read our privacy policy',
              () {
                // Navigate to privacy policy
              },
            ),
            _buildSettingsItem(
              Icons.description,
              'Terms of Service',
              'Read our terms of service',
              () {
                // Navigate to terms of service
              },
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    // Show delete account confirmation
                    _showDeleteAccountDialog();
                  },
                  child: const Text(
                    'DELETE ACCOUNT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool showArrow = true}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, String subtitle,
      bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8BC34A),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  // void _showChangePasswordDialog() {
  //   final TextEditingController _currentPasswordController =
  //       TextEditingController();
  //   final TextEditingController _newPasswordController =
  //       TextEditingController();
  //   final TextEditingController _confirmPasswordController =
  //       TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Change Password'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: _currentPasswordController,
  //                 obscureText: true,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Current Password',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               TextField(
  //                 controller: _newPasswordController,
  //                 obscureText: true,
  //                 decoration: const InputDecoration(
  //                   labelText: 'New Password',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               TextField(
  //                 controller: _confirmPasswordController,
  //                 obscureText: true,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Confirm New Password',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Implement password change logic here
  //               // Validate inputs and update password

  //               if (_newPasswordController.text ==
  //                   _confirmPasswordController.text) {
  //                 // Update password logic
  //                 Navigator.pop(context);
  //                 _showSuccessSnackBar('Password updated successfully');
  //               } else {
  //                 _showErrorSnackBar('Passwords don\'t match');
  //               }
  //             },
  //             child: const Text('Update'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement account deletion logic here
                Navigator.pop(context);
                // Show confirmation message
                _showSuccessSnackBar('Account deleted successfully');
                // Navigate to login screen
                // Add navigation logic here
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }
}
