import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/models/predicted_places.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';
import 'package:taxi_app/screens/widgets/search_location.dart';
import 'package:taxi_app/utils/colors.dart';

enum RideState {
  choosingLocation,
  confirmFare,
  waitingForPickup,
  riding,
  postRide,
}

// final places = GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_API_KEY']!);
final supabase = Supabase.instance.client;

class InitiateRide extends StatefulWidget {
  const InitiateRide({super.key});

  @override
  State<InitiateRide> createState() => _InitiateRideState();
}

class _InitiateRideState extends State<InitiateRide> {
  RideState _rideState = RideState.choosingLocation;
  LatLng? _currentLocation;
  LatLng? _selectedDestination;
  CameraPosition? _initialPosition;
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  BitmapDescriptor? _pinIcon;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool useCurrentLocation = true;
  late Placemark originPlace;
  late Placemark destinationPlace;
  List<PredictedPlaces> predictedPlacesList = [];

  late LocationSettings locationSettings;

  double? initialLat;
  double? initialLng;
  String? pickupAddress;

  late int _fare;
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadPinIcon();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateMapTheme(GoogleMapController mapController) {
    if (Provider.of<ThemeProvider>(context, listen: false).isDarkMode ==
        false) {
      return;
    }
    getJsonFileFromTheme(
      'map_themes/dark_style.json',
    ).then((value) => setGoogleMapStyle(value, mapController));
  }

  Future<String> getJsonFileFromTheme(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return utf8.decode(list);
  }

  void setGoogleMapStyle(
    String googleMapStyle,
    GoogleMapController mapController,
  ) {
    mapController.setMapStyle(googleMapStyle);
  }

  Future<void> _loadPinIcon() async {
    _pinIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(28, 48)),
      'assets/images/pin2.png',
    );
  }

  Future<void> _checkLocationPermission() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enable location')));
        return;
      }
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please enable location')));
          return;
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enable location')));
        return;
      }
    }

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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];

    String? street = place.street;
    String? locality = place.locality;
    String? administrativeArea = place.administrativeArea;
    String? country = place.country;
    String address =
        '${street!}, ${locality!}, ${administrativeArea!}, ${country!}';

    _pickupController.text = address;
    initialLat = position.latitude;
    initialLng = position.longitude;

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _initialPosition = CameraPosition(target: _currentLocation!, zoom: 15);
    });
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition!),
    );
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error finding location: $e')));
      }
      return null;
    }
  }

  void _goToNextState() {
    setState(() {
      if (_rideState == RideState.postRide) {
        _rideState = RideState.choosingLocation;
      } else {
        _rideState = RideState.values[_rideState.index + 1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Initiate Ride'),
        backgroundColor: AppColors.primary,
        titleTextStyle: TextStyle(
          color: Colors.white, // White color
          fontSize: 20, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          // initialLat == null || initialLng == null || _mapController.
          //     ? const Center(child: CircularProgressIndicator())
          //     :
          Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(initialLat!, initialLng!),
                  zoom: 14,
                ),
                onCameraMove: (position) {
                  if (_rideState == RideState.choosingLocation) {
                    _selectedDestination = position.target;
                  }
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                  updateMapTheme(_mapController);
                },
              ),
              if (_rideState == RideState.choosingLocation)
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Image.asset(
                      'assets/images/pin2.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              Positioned(
                top: defaultTargetPlatform == TargetPlatform.iOS ? 20 : 50,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    TextField(
                      controller: _pickupController,
                      decoration: inputDecoration(
                        context: context,
                        hint: 'Enter pickup address',
                        prefixIcon: Ic.twotone_my_location,
                      ).copyWith(filled: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _destinationController,
                      decoration: inputDecoration(
                        context: context,
                        hint: 'Enter destination address',
                        prefixIcon: Ic.twotone_location_on,
                      ).copyWith(filled: true),
                    ),
                    SearchLocationWidget(
                      // lat: initialLat!, lng: initialLng!
                    ),
                  ],
                ),
              ),
            ],
          ),
      bottomSheet: _rideState == RideState.confirmFare
          ? Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(
                16,
              ).copyWith(bottom: MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirm Trip',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Estimated Fare: ${NumberFormat.currency(symbol: '₺', decimalDigits: 2).format(_fare / 10)}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {},
                    child: Text('Confirm Fare'),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _rideState == RideState.choosingLocation
          ? FloatingActionButton.extended(
              onPressed: () async {
                LatLng? origin;

                // 1. Determine origin
                if (useCurrentLocation) {
                  if (_currentLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Current location not available'),
                      ),
                    );
                    return;
                  }
                  origin = _currentLocation;
                } else {
                  if (_pickupController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a pickup address'),
                      ),
                    );
                    return;
                  }
                  origin = await getCoordinatesFromAddress(
                    _pickupController.text,
                  );
                  if (origin == null) return;
                }

                // 2. Get destination
                if (_destinationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a destination address'),
                    ),
                  );
                  return;
                }

                final destination = await getCoordinatesFromAddress(
                  _destinationController.text,
                );
                if (destination == null) return;

                _selectedDestination = destination;

                // 3. Call Supabase function to get route
                final response = await supabase.functions.invoke(
                  'routes',
                  body: {
                    'origin': {
                      'latitude': origin!.latitude,
                      'longitude': origin.longitude,
                    },
                    'destination': {
                      'latitude': destination.latitude,
                      'longitude': destination.longitude,
                    },
                  },
                );

                final data = response.data as Map<String, dynamic>;
                final coordinates =
                    data['legs'][0]['polyline']['geoJsonLinestring']['coordinates']
                        as List;
                final duration = parseDuration(data['duration'] as String);
                _fare = (duration.inMinutes * 40).ceil();

                final polylineCoordinates = coordinates
                    .map((c) => LatLng(c[1], c[0]))
                    .toList();

                setState(() {
                  _polylines.clear();
                  _markers.clear();

                  _polylines.add(
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylineCoordinates,
                      color: Colors.black,
                      width: 5,
                    ),
                  );

                  _markers.add(
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      icon: _pinIcon!,
                    ),
                  );
                });

                final bounds = LatLngBounds(
                  southwest: LatLng(
                    polylineCoordinates
                        .map((e) => e.latitude)
                        .reduce((a, b) => a < b ? a : b),
                    polylineCoordinates
                        .map((e) => e.longitude)
                        .reduce((a, b) => a < b ? a : b),
                  ),
                  northeast: LatLng(
                    polylineCoordinates
                        .map((e) => e.latitude)
                        .reduce((a, b) => a > b ? a : b),
                    polylineCoordinates
                        .map((e) => e.longitude)
                        .reduce((a, b) => a > b ? a : b),
                  ),
                );

                _mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 50),
                );
                _goToNextState();
              },
              label: const Text('Confirm Destination'),
            )
          : const SizedBox.shrink(),
    );
  }
}


 // floatingActionButton: _rideState == RideState.choosingLocation
      //     ? FloatingActionButton.extended(
      //         onPressed: () async {
      //           final response = await supabase.functions.invoke(
      //             'routes',
      //             body: {
      //               'origin': {
      //                 'latitude': _currentLocation!.latitude,
      //                 'longitude': _currentLocation!.longitude,
      //               },
      //               'destination': {
      //                 'latitude': _selectedDestination!.latitude,
      //                 'longitude': _selectedDestination!.longitude,
      //               },
      //             },
      //           );
      //           final data = response.data as Map<String, dynamic>;
      //           final coordinates =
      //               data['legs'][0]['polyline']['geoJsonLinestring']['coordinates']
      //                   as List<dynamic>;
      //           final duration = parseDuration(data['duration'] as String);
      //           _fare = (duration.inMinutes * 40).ceil();

      //           final polylineCoordinates = coordinates.map((coordinate) {
      //             return LatLng(coordinate[1], coordinate[0]);
      //           }).toList();

      //           setState(() {
      //             _polylines.add(
      //               Polyline(
      //                 polylineId: PolylineId('route'),
      //                 points: polylineCoordinates,
      //                 color: Colors.black,
      //                 width: 5,
      //               ),
      //             );
      //           });

      //           _markers.add(
      //             Marker(
      //               markerId: MarkerId('destination'),
      //               position: _selectedDestination!,
      //               icon: _pinIcon!,
      //             ),
      //           );

      //           final bounds = LatLngBounds(
      //             southwest: LatLng(
      //               polylineCoordinates
      //                   .map((e) => e.latitude)
      //                   .reduce((a, b) => a < b ? a : b),
      //               polylineCoordinates
      //                   .map((e) => e.longitude)
      //                   .reduce((a, b) => a < b ? a : b),
      //             ),
      //             northeast: LatLng(
      //               polylineCoordinates
      //                   .map((e) => e.latitude)
      //                   .reduce((a, b) => a > b ? a : b),
      //               polylineCoordinates
      //                   .map((e) => e.longitude)
      //                   .reduce((a, b) => a > b ? a : b),
      //             ),
      //           );
      //           _mapController.animateCamera(
      //             CameraUpdate.newLatLngBounds(bounds, 50),
      //           );
      //           _goToNextState();
      //         },
      //         label: Text('Confirm Destination'),
      //       )
      //     : SizedBox.shrink(),