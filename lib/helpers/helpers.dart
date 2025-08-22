import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:taxi_app/models/direction_details_info.dart';

String userDropOffAddress = '';
String driverCarDetails = '';
String driverCarModel = '';
String driverCarColour = '';
String driverNumberPlate = '';
String driverName = '';
String driverPhone = '';
String driverPhotoUrl = '';

double countRatingStars = 0.0;
String titleStarsRating = '';

List driversList = [];

String cloudMessagingServerToken = '';

Position? driverCurrentPosition;

DirectionDetailsInfo? tripDirectionDetailsInfo;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

// AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
