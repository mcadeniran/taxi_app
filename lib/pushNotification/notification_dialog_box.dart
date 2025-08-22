import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/models/user_ride_request_information.dart';
import 'package:taxi_app/screens/rides/drivers/new_trip_screen.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/methods.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformation userRideRequestDetails;
  const NotificationDialogBox({
    super.key,
    required this.userRideRequestDetails,
  });

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(2),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/taksi.png', width: 150, height: 150),
            SizedBox(height: 0),
            Text(
              'New Ride Request',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 14),
            Divider(height: 2, thickness: 2, color: AppColors.border),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/origin.png',
                        color: isDark
                            // ? AppColors.secondary
                            ? Colors.tealAccent
                            : AppColors.primary,
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails.originAddress!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/destination.png',
                        color: isDark
                            ? AppColors.tertiary
                            // : Colors.redAccent.shade400,
                            : AppColors.tertiary,
                        // color: isDark ? AppColors.tertiary : AppColors.primary,
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails.destinationAddress!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 2, thickness: 2, color: AppColors.border),
            Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Stop audio
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO:
                      // Stop audio
                      print('REQUEST ACCEPTED');
                      acceptRideRequest(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'ACCEPT',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void acceptRideRequest(BuildContext context) async {
    String driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;

    await FirebaseFirestore.instance
        .collection("profiles")
        .doc(driverId)
        .get()
        .then((dataSnapshot) async {
          print(dataSnapshot.data());
          var driverKeyInfo = dataSnapshot.data();
          var driverStatus = driverKeyInfo!['newRideStatus'];

          print("Driver Status: $driverStatus");
          print('Driver Key Information: $driverKeyInfo');

          if (driverStatus == null || driverStatus == 'idle') {
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(driverId)
                .update({'newRideStatus': 'accepted'});

            AppMethods.pauseLiveLocationUpdates(userId: driverId);

            // Trip started now, send driver to new tripScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => NewTripScreen(
                  userRideRequestDetails: widget.userRideRequestDetails,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ride request is not available')),
            );
            Navigator.pop(context);
          }
        });
  }
}
