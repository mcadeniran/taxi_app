import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/helpers/helpers.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/l10n/app_localizations.dart';
import 'package:taxi_app/models/active_nearby_available_driver.dart';
import 'package:taxi_app/models/profile.dart';
import 'package:taxi_app/screens/customer_home.dart';
import 'package:taxi_app/screens/rides/riders/precise_pickup_location.dart';
import 'package:taxi_app/screens/rides/riders/search_places_screen.dart';
import 'package:taxi_app/screens/widgets/progress_dialog.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/geofire_assistant.dart';
import 'package:taxi_app/utils/methods.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launchUrl(url as Uri);
  } else {
    throw '${AppLocalizations.of(context)!.couldNotCallDriver} $url';
  }
}

class RequestRide extends StatefulWidget {
  const RequestRide({super.key});

  @override
  State<RequestRide> createState() => _RequestRideState();
}

class _RequestRideState extends State<RequestRide> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRideContainerHeight = 0;
  double searchingForDriversContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String username = "";
  String userEmail = "";
  String userRideRequestStatus = '';

  // String? _address;
  bool activateNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = 'Driver is coming';
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  List<ActiveNearbyAvailableDriver> onlineNearbyAvailableDriversList = [];

  bool requestPositionInfo = true;

  String? _mapStyle;

  late LocationSettings locationSettings;

  Future<void> locateUserPosition() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "KIPGO will continue to receive your location even when you aren't using it",
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

    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
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
          userCurrentPosition!,
          context,
        );

    print("Address: $humanReadableAddress");

    if (!mounted) return;
    driverRideStatus = AppLocalizations.of(context)!.driverIsComing;
    username = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.username;

    initializeGeoFireListner();
    // AppMethods.readTripsKeysForOnlineUser(context);
  }

  StreamSubscription<dynamic>? _geoQuerySubscription;

  void initializeGeoFireListner() {
    Geofire.initialize('activeDrivers');

    _geoQuerySubscription =
        Geofire.queryAtLocation(
          userCurrentPosition!.latitude,
          userCurrentPosition!.longitude,
          10,
        )!.listen((map) {
          if (map != null) {
            var callBack = map['callBack'];

            switch (callBack) {
              // Whenever any driver becomes active/online
              case Geofire.onKeyEntered:
                GeofireAssistant.activeNearbyAvailableDriversList.clear();
                ActiveNearbyAvailableDriver activeNearbyAvailableDriver =
                    ActiveNearbyAvailableDriver();
                activeNearbyAvailableDriver.driverId = map['key'];
                activeNearbyAvailableDriver.locationLatitude = map['latitude'];
                activeNearbyAvailableDriver.locationLongitude =
                    map['longitude'];
                GeofireAssistant.activeNearbyAvailableDriversList.add(
                  activeNearbyAvailableDriver,
                );

                if (activateNearbyDriverKeysLoaded == true) {
                  displayActiveDriversOnUserMap();
                }
                break;

              // Whenever any driver goes inactive/offline
              case Geofire.onKeyExited:
                GeofireAssistant.deleteOfflineDriverFromList(map['key']);
                displayActiveDriversOnUserMap();
                break;

              // Whenever a driver moves - update location
              case Geofire.onKeyMoved:
                ActiveNearbyAvailableDriver activeNearbyAvailableDriver =
                    ActiveNearbyAvailableDriver();
                activeNearbyAvailableDriver.driverId = map['key'];
                activeNearbyAvailableDriver.locationLatitude = map['latitude'];
                activeNearbyAvailableDriver.locationLongitude =
                    map['longitude'];
                GeofireAssistant.updateActiveNearbyAvailableDriverLocation(
                  activeNearbyAvailableDriver,
                );
                displayActiveDriversOnUserMap();
                break;

              // Display online active drivers on user's map
              case Geofire.onGeoQueryReady:
                activateNearbyDriverKeysLoaded = true;
                displayActiveDriversOnUserMap();
                break;
            }
          }
          setState(() {});
        });
  }

  void displayActiveDriversOnUserMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = <Marker>{};

      for (ActiveNearbyAvailableDriver eachDriver
          in GeofireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(
          eachDriver.locationLatitude!,
          eachDriver.locationLongitude!,
        );

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });
  }

  void createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(30, 30),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/car.png',
      ).then((value) => activeNearbyIcon = value);
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool isDark) async {
    var originPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userDropOffLocation;

    if (destinationPosition == null) {
      return;
    }

    var originLatLng = LatLng(
      originPosition!.locationLatitude!,
      originPosition.locationLongitude!,
    );

    var destinationLatLng = LatLng(
      destinationPosition.locationLatitude!,
      destinationPosition.locationLongitude!,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
    );

    var directionDetailsInfo =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    if (!mounted) return;

    Navigator.pop(context);

    if (directionDetailsInfo == null) return;

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList = pPoints.decodePolyline(
      directionDetailsInfo.ePoints!,
    );

    pLineCoordinateList.clear();

    if (decodePolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointsResultList) {
        pLineCoordinateList.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: pLineCoordinateList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
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

    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: MarkerId('originId'),
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: AppLocalizations.of(context)!.from,
      ),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destinationId'),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: AppLocalizations.of(context)!.to,
      ),
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

  void checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  void saveRideRequestInformation() {
    referenceRideRequest = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .push();

    var originLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userDropOffLocation;

    Map originLocationMap = {
      // key: 'value',
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      // key: 'value',
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };
    Profile profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    Map userInformationMap = {
      'origin': originLocationMap,
      'destination': destinationLocationMap,
      'time': DateTime.now().toString(),
      'userId': profile.id,
      'username': profile.username,
      'userPhone': profile.personal.phone,
      'originAddress': originLocation.locationName,
      'destinationAddress': destinationLocation.locationName,
      'driverId': 'waiting',
    };

    referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((
      eventSnap,
    ) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)['model'] != null) {
        setState(() {
          driverCarModel = (eventSnap.snapshot.value as Map)['model']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['colour'] != null) {
        setState(() {
          driverCarColour = (eventSnap.snapshot.value as Map)['colour']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['numberPlate'] != null) {
        setState(() {
          driverNumberPlate = (eventSnap.snapshot.value as Map)['numberPlate']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverPhone'] != null) {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)['driverPhone']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverName'] != null) {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)['driverName']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverPhotoUrl'] != null) {
        setState(() {
          driverPhotoUrl = (eventSnap.snapshot.value as Map)['driverPhotoUrl']
              .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['status'] != null) {
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)['status']
              .toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)['driverLocation'] != null) {
        double driverCurrentPositionLat = double.parse(
          (eventSnap.snapshot.value as Map)['driverLocation']['latitude']
              .toString(),
        );
        double driverCurrentPositionLng = double.parse(
          (eventSnap.snapshot.value as Map)['driverLocation']['longitude']
              .toString(),
        );

        LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPositionLat,
          driverCurrentPositionLng,
        );

        // status = 'accepted'
        if (userRideRequestStatus == 'accepted') {
          updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
        }

        // status = 'arrived'
        if (userRideRequestStatus == 'arrived') {
          setState(() {
            driverRideStatus = AppLocalizations.of(context)!.driverHasArrived;
          });
        }

        // status = 'onTrip'
        if (userRideRequestStatus == 'ontrip') {
          updateReachingTimeToUserDropoffLocation(driverCurrentPositionLatLng);
        }

        // if (userRideRequestStatus == 'ended') {
        //   // setState(() {
        //   //   assignedDriverInfoContainerHeight = 0;
        //   // });
        //   // referenceRideRequest!.onDisconnect();
        //   // tripRideRequestInfoStreamSubscription!.cancel();
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(builder: (c) => CustomerHome()),
        //   // );
        //   // cleanupRideResources();

        //   // Navigate back to Customer Home
        //   // if (mounted) {
        //   //   Navigator.pushReplacement(
        //   //     context,
        //   //     MaterialPageRoute(builder: (c) => CustomerHome()),
        //   //   );
        //   // }

        //   // if ((eventSnap.snapshot.value as Map)['driverId'] != null) {
        //   //   String assignedDriverId =
        //   //       (eventSnap.snapshot.value as Map)['driverId'].toString();
        //   //   // Navigator.push(
        //   //   //   context,
        //   //   //   MaterialPageRoute(builder: (c) => RateDriverScreen),
        //   //   // );
        //   // }
        // }
        if (userRideRequestStatus == 'ended') {
          setState(() {
            assignedDriverInfoContainerHeight = 0;
          });

          // 🔑 Cleanup resources before navigating
          cleanupRideResources();

          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false, // user must tap the button
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Theme.of(
                    context,
                  ).scaffoldBackgroundColor, // custom color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.rideCompleted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // color: AppColors.primary,
                    ),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.yourRideHasEnded,
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                      },
                      child: Text(
                        AppLocalizations.of(context)!.stay,
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
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const CustomerHome(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.goHome),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    });

    onlineNearbyAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriversContainerHeight = 200;
    });
  }

  Future<void> updateArrivalTimeToUserPickupLocation(
    LatLng driverCurrentPositionLatLng,
  ) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickupPosition = LatLng(
        userCurrentPosition!.latitude,
        userCurrentPosition!.longitude,
      );

      var directionDetailsInfo =
          await AppMethods.obtainOriginToDestinationDirectionDetails(
            driverCurrentPositionLatLng,
            userPickupPosition,
          );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
            "${AppLocalizations.of(context)!.driverIsComing}: ${directionDetailsInfo.durationText}";
      });

      requestPositionInfo = true;
    }
  }

  Future<void> updateReachingTimeToUserDropoffLocation(
    LatLng driverCurrentPositionLatLng,
  ) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropoffLocation = Provider.of<AppInfo>(
        context,
        listen: false,
      ).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
        dropoffLocation!.locationLatitude!,
        dropoffLocation.locationLongitude!,
      );

      var directionDetailsInfo =
          await AppMethods.obtainOriginToDestinationDirectionDetails(
            driverCurrentPositionLatLng,
            userDestinationPosition,
          );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
            '${AppLocalizations.of(context)!.goingTowardsDestination}: ${directionDetailsInfo.durationText}';
      });

      requestPositionInfo = true;
    }
  }

  Future<void> searchNearestOnlineDrivers() async {
    if (onlineNearbyAvailableDriversList.isEmpty) {
      // Cancel/Delete the ride request information
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoordinateList.clear();
      });
      final noDriverSnackbar = SnackBar(
        content: Text(AppLocalizations.of(context)!.noAvailableDriverNearby),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(noDriverSnackbar);

      return;
    }

    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    for (int i = 0; i < driversList.length; i++) {
      AppMethods.sendNotificationToDriverNow(
        driversList[i]['token'],
        referenceRideRequest!.key!,
        context,
      );
    }

    showSearchingForDriversContainer();

    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(referenceRideRequest!.key!)
        .child('driverId')
        .onValue
        .listen((eventRideRequestSnapshot) {
          if (eventRideRequestSnapshot.snapshot.value != null) {
            if (eventRideRequestSnapshot.snapshot.value != 'waiting') {
              showUIForAssignedDriverInfo();
            }
          }
        });
  }

  void showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 280;
      suggestedRideContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  Future<void> retrieveOnlineDriversInformation(
    List onlineNearestDriverList,
  ) async {
    driversList.clear();

    for (int i = 0; i < onlineNearestDriverList.length; i++) {
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(onlineNearestDriverList[i].driverId)
          .get()
          .then((dataSnapshot) {
            var driverKeyInfo = dataSnapshot.data();

            driversList.add(driverKeyInfo);
          });
    }
  }

  @override
  void initState() {
    super.initState();
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (isDark) {
      _loadMapStyle();
    }
    checkIfLocationPermissionAllowed();
  }

  void cleanupRideResources() {
    // Cancel ride request subscription
    tripRideRequestInfoStreamSubscription?.cancel();
    tripRideRequestInfoStreamSubscription = null;

    // Cancel GeoFire subscription
    _geoQuerySubscription?.cancel();
    _geoQuerySubscription = null;

    // Clean up Firebase ride request reference
    referenceRideRequest?.onDisconnect();
    referenceRideRequest = null;

    // Dispose Google Maps controller
    newGoogleMapController?.dispose();
    newGoogleMapController = null;

    // Reset temporary data (optional, keeps things tidy)
    markersSet.clear();
    circlesSet.clear();
    polylineSet.clear();
    pLineCoordinateList.clear();
    userRideRequestStatus = '';
    // driverRideStatus = AppLocalizations.of(context)!.driverIsComing;
  }

  @override
  void dispose() {
    cleanupRideResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    createActiveNearbyDriverIconMarker();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              style: isDark ? _mapStyle : null,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              circles: circlesSet,
              markers: markersSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 200;
                });
                locateUserPosition();
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                              // color: Colors.red,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Iconify(
                                        Ic.my_location,
                                        color: isDark
                                            ? AppColors.darkLayer
                                            : AppColors.primary,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.from,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? AppColors.darkLayer
                                                    : AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(
                                                        context,
                                                      ).userPickUpLocation !=
                                                      null
                                                  ? (Provider.of<AppInfo>(
                                                          context,
                                                        )
                                                        .userPickUpLocation!
                                                        .locationName!)
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.unknownAddress,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () async {
                                      var responseFromSearchScreen =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  SearchPlacesScreen(),
                                            ),
                                          );

                                      if (responseFromSearchScreen ==
                                          'obtainedDropOff') {
                                        setState(() {
                                          // do something
                                        });
                                      }

                                      await drawPolyLineFromOriginToDestination(
                                        isDark,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Iconify(
                                          Ic.location_on,
                                          color: isDark
                                              ? AppColors.darkLayer
                                              : AppColors.primary,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.to,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppColors.darkLayer
                                                      : AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                Provider.of<AppInfo>(
                                                          context,
                                                        ).userDropOffLocation !=
                                                        null
                                                    ? (Provider.of<AppInfo>(
                                                            context,
                                                          )
                                                          .userDropOffLocation!
                                                          .locationName!)
                                                    : AppLocalizations.of(
                                                        context,
                                                      )!.enterDestination,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) =>
                                          PrecisePickupLocationScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.tertiary
                                      : AppColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      4.0,
                                    ), // Adjust the radius as needed
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.changePickup,
                                  style: TextStyle(
                                    // color: isDark ? Colors.white : Colors.black,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (Provider.of<AppInfo>(
                                            context,
                                            listen: false,
                                          ).userDropOffLocation !=
                                          null &&
                                      Provider.of<AppInfo>(
                                            context,
                                            listen: false,
                                          ).userPickUpLocation !=
                                          null) {
                                    saveRideRequestInformation();
                                  } else {
                                    final snackBarPickup = SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.pleaseEnterPickupAddress,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    );
                                    final snackBarDestination = SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.pleaseEnterDestination,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    );

                                    if (Provider.of<AppInfo>(
                                          context,
                                          listen: false,
                                        ).userPickUpLocation ==
                                        null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(snackBarPickup);
                                    } else if (Provider.of<AppInfo>(
                                          context,
                                          listen: false,
                                        ).userDropOffLocation ==
                                        null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(snackBarDestination);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      4.0,
                                    ), // Adjust the radius as needed
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.requestARide,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Requesting a ride
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: searchingForDriversContainerHeight,
                // height: 180,
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: isDark
                          ? AppColors.darkLayer
                          : AppColors.primary,
                      color: AppColors.tertiary,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.searchingForDriver,
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.headlineSmall!.color!.withAlpha(100),
                            ),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        referenceRideRequest!.remove();
                        setState(() {
                          searchingForDriversContainerHeight = 0;
                          suggestedRideContainerHeight = 0;
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1, color: AppColors.border),
                        ),
                        child: Icon(Icons.close, size: 25),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // UI for displaying assigned driver information
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                // padding: EdgeInsets.all(10),
                height: assignedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(driverRideStatus),
                      SizedBox(height: 5),
                      Divider(thickness: 0.5, color: AppColors.border),
                      SizedBox(height: 5),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            // shape: const CircleBorder(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: driverPhotoUrl == ''
                                ? Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      // shape: BoxShape.circle,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        // username[0].toUpperCase(),
                                        'J',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  )
                                : FadeInImage.assetNetwork(
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                    placeholder: "assets/images/avatar.png",
                                    image: driverPhotoUrl,
                                    fadeInDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    fadeOutDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    imageErrorBuilder: (c, e, s) => Image.asset(
                                      "assets/images/avatar.png",
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange.shade200,
                                  ),
                                  SizedBox(width: 5),
                                  Text('4.5'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("$driverCarColour $driverCarModel"),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(driverNumberPlate),
                          ),
                        ],
                      ),
                      Divider(thickness: 0.5, color: AppColors.border),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: MediaQuery.of(context).size.width / 8,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _makePhoneCall(context, "tel: $driverPhone");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00009A),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.call),
                          label: Text(AppLocalizations.of(context)!.callDriver),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
