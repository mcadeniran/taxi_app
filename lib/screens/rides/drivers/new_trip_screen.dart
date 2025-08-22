import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/helpers/helpers.dart';
import 'package:taxi_app/models/profile.dart';
import 'package:taxi_app/models/user_ride_request_information.dart';
import 'package:taxi_app/screens/driver_home.dart';
import 'package:taxi_app/screens/rides/drivers/available_rides_screen.dart';
import 'package:taxi_app/screens/widgets/progress_dialog.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/methods.dart';

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;
  const NewTripScreen({super.key, this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newTripGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String buttonTitle = 'Arrived';

  Set<Marker> markersSet = <Marker>{};
  Set<Circle> circlesSet = <Circle>{};
  Set<Polyline> polylinesSet = <Polyline>{};
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimateMarker;
  Geolocator geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = 'accepted';

  String durationFromOriginToDestination = '';

  bool isRequestDirectionDetails = false;

  // Step 1:When driver accepts user's request
  // Origin addres is the driver's current address and destination address is the passanger's pickup address
  //
  // Step 2: When driver reaches the user's location
  // Origin location is user's current location and destination location is the dropoff location

  Future<void> drawPolylineFromOriginToDestination(
    LatLng originLatLng,
    LatLng destinationLatLng,
    bool isDark,
  ) async {
    showDialog(
      context: context,
      builder: ((BuildContext context) =>
          ProgressDialog(message: 'Please wait...')),
    );

    var directionDetailsInfo =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    if (!mounted) return;

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(
      directionDetailsInfo!.ePoints!,
    );

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResultList) {
        polylinePositionCoordinates.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    polylinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylinesSet.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if (originLatLng.longitude > destinationLatLng.longitude &&
        originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }

    newTripGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: MarkerId('originId'),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destinationId'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId('originId'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destinationId'),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  void createDriverIconMarker() {
    if (iconAnimateMarker == null) {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(24, 24),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/car.png',
      ).then((value) => iconAnimateMarker = value);
    }
  }

  void saveAssignedDriverDetailsToUserRideRequest() {
    Profile onlineDriverData = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child('driverId') != 'waiting') {
      databaseReference.child('driverLocation').set(driverLocationDataMap);

      databaseReference.child('status').set('accepted');
      databaseReference.child('driverId').set(onlineDriverData.id);
      databaseReference.child('driverName').set(onlineDriverData.username);
      databaseReference
          .child('driverPhone')
          .set(onlineDriverData.personal.phone);
      databaseReference.child('ratings').set(onlineDriverData.personal.rating);
      // databaseReference
      //     .child('car_details')
      //     .set(
      //       '${onlineDriverData.vehicle.colour} ${onlineDriverData.vehicle.model} ${onlineDriverData.vehicle.numberPlate}',
      //     );
      databaseReference.child('model').set(onlineDriverData.vehicle.model);
      databaseReference.child('colour').set(onlineDriverData.vehicle.colour);
      databaseReference
          .child('numberPlate')
          .set(onlineDriverData.vehicle.numberPlate);

      // saveRideRequestIdToDriverHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This Ride has been accepted by another driver."),
        ),
      );
      Navigator.pop(context);
    }
  }

  // Future<void> saveRideRequestIdToDriverHistory() async {
  //   List<dynamic> allDrives = [];
  //   allDrives.add(widget.userRideRequestDetails!.rideRequestId);
  //   String driverId = Provider.of<ProfileProvider>(
  //     context,
  //     listen: false,
  //   ).profile!.id;

  //   await FirebaseFirestore.instance
  //       .collection('profiles')
  //       .doc(driverId)
  //       .update({'drives': allDrives});
  // }

  void getDriverLocationUpdatesAtRealTime() {
    // LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
        .listen((Position position) {
          driverCurrentPosition = position;
          onlineDriverCurrentPosition = position;

          // if (newTripGoogleMapController == null) {
          //   return;
          // }

          LatLng latLngLiveDriverPosition = LatLng(
            onlineDriverCurrentPosition!.latitude,
            onlineDriverCurrentPosition!.longitude,
          );

          Marker animatingMarker = Marker(
            markerId: MarkerId('AnimatedMarker'),
            position: latLngLiveDriverPosition,
            icon: iconAnimateMarker!,
            infoWindow: InfoWindow(title: 'Your current position'),
          );

          setState(() {
            CameraPosition cameraPosition = CameraPosition(
              target: latLngLiveDriverPosition,
              zoom: 18,
            );
            newTripGoogleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(cameraPosition),
            );

            markersSet.removeWhere(
              (element) => element.markerId.value == 'AnimatedMarker',
            );
            markersSet.add(animatingMarker);
          });

          // oldLatLng = latLngLiveDriverPosition;

          updateDurationInRealTime();

          // Updating driver location in real time in database
          Map driverLatLngMap = {
            'latitude': onlineDriverCurrentPosition!.latitude.toString(),
            'longitude': onlineDriverCurrentPosition!.longitude.toString(),
          };

          FirebaseDatabase.instance
              .ref()
              .child('All Ride Requests')
              .child(widget.userRideRequestDetails!.rideRequestId!)
              .child('driverLocation')
              .set(driverLatLngMap);
        });
  }

  Future<void> updateDurationInRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      LatLng originLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      LatLng destinationLatLng;

      if (rideRequestStatus == 'accepted') {
        destinationLatLng = widget.userRideRequestDetails!.originLatLng!;
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;
      }

      var directionInformation =
          await AppMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng,
            destinationLatLng,
          );

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.durationText!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  Future<void> endTripNow() async {
    showDialog(
      context: context,
      builder: ((BuildContext context) =>
          ProgressDialog(message: 'Please wait...')),
    );

    // get the trip details = distance travelled
    // var currentDriverPositionLatLng = LatLng(
    //   onlineDriverCurrentPosition!.latitude,
    //   onlineDriverCurrentPosition!.longitude,
    // );

    // For calculating fare

    // var tripDirectionDetails =
    //     await AppMethods.obtainOriginToDestinationDirectionDetails(
    //       currentDriverPositionLatLng,
    //       widget.userRideRequestDetails!.originLatLng!,
    //     );

    // Fare amount

    // End trip
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child('status')
        .set('ended');

    String driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;

    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(driverId)
        .update({'newRideStatus': 'idle'});

    // Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (c) => AvailableRidesScreen()),
    // );
    if (!mounted) return;

    final shouldGoHome = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Ride Completed",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Your ride has ended successfully.\n\nDo you want to return to the home screen?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Stay",
                style: TextStyle(color: AppColors.tertiary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Go Home"),
            ),
          ],
        );
      },
    );

    if (shouldGoHome == true) {
      cleanupResources();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const DriverHome()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const AvailableRidesScreen()),
        (route) => false,
      );
    }
  }

  void cleanupResources() {
    streamSubscriptionDriverLivePosition?.cancel();
    newTripGoogleMapController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    createDriverIconMarker();
    // Get driver's initial location safely
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((
      position,
    ) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      setState(() {}); // trigger rebuild once we have location
    });

    // Save ride details
    saveAssignedDriverDetailsToUserRideRequest();
  }

  @override
  void dispose() {
    // Cancel live location updates
    streamSubscriptionDriverLivePosition?.cancel();

    // Dispose Google Map controller
    newTripGoogleMapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: markersSet,
            circles: circlesSet,
            polylines: polylinesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude,
              );

              var userPickupLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolylineFromOriginToDestination(
                driverCurrentLatLng,
                userPickupLatLng!,
                isDark,
              );

              getDriverLocationUpdatesAtRealTime();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Duration
                    Text(
                      "$durationFromOriginToDestination To Pickup",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 0.5, color: AppColors.border),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.userRideRequestDetails!.username!),
                        IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/origin.png',
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/destination.png',
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 0.5, color: AppColors.border),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Driver arrives at pickup station - Arrived Button

                        if (rideRequestStatus == 'accepted') {
                          rideRequestStatus = 'arrived';

                          FirebaseDatabase.instance
                              .ref()
                              .child('All Ride Requests')
                              .child(
                                widget.userRideRequestDetails!.rideRequestId!,
                              )
                              .child('status')
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = 'Start Trip';
                          });

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: ((BuildContext context) =>
                                ProgressDialog(message: 'Loading...')),
                          );

                          await drawPolylineFromOriginToDestination(
                            widget.userRideRequestDetails!.originLatLng!,
                            widget.userRideRequestDetails!.destinationLatLng!,
                            isDark,
                          );

                          Navigator.pop(context);
                        }
                        // User is onboard - Trip Started Button
                        else if (rideRequestStatus == 'arrived') {
                          rideRequestStatus = 'ontrip';

                          FirebaseDatabase.instance
                              .ref()
                              .child('All Ride Requests')
                              .child(
                                widget.userRideRequestDetails!.rideRequestId!,
                              )
                              .child('status')
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = 'End Trip';
                          });
                        }
                        // User reached dropoff location
                        else if (rideRequestStatus == 'ontrip') {
                          endTripNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.2,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.directions_car, size: 25),
                      label: Text(buttonTitle),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
