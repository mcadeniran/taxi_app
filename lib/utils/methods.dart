import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/models/direction.dart';
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

      // Provider.of<AppInfo>(
      //   context,
      //   listen: false,
      // ).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }
}
