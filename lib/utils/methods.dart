import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/models/direction.dart';
import 'package:taxi_app/models/direction_details_info.dart';
import 'package:taxi_app/utils/request_assistant.dart';

class AppMethods {
  static Future<String> searchAddressFromGeographicalCoordinates(
    Position position,
    context,
  ) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress = '';

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != 'Error fetching data. No Response' &&
        requestResponse != 'Error fetchin data.') {
      humanReadableAddress = requestResponse['results'][0]['formatted_address'];

      Direction userPickupAddress = Direction();

      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?>
  obtainOriginToDestinationDirectionDetails(
    LatLng originPosition,
    LatLng destinationPosition,
  ) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    String originToDestinationDetailsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$apiKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
      originToDestinationDetailsUrl,
    );

    if (responseDirectionApi == 'Error fetching data. No Response' ||
        responseDirectionApi == 'Error fetchin data.') {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.ePoints =
        responseDirectionApi['routes'][0]['overview_polyline']['points'];

    directionDetailsInfo.distanceText =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['text'];
    directionDetailsInfo.distanceValue =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['value'];

    directionDetailsInfo.durationText =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['text'];
    directionDetailsInfo.durationValue =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['value'];

    return directionDetailsInfo;
  }
}
