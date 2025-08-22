import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/ride_history_provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/screens/login_screen.dart';
import 'package:taxi_app/screens/rides/riders/ride_history_screen.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String userId = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile!.id;
      final provider = Provider.of<RideHistoryProvider>(context, listen: false);
      provider.fetchUserRides(userId);
    });
  }

  void _logout() async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final rideProvider = Provider.of<RideHistoryProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBarWidget(title: 'MY PROFILE'),

      body: Consumer<ProfileProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return CircularProgressIndicator();
          }
          final profile = userProvider.profile;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
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
                ),
                SizedBox(height: 18),
                Text('Personal Details'),
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 2),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailsRow(title: 'Username', details: profile!.username),
                      const SizedBox(height: 10),
                      detailsRow(title: 'Email', details: profile.email),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: 'First Name',
                        details: profile.personal.firstName,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: 'Surname',
                        details: profile.personal.lastName,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: 'Phone',
                        details: profile.personal.phone,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Total Rides Taken:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5),
                              rideProvider.isLoading
                                  ? CircularProgressIndicator.adaptive()
                                  : Text(
                                      rideProvider.userRides.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RideHistoryScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.chevron_right_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (profile.role == 'driver') ...[
                  SizedBox(height: 16),
                  Text('Vehicle Details'),
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(top: 2),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailsRow(
                          title: 'Car Model',
                          details: profile.vehicle.model,
                        ),
                        const SizedBox(height: 10),
                        detailsRow(
                          title: 'Colour',
                          details: profile.vehicle.colour,
                        ),
                        const SizedBox(height: 10),
                        detailsRow(
                          title: 'Registration Number',
                          details: profile.vehicle.numberPlate,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Total Rides Driven:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '1',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00009A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Log Out"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row detailsRow({required String title, required String details}) {
    return Row(
      children: [
        Text(
          '$title:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Text(
          details,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
