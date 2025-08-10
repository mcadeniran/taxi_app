import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';

class SearchLocationWidget extends StatelessWidget {
  // final double lat;
  // final double lng;
  const SearchLocationWidget({
    super.key,
    // required this.lat, required this.lng
  });

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    TextEditingController controller = TextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: GooglePlaceAutoCompleteTextField(
        containerVerticalPadding: 0,
        textEditingController: controller,
        googleAPIKey: apiKey!,
        inputDecoration: inputDecoration(
          context: context,
          prefixIcon: Ic.twotone_my_location,
        ).copyWith(filled: true),
        debounceTime: 800, // default 600 ms,
        countries: ["NG", "CY", "TR", "US"], // optional by default null is set
        isLatLngRequired: true, // if you required coordinates from place detail
        getPlaceDetailWithLatLng: (Prediction prediction) {
          // this method will return latlng with place detail
          print("placeDetails" + prediction.lng.toString());
          print("Address: " + prediction.description!);
        }, // this callback is called when isLatLngRequired is true
        itemClick: (Prediction prediction) {
          controller.text = prediction.description!;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description!.length),
          );
        },
        // if we want to make custom list item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
                Expanded(child: Text("${prediction.description ?? ""}")),
              ],
            ),
          );
        },
        // if you want to add seperator between list items
        seperatedBuilder: Divider(),
        // latitude: lat,
        // longitude: lng,
        // radius: 1,
        // want to show close icon
        isCrossBtnShown: true,
        // optional container padding
        containerHorizontalPadding: 0,
        // place type
        placeType: PlaceType.geocode,
      ),
    );
  }
}
