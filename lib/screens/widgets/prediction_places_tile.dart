import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/helpers/helpers.dart';
import 'package:taxi_app/infoHandler/app_info.dart';
import 'package:taxi_app/models/direction.dart';
import 'package:taxi_app/models/predicted_places.dart';
import 'package:taxi_app/screens/widgets/progress_dialog.dart';
import 'package:taxi_app/utils/request_assistant.dart';

class PredictionPlacesTile extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;
  const PredictionPlacesTile({super.key, this.predictedPlaces});

  @override
  State<PredictionPlacesTile> createState() => _PredictionPlacesTileState();
}

class _PredictionPlacesTileState extends State<PredictionPlacesTile> {
  final apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<void> getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: 'Setting up location. Please wait...'),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    var responseApi = await RequestAssistant.receiveRequest(
      placeDirectionDetailsUrl,
    );

    Navigator.pop(context);

    if (responseApi == 'Error fetching data. No Response' ||
        responseApi == 'Error fetchin data.') {
      return;
    }

    if (responseApi["status"] == 'OK') {
      Direction directions = Direction();
      directions.locationName = responseApi['result']['name'];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi['result']['geometry']['location']['lat'];
      directions.locationLongitude =
          responseApi['result']['geometry']['location']['lng'];

      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, 'obtainedDropOff');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.placeId, context);
      },
      style: TextButton.styleFrom(
        // backgroundColor: isDark ? Colors.black : Colors.white,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            0.0,
          ), // Adjust the radius as needed
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(Icons.add_location),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces!.mainText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.predictedPlaces!.secondaryText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
