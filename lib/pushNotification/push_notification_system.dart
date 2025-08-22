import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/models/user_ride_request_information.dart';
import 'package:taxi_app/pushNotification/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    // 1. Terminated (APP is closed and open directly when notification clicked)
    messaging.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
          remoteMessage.data['rideRequestId'],
          context,
        );
      }
    });

    // 2. Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
        remoteMessage!.data['rideRequestId'],
        context,
      );
    });

    // 3. Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
        remoteMessage!.data['rideRequestId'],
        context,
      );
    });
  }

  void readUserRideRequestInformation(String userRideRequestId, context) {
    String uid = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(userRideRequestId)
        .child('driverId')
        .onValue
        .listen((event) {
          if (event.snapshot.value == 'waiting' ||
              event.snapshot.value == uid) {
            FirebaseDatabase.instance
                .ref()
                .child('All Ride Requests')
                .child(userRideRequestId)
                .once()
                .then((snapData) {
                  if (snapData.snapshot.value != null) {
                    // TODO:
                    // PLAY ALERT AUDIO

                    double originLat = double.parse(
                      (snapData.snapshot.value! as Map)['origin']['latitude'],
                    );
                    double originLng = double.parse(
                      (snapData.snapshot.value! as Map)['origin']['longitude'],
                    );
                    String originAddress =
                        (snapData.snapshot.value as Map)['originAddress'];

                    double destinationLat = double.parse(
                      (snapData.snapshot.value!
                          as Map)['destination']['latitude'],
                    );
                    double destinationLng = double.parse(
                      (snapData.snapshot.value!
                          as Map)['destination']['longitude'],
                    );
                    String destinationAddress =
                        (snapData.snapshot.value as Map)['destinationAddress'];

                    String username =
                        (snapData.snapshot.value! as Map)['username'];

                    String userPhone =
                        (snapData.snapshot.value! as Map)['userPhone'];

                    String? rideRequestId = snapData.snapshot.key;

                    UserRideRequestInformation userRideRequestDetails =
                        UserRideRequestInformation();
                    userRideRequestDetails.originLatLng = LatLng(
                      originLat,
                      originLng,
                    );
                    userRideRequestDetails.destinationLatLng = LatLng(
                      destinationLat,
                      destinationLng,
                    );
                    userRideRequestDetails.destinationAddress =
                        destinationAddress;
                    userRideRequestDetails.originAddress = originAddress;
                    userRideRequestDetails.userPhone = userPhone;
                    userRideRequestDetails.username = username;
                    userRideRequestDetails.rideRequestId = rideRequestId;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => NotificationDialogBox(
                        userRideRequestDetails: userRideRequestDetails,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This Ride does not exists."),
                      ),
                    );
                  }
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This Ride request has been cancelled."),
              ),
            );
            Navigator.pop(context);
          }
        });
  }

  Future generateAndGetToken(BuildContext context) async {
    String userId = Provider.of<ProfileProvider>(context).profile!.id;
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: $registrationToken");
    await FirebaseFirestore.instance.collection('profiles').doc(userId).update({
      'token': registrationToken,
    });

    messaging.subscribeToTopic('allDrivers');
    messaging.subscribeToTopic('allUsers');
  }
}
