import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/models/ride_history.dart';
import 'package:taxi_app/screens/rides/directions_service.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/utils/colors.dart';

class RideDetailsScreen extends StatefulWidget {
  final String title;
  final bool isRider;
  final RideHistory history;
  const RideDetailsScreen({
    super.key,
    required this.title,
    required this.isRider,
    required this.history,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

final apiKey = dotenv.env['GOOGLE_API_KEY'];

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final DirectionsService _directionsService = DirectionsService(apiKey!);

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _loadRoute();
  }

  void _setMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId("pickup"),
        position: LatLng(
          widget.history.origin.latitude,
          widget.history.origin.longitude,
        ),
        // position: widget.pickupLatLng,
        infoWindow: InfoWindow(
          title: "Pickup",
          snippet: widget.history.originAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId("dropOff"),
        position: LatLng(
          widget.history.destination.latitude,
          widget.history.destination.longitude,
        ),
        // position: widget.dropOffLatLng,
        infoWindow: InfoWindow(
          title: "Drop Off",
          snippet: widget.history.destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Future<void> _loadRoute() async {
    try {
      final route = await _directionsService.getRoute(
        LatLng(widget.history.origin.latitude, widget.history.origin.longitude),
        LatLng(
          widget.history.destination.latitude,
          widget.history.destination.longitude,
        ),
      );

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.black,
            width: 5,
            points: route,
          ),
        };
      });

      // Fit map to markers and route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([
            LatLng(
              widget.history.origin.latitude,
              widget.history.origin.longitude,
            ),
            LatLng(
              widget.history.destination.latitude,
              widget.history.destination.longitude,
            ),
          ]),
          100,
        ),
      );
    } catch (e) {
      debugPrint("Error loading route: $e");
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list[0].latitude, x1 = list[0].latitude;
    double y0 = list[0].longitude, y1 = list[0].longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: widget.title),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 1,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.history.origin.latitude,
                  widget.history.origin.longitude,
                ),
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),

          // Ride info
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Iconify(
                        Ic.outline_trip_origin,
                        color: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.history.originAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Iconify(
                        Ic.baseline_nature_people,
                        color: AppColors.tertiary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.history.destinationAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Divider(thickness: 0.5, color: AppColors.border),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Iconify(
                        widget.isRider
                            ? Healthicons.truck_driver_outline
                            : Mdi.seat_passenger,
                        color: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                      ),
                      SizedBox(width: 14),
                      Text(
                        widget.isRider
                            ? widget.history.driverName
                            : widget.history.username,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Iconify(
                        Platform.isIOS
                            ? Ic.round_phone_iphone
                            : Ic.round_phone_android,
                        color: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                      ),
                      SizedBox(width: 14),
                      Text(
                        widget.isRider
                            ? widget.history.driverPhone
                            : widget.history.userPhone,
                      ),
                    ],
                  ),

                  if (widget.isRider) ...[
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Iconify(
                          Ic.twotone_local_taxi,
                          color: isDark
                              ? AppColors.lightLayer
                              : AppColors.primary,
                        ),
                        SizedBox(width: 14),
                        Text(
                          '${widget.history.colour} ${widget.history.model}',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Iconify(
                          Fa.drivers_license_o,
                          color: isDark
                              ? AppColors.lightLayer
                              : AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(widget.history.numberPlate),
                      ],
                    ),
                  ],
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF00009A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? AppColors.lightLayer
                          : AppColors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white54,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.call),
                    label: Text(
                      widget.isRider
                          ? 'CALL ${widget.history.driverName}'
                          : 'CALL ${widget.history.username}',
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
