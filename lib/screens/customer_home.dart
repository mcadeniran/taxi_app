import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/pushNotification/push_notification_system.dart';
import 'package:taxi_app/screens/rides/riders/ride_history_screen.dart'
    as history;
import 'package:taxi_app/screens/profile_screen.dart' as profile;
import 'package:taxi_app/screens/rides/riders/request_ride.dart';
import 'package:taxi_app/screens/settings_screen.dart' as settings;
import 'package:taxi_app/screens/text_screen.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/utils/colors.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBarWidget(title: 'KIPGO'),
      backgroundColor: AppColors.primary,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading) {
                    return CircularProgressIndicator.adaptive();
                  }
                  final displayName = profileProvider.profile!.username;
                  return Text(
                    "Hi $displayName",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // color: const Color(0xFF00009A),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3);
                },
              ),
              const SizedBox(height: 10),
              Text(
                "What would you like to do today?",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Buttons grid
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 140,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                children: [
                  _buildOptionCard(
                    context,
                    title: "Request Ride",
                    icon: Icons.directions_car,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestRide()),
                        // MaterialPageRoute(builder: (_) => const InitiateRide()),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: "Ride History",
                    icon: Icons.history,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const history.RideHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: "My Profile",
                    icon: Icons.person,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const profile.ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: "Settings",
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const settings.SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: "Test",
                    icon: Icons.laptop_chromebook,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TestScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkLayer : Color(0xFF00009A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Use promo code KIPGO10 to get 10% off your next ride!",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkLayer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Color(0xFF00009A)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
