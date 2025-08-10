import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/screens/widgets/change_theme_button_widget.dart';
import 'package:taxi_app/screens/widgets/setting_widget.dart';
import 'package:taxi_app/services/auth_service.dart';
import 'package:taxi_app/utils/colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authService = AuthService();
  bool notificationsEnabled = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
  }

  void logout() async {
    await authService.signOut(context);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      // backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00009A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return CircularProgressIndicator();
          }
          final profile = userProvider.profile;
          return profile == null
              ? Center(child: Text('Profile Not Found'))
              : ListView(
                  padding: const EdgeInsets.all(12),

                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(top: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 46,
                                backgroundColor: isDark
                                    ? AppColors.darkLayer
                                    : AppColors.primary,
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  child: Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/images/avatar.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Email',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          SettingWidget(
                            title: 'Change Password',
                            icon: Icons.lock,
                          ),
                          Divider(
                            height: 0,
                            color: Colors.black12,
                            thickness: 0.4,
                          ),
                          SettingWidget(
                            title: 'Delete Account',
                            icon: Icons.delete_forever,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "App",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Row(
                                children: [
                                  Icon(CupertinoIcons.moon_stars, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Enable Dark Mode',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              ChangeThemeButtonWidget(),
                            ],
                          ),
                          Divider(
                            height: 0,
                            color: Colors.black12,
                            thickness: 0.4,
                          ),
                          SettingWidget(
                            title: 'Enable Notifications',
                            icon: Icons.notifications_none,
                          ),
                          Divider(
                            height: 0,
                            color: Colors.black12,
                            thickness: 0.4,
                          ),
                          SettingWidget(
                            title: 'Delete Account',
                            icon: Icons.delete_forever,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Support",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          SettingWidget(
                            title: 'Contact Us',
                            icon: Icons.contact_support,
                          ),
                          Divider(
                            height: 0,
                            color: Colors.black12,
                            thickness: 0.4,
                          ),
                          SettingWidget(
                            title: 'Terms & Conditions',
                            icon: Icons.article,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: logout,
                        child: Row(
                          children: [
                            Icon(
                              Icons.login_outlined,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Log Out',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
