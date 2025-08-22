import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/controllers/ride_history_provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/models/ride_history.dart';
import 'package:taxi_app/screens/rides/ride_details_screen.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideHistoryProvider>(context);
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBarWidget(title: 'RIDE HISTORY'),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: rideProvider.isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : rideProvider.userRides.isEmpty
            ? Center(child: Text("No rides found."))
            : ListView.builder(
                itemCount: rideProvider.userRides.length,
                itemBuilder: (context, index) {
                  RideHistory ride = rideProvider.userRides[index];
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
                              title: 'RIDE DETAILS',
                              isRider: true,
                              history: ride,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // ride.time.toString(),
                              timeago.format(ride.time),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
                                Expanded(child: Text(ride.originAddress)),
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
                                Expanded(child: Text(ride.destinationAddress)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ride.status,
                                  style: TextStyle(
                                    color: ride.status == 'ended'
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
