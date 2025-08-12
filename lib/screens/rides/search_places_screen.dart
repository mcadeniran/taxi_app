import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/models/predicted_places.dart';
import 'package:taxi_app/screens/widgets/prediction_places_tile.dart';
import 'package:taxi_app/utils/colors.dart';
import 'package:taxi_app/utils/request_assistant.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  List<PredictedPlaces> predictedPlacesList = [];

  Future<void> findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$apiKey&components=country:tr|country:cy|country:us|country:ng";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(
        urlAutoCompleteSearch,
      );

      if (responseAutoCompleteSearch == 'Error fetching data. No Response' ||
          responseAutoCompleteSearch == 'Error fetchin data.') {
        return;
      }

      if (responseAutoCompleteSearch["status"] == 'OK') {
        var placePredictions = responseAutoCompleteSearch['predictions'];

        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          predictedPlacesList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          titleTextStyle: TextStyle(
            color: Colors.white, // White color
            fontSize: 20, // Font size
            fontWeight: FontWeight.bold, // Bold text
          ),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Enter dropoff location',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkLayer : AppColors.lightLayer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp),
                        SizedBox(width: 18),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutoCompleteSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Dropoff Location',
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (predictedPlacesList.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                      separatorBuilder: (BuildContext ctx, int index) {
                        return Divider(
                          height: 0,
                          thickness: 0.2,
                          color: isDark
                              ? AppColors.darkLayer
                              : AppColors.lightLayer,
                        );
                      },
                      physics: ClampingScrollPhysics(),
                      itemCount: predictedPlacesList.length,
                      itemBuilder: (context, index) {
                        return PredictionPlacesTile(
                          predictedPlaces: predictedPlacesList[index],
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
