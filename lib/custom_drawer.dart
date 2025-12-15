import 'package:flutter/material.dart';
import 'package:iris_app/admin_edit_profile.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/edit_profile_screen.dart';
import 'package:iris_app/sign_in.dart';

import 'package:provider/provider.dart';
class CustomDrawer extends StatefulWidget {
  final Map<String, dynamic> staffData;

  CustomDrawer({Key? key, required this.staffData}) : super(key: key);

 

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
                      'Worker',
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
                        builder: (context) =>  EditAdminProfileScreen(
                          staffData:widget.staffData,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),

                // ListTile(
                //   leading: Icon(
                //     themeProvider.isDarkMode
                //         ? Icons.dark_mode
                //         : Icons.light_mode,
                //   ),
                //   title: const Text('Theme'),
                //   trailing: Switch(
                //     value: themeProvider.isDarkMode,
                //     onChanged: (value) {
                //       themeProvider.toggleTheme(value);
                //     },
                //     activeColor: AppColors.primaryBlue,
                //   ),
                // ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen(),));
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
  