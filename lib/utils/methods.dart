import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/helpers/helpers.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/models/direction.dart';
import 'package:taxi_app/models/direction_details_info.dart';
import 'package:taxi_app/utils/request_assistant.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

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

  static void pauseLiveLocationUpdates({required String userId}) {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(userId);
  }

  static void sendNotificationToDriverNow(
    String deviceRegistrationToken,
    String userRideRequestId,
    context,
  ) async {
    String destinationAddress = userDropOffAddress;

    String serverAccessTokenKey = await getAccessToken();

    String endPointFirebasecloudMessaging =
        'https://fcm.googleapis.com/v1/projects/kipgo-taxi/messages:send';

    // Map<String, String> headerNotification = {
    //   'Content-Type': 'Application/json',
    //   'Authorization': 'Bearer $serverAccessTokenKey',
    // };

    // Map bodyNotification = {
    //   "body": "Destination Address: \n$destinationAddress",
    //   "title": "New Trip Request",
    // };

    // Map dataMap = {
    //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //   "id": "1",
    //   "status": "done",
    //   "rideRequestId": userRideRequestId,
    // };

    // Map officialNotificationFormat = {
    //   "notification": bodyNotification,
    //   "data": dataMap,
    //   "priority": 'high',
    //   "to": deviceRegistrationToken,
    // };

    // var responseNotification = await http.post(
    //   Uri.parse(endPointFirebasecloudMessaging),
    //   headers: headerNotification,
    //   body: jsonEncode(officialNotificationFormat),
    // );

    // print("Notification Response: ${responseNotification.body}");

    String username = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.username;
    String pickupAddress = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation!.locationName!;
    final Map<String, dynamic> message = {
      'message': {
        'token': deviceRegistrationToken,
        'notification': {
          'title': "NEW TRIP REQUEST FROM $username",
          'body':
              "Pickup Location: $pickupAddress \nDropoff Location: $userDropOffAddress",
        },
        'data': {"rideRequestId": userRideRequestId},
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endPointFirebasecloudMessaging),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send FCM Message: ${response.statusCode}');
      print("FAILED DETAILS: ${response.body}");
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "kipgo-taxi",
      "private_key_id": "9d7efa8fd305424386c70d112f105a9d08ff19cf",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCIGJUDslxSgxJg\nb8hXhz9nRPm/ysESiz6Mz9nGSsLQFOxRfkLexPTFIthSKzBYxeO8ciCrOmrzKOh9\nrzT8EU82Tlv9uQAI6NuOELnGWnsD4SajUWAjVGQQdR6o9kTKB+BS07S1gDBoxoic\nsdsnfrr3hGRpvk+zm+ys6ye1PNteXdP3l2HMw62qWOKKoZDhOuEKolitJEvy9KBf\nSrCWcga9bKSvdHSEmj7AaNukcIKsMG05SC2hA3AkOYLFO4+kqR0JOKWDXJv8/KX7\nNKapHMJsKjVadd1V7tyqOtDjFYu7TWmT+EUIuycbiGoR1xE8kRxe1jg4OwmYIO7u\nhJqO/uILAgMBAAECggEAKOHxiZ2/vA2hrJSHwzteoYAH4kRfAVoQ3S3nBnkY0ncm\nkkhygAb8XGfeQbi1mkU/5zEFfUpcLFVimbbTHNF6UR7y5WH4j7Sbl66Qj/RINd8h\nwzfDwHkuYf88yZbJDUOWcGsmQsuSPzc8fI20/sVEFuyPWXCQ8qxpSXyOfhQc9dib\njYIoaVCnwnKqCNcEX0K31WvtDw4jXfa7h9UBh6bUZ/K7Y0U5e9huJPF491mwM0AP\na+U04We0Ajbb4BtQcNhbH+yYuvYNrb3UC41GLKo4OdtbizmQYx5H0I6nW4jc83sL\n844W4HjoPFTDW0Vct95f2fm9DuU+lsw553LynjrjkQKBgQDAXfvqx31yxtaTBTe8\n+qHcX/lf8Zs6XZMuYPqgO4CRZM3r3UVpi3xAXv2NcH7m1NPT5BAG+ibW4bmjybm/\n7dqHr8AB0ZXwjB5IUSqkAzkwG6FZILIRX+E+7OLY8+zH25pEopsG0SJhYbR02BoF\nMhZd5SdUFuYdP8eSdRGNaN5SowKBgQC1HXQeC2KW9xY4HwyTrD/0vEvBmRLV2BZb\nS4HwzNlmsbE1ZQLpg6GxfGgK83oWHS/pAYVHFmyYFyxtJnSHFmKnmk9y5eWcFh+i\nHBa0kBBeuotqrzld0AWyqhRP9yqhnj17pHKuIYuuf5/RYy8tzttxFkAtyWyR/wfH\n9zH7H68ReQKBgGHery+I5UNC9KKCMhR8s2MKlTaCFsbAGwSqpHhnLYdLcRUCU7Fa\nHRInAfs28+l++HLCgoD6Pk5vM2KoXE/QtLD58sc6GX3z2+hRG0+ssCjQtetBnjcG\nv/Oi09srZxlbmgY3cIYsWsCO1B/qXnqsPALzdmnq6JKTA3d5BkAazZnfAoGAAQI5\n/FTZ5rdXk1Zw7n2eGZHW5iwhE7nRXg7MmXe6mjzRHNgELSLDisaDmdQDUQ42jxio\nEl5Imow+fhkhuwLf58kPOjeXkMf6wx9e7QCEZtKpJh31ttUKwxT5afyZay8DbqXa\n0ad0LLOfQz5HK/0j8bxK/TZK+YEvHOj+iUSC6BkCgYBlD9tPfGB66IzPedu+FGyI\nRNVRnCXJR0lg4VGyZADEn0E2bpf6E3mBKOD06wS10e99alj2emypqguhGu87AGPT\n/iH1AAm2jcbMczbk2lnfiFvx00ozk7KMMcPqnIbV7DjiILxSq3WNirmJt9d7BPMm\nd8MH2EQT7a+Fym7nVNXu2Q==\n-----END PRIVATE KEY-----\n",
      "client_email": "kipgo-taxi@kipgo-taxi.iam.gserviceaccount.com",
      "client_id": "107177335304477395485",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/kipgo-taxi%40kipgo-taxi.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // get the access token
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client,
        );

    client.close();

    return credentials.accessToken.data;
  }
}
