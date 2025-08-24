import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';

import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/l10n/app_localizations.dart';
import 'package:taxi_app/screens/edit_profile.dart';
import 'package:taxi_app/screens/settings/Change_password_screen.dart';
import 'package:taxi_app/screens/settings/contact_us_screen.dart';
import 'package:taxi_app/screens/settings/delete_account_screen.dart';
import 'package:taxi_app/screens/settings/terms_and_conditions_screen.dart';
import 'package:taxi_app/screens/settings/vehicle_details_screen.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/screens/widgets/change_theme_button_widget.dart';
import 'package:taxi_app/screens/widgets/language_picker_widget.dart';
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
    await authService.logout();
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
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.settings.toUpperCase(),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return CircularProgressIndicator();
          }
          final profile = userProvider.profile;
          return profile == null
              ? Center(child: Text('Profile Not Found'))
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ListView(
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
                                  radius: 40,
                                  backgroundColor: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    child: Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      width: 68,
                                      height: 68,
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
                                      profile.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      profile.email,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppLocalizations.of(context)!.accountTitle,
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
                            if (profile.role == 'driver') ...[
                              SettingWidget(
                                icon: Icons.car_rental,
                                title: 'Vehicle Details',
                                page: const VehicleDetailsScreen(),
                              ),
                              Divider(
                                height: 0,
                                color: Colors.black12,
                                thickness: 0.4,
                              ),
                            ],
                            SettingWidget(
                              title: AppLocalizations.of(
                                context,
                              )!.changePassword,
                              icon: Icons.lock,
                              page: const ChangePasswordScreen(),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.black12,
                              thickness: 0.4,
                            ),
                            SettingWidget(
                              title: AppLocalizations.of(
                                context,
                              )!.deleteAccount,
                              icon: Icons.delete_forever,
                              page: const DeleteAccountScreen(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
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
                                    Iconify(
                                      Carbon.ibm_watson_language_translator,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.changeLanguage,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                LanguagePickerWidget(),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.moon_stars, size: 18),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.enableDarkMode,
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
                              title: AppLocalizations.of(
                                context,
                              )!.enableNotifications,
                              icon: Icons.notifications_none,
                              page: const DeleteAccountScreen(),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.black12,
                              thickness: 0.4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppLocalizations.of(context)!.supportTitle,
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
                              title: AppLocalizations.of(context)!.contactUs,
                              icon: Icons.contact_support,
                              page: const ContactUsScreen(),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.black12,
                              thickness: 0.4,
                            ),
                            SettingWidget(
                              title: AppLocalizations.of(
                                context,
                              )!.termsAndConditions,
                              icon: Icons.article,
                              page: const TermsAndConditionsScreen(),
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
                                AppLocalizations.of(context)!.logOut,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
