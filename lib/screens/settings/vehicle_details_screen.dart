import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/models/profile.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/screens/widgets/error_message.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';
import 'package:taxi_app/screens/widgets/success_message_widget.dart';
import 'package:taxi_app/utils/colors.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final vehicleEditKey = GlobalKey<FormState>();
  TextEditingController colourController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController numberPlateController = TextEditingController();

  late Profile profile;
  bool documentSubmitted = false;

  String localError = '';
  String localSuccess = '';

  bool isLoading = false;

  Future<void> updateVehicleDetails() async {
    setState(() {
      isLoading = true;
      localError = '';
      localSuccess = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'vehicle.colour': colourController.text,
            'vehicle.licence': licenseController.text,
            'vehicle.model': modelController.text,
            'vehicle.numberPlate': numberPlateController.text,
            'account.isApproved': false,
          });
      setState(() {
        localSuccess = 'Vehicle details updated successfully';
        documentSubmitted = true;
      });
    } catch (e) {
      setState(() {
        localError = 'Error updating vehicle details: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

    colourController.text = profile.vehicle.colour;
    modelController.text = profile.vehicle.model;
    licenseController.text = profile.vehicle.licence;
    numberPlateController.text = profile.vehicle.numberPlate;

    if (profile.vehicle.colour == '' ||
        profile.vehicle.model == '' ||
        profile.vehicle.licence == '' ||
        profile.vehicle.numberPlate == '') {
      documentSubmitted = false;
    } else {
      documentSubmitted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: 'VEHICLE DETAILS'),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Documents Status: ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      documentSubmitted == false
                          ? 'Not Submitted'
                          : profile.account.isApproved == true
                          ? 'Approved'
                          : 'Pending',
                      style: TextStyle(
                        color: profile.account.isApproved
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Form(
                  key: vehicleEditKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: modelController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: 'Car Model (e.g. Mercedes C180)',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Car model is required';
                          } else if (value != null && value.length < 6) {
                            return 'Car model cannot be less than 6 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: colourController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: 'Colour',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Car colour is required';
                          } else if (value != null && value.length < 3) {
                            return 'Colour cannot be less than 3 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: licenseController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: 'Licence Number',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Licence number is required';
                          } else if (value != null && value.length < 5) {
                            return 'Licence number cannot be less than 5 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: numberPlateController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: 'Car Registration Number (e.g AB 123)',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Licence number is required';
                          } else if (value != null && value.length < 5) {
                            return 'Registration number cannot be less than 5 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      if (localError != '') ...[
                        SizedBox(height: 16),
                        ErrorMessageWidget(localErrorMessage: localError),
                      ],
                      if (localSuccess != '') ...[
                        SizedBox(height: 16),
                        SuccessMessageWidget(successMessage: localSuccess),
                      ],
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (vehicleEditKey.currentState!.validate()) {
                                  vehicleEditKey.currentState!
                                      .save(); // ensures phone is saved
                                  updateVehicleDetails();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00009A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor: Colors.white54,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Submit Vehicle Details'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '*Your status will stay pending until your vehicle documents are verified.',
                      ),
                      SizedBox(height: 10),
                      Text(
                        '*If you update any documents, your status will return to pending until re-verified.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
