import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/helpers/helpers.dart';
import 'package:taxi_app/models/profile.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/methods.dart';

class AvailableRidesScreen extends StatefulWidget {
  const AvailableRidesScreen({super.key});

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = 'Currently Offline';
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  late LocationSettings locationSettings;
  Profile? currentDriver;

  Future<void> locateDriverPosition() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 100,
        maximumAge: Duration(minutes: 5),
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 100,
      );
    }
    Position cPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    if (!mounted) return;
    String humanReadableAddress =
        await AppMethods.searchAddressFromGeographicalCoordinates(
          driverCurrentPosition!,
          context,
        );

    print("Address: $humanReadableAddress");
    // initializeGeoFireListner();
    // AppMethods.readTripsKeysForOnlineUser(context);
  }

  void checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
  }

  void readCurrentDriverInformation() {
    currentDriver = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Available Rides',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00009A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 40),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                locateDriverPosition();
              },
            ),

            statusText != 'Now Online'
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    color: Colors.black87,
                  )
                : Container(),

            Positioned(
              top: statusText != 'Now Online'
                  ? MediaQuery.of(context).size.height * 0.45
                  : 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (isDriverActive != true) {
                        driverIsOnlineNow();
                        updateDriverLocationInRealTime();

                        setState(() {
                          statusText = 'Now Online';
                          isDriverActive = true;
                          buttonColor = Colors.transparent;
                        });
                      } else {
                        driverIsOfflineNow();
                        setState(() {
                          statusText = 'Currently Offline';
                          isDriverActive = false;
                          buttonColor = Colors.grey;
                        });
                        final snackBar = SnackBar(
                          content: const Text('You are currently offline'),
                          duration: const Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: statusText != 'Now Online'
                        ? Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.phonelink_ring,
                            color: Colors.white,
                            size: 20,
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

  Future<void> driverIsOnlineNow() async {
    // Position pos = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );

    // driverCurrentPosition = pos;

    // Geofire.initialize('activeDrivers');
    // Geofire.setLocation(
    //   currentDriver!.id,
    //   driverCurrentPosition!.latitude,
    //   driverCurrentPosition!.longitude,
    // );

    // DatabaseReference ref = FirebaseDatabase.instance
    //     .ref()
    //     .child('drivers')
    //     .child(currentDriver!.id)
    //     .child('newRideStatus');
    // ref.set('idle');
    // ref.onValue.listen((event) {});
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      driverCurrentPosition = pos;

      Geofire.initialize('activeDrivers');
      Geofire.setLocation(
        currentDriver!.id,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      // Create driver entry in Realtime DB
      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child('activeDrivers')
          .child(currentDriver!.id);

      await driverRef.set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'status': 'idle',
        'updatedAt': ServerValue.timestamp,
      });

      // Start listening for location updates
      // updateDriverLocationInRealTime();
    } catch (e) {
      debugPrint('Error setting driver online: $e');
    }
  }

  void updateDriverLocationInRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((
      Position position,
    ) {
      if (isDriverActive == true) {
        Geofire.setLocation(
          currentDriver!.id,
          driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude,
        );
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void driverIsOfflineNow() {
    Geofire.removeLocation(currentDriver!.id);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child('activeDrivers')
        .child(currentDriver!.id);
    // .child('newRideStatus');

    ref.onDisconnect();
    ref.remove();
    ref = null;

    // Future.delayed(Duration(milliseconds: 2000), () {
    //   SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    // });
  }
}
