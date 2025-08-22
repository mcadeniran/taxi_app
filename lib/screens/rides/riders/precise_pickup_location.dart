import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/models/direction.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/methods.dart';

class PrecisePickupLocationScreen extends StatefulWidget {
  const PrecisePickupLocationScreen({super.key});

  @override
  State<PrecisePickupLocationScreen> createState() =>
      _PrecisePickupLocationScreenState();
}

class _PrecisePickupLocationScreenState
    extends State<PrecisePickupLocationScreen> {
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
  Position? userCurrentPosition;

  double bottomPaddingOfMap = 0;

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
  }

  Future<void> getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLocation!.latitude,
        longitude: pickLocation!.longitude,
        googleMapApiKey: apiKey!,
      );

      setState(() {
        Direction userPickupAddress = Direction();
        userPickupAddress.locationLatitude = pickLocation!.latitude;
        userPickupAddress.locationLongitude = pickLocation!.longitude;
        userPickupAddress.locationName = data.address;
        // _address = data.address;

        Provider.of<AppInfo>(
          context,
          listen: false,
        ).updatePickUpLocationAddress(userPickupAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  @override
  void initState() {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (isDark) {
      _loadMapStyle();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      key: _scaffoldState,
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 100, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            style: isDark ? _mapStyle : null,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 50;
              });
              locateUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position!.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatLng();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 60, bottom: bottomPaddingOfMap),
              child: Image.asset(
                'assets/images/pin2.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Text(
                Provider.of<AppInfo>(context).userPickUpLocation != null
                    ? (Provider.of<AppInfo>(
                        context,
                      ).userPickUpLocation!.locationName!)
                    : 'Unknown Address',
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkLayer
                      : AppColors.lightLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Text(
                  'Set Current Location',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
