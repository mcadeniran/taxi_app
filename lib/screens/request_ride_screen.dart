import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;

  final List<Map<String, dynamic>> _nearbyDrivers = [
    {
      "name": "Driver 1",
      "lat": 37.7667,
      "lon": -122.4155,
      "distance": "0.97 km",
      "eta": "10 min"
    },
    {
      "name": "Driver 2",
      "lat": 37.7750,
      "lon": -122.4204,
      "distance": "0.09 km",
      "eta": "1 min"
    },
    {
      "name": "Driver 3",
      "lat": 37.7771,
      "lon": -122.4152,
      "distance": "0.44 km",
      "eta": "4 min"
    },
    {
      "name": "Driver 4",
      "lat": 37.7842,
      "lon": -122.4246,
      "distance": "1.14 km",
      "eta": "11 min"
    },
    {
      "name": "Driver 5",
      "lat": 37.7799,
      "lon": -122.4180,
      "distance": "0.58 km",
      "eta": "6 min"
    },
  ];

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) return;

    final locData = await location.getLocation();
    _userLocation = LatLng(locData.latitude!, locData.longitude!);

    // Set user marker
    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: "You"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add driver markers
    for (var driver in _nearbyDrivers) {
      _markers.add(
        Marker(
          markerId: MarkerId(driver["name"]),
          position: LatLng(driver["lat"], driver["lon"]),
          infoWindow: InfoWindow(title: driver["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {});

    // Animate to user location
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation!, 14),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _selectDriver(Map<String, dynamic> driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request sent to ${driver['name']}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔹 TOP HALF: Google Map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 13,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
          ),

          // 🔹 BOTTOM HALF: Drivers List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nearby Drivers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00009A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _nearbyDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = _nearbyDrivers[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person,
                                color: Color(0xFF00009A)),
                            title: Text(driver["name"]),
                            subtitle: Text(
                              "Distance: ${driver['distance']} • ETA: ${driver['eta']}",
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _selectDriver(driver),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00009A),
                              ),
                              child: const Text("Request"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
