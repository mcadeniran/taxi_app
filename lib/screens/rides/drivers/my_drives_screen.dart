import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/models/ride_history.dart';
import 'package:taxi_app/screens/rides/ride_details_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:taxi_app/controllers/drive_history_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';

class MyDrivesScreen extends StatefulWidget {
  const MyDrivesScreen({super.key});

  @override
  State<MyDrivesScreen> createState() => _MyDrivesScreenState();
}

class _MyDrivesScreenState extends State<MyDrivesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String driverId = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile!.id;
      final provider = Provider.of<DriveHistoryProvider>(
        context,
        listen: false,
      );
      provider.fetchDriverRides(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final driveProvider = Provider.of<DriveHistoryProvider>(context);
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBarWidget(title: 'My Drives'),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: driveProvider.isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : driveProvider.driverRides.isEmpty
            ? Center(child: Text("No completed drives found."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: driveProvider.driverRides.length,
                itemBuilder: (context, index) {
                  RideHistory drive = driveProvider.driverRides[index];
                  return Card(
                    color: isDark ? Colors.black38 : Colors.grey[50],
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RideDetailsScreen(
                              title: 'DRIVE DETAILS',
                              isRider: false,
                              history: drive,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timeago.format(drive.time),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Drive ${index + 1}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(drive.originAddress)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(drive.destinationAddress)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  drive.status,
                                  style: TextStyle(
                                    color: drive.status == 'ended'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
