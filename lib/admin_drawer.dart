import 'package:flutter/material.dart';
import 'package:iris_app/admin_edit_profile.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/cerberus.dart';
import 'package:iris_app/products.dart';
import 'package:iris_app/sign_in.dart';
import 'package:iris_app/worker_management.dart';

import 'package:provider/provider.dart';

class AdminDrawer extends StatefulWidget {
  final Map<String, dynamic> staffData;

  const AdminDrawer({Key? key, required this.staffData}) : super(key: key);

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  get staffData => widget.staffData;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Admin Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.primaryBlue),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    staffData['email'].toString().split('@')[0],
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staffData['email'] ?? 'No email provided',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditAdminProfileScreen(staffData: widget.staffData),
                      ),
                    );
                  },
                ),
                const Divider(),

            
             
                 ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Worker Management'),
                  onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context) =>      WorkersManagementScreen(
 staffData: widget.staffData),));
   
                    // close the drawer or bottom sheet if needed
                  },
                ),
                 ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Products Information'),
                  onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context) =>  WarehouseProductsScreen(staffData: widget.staffData)));
           
                    // close the drawer or bottom sheet if needed
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('IRIS AI'),
                  onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context) =>  ChatScreen( staffData: widget.staffData,role:"manager"),));
        
                    // close the drawer or bottom sheet if needed
                  },
                ),
              ],
            ),
          ),

          // Logout
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
