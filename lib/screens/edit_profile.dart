import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/profile_provider.dart';
import 'package:taxi_app/l10n/app_localizations.dart';
import 'package:taxi_app/models/profile.dart';
import 'package:taxi_app/screens/widgets/app_bar_widget.dart';
import 'package:taxi_app/screens/widgets/error_message.dart';
import 'package:taxi_app/screens/widgets/input_decorator.dart';
import 'package:taxi_app/screens/widgets/success_message_widget.dart';
import 'package:taxi_app/utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final profileEditKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  late String photoUrl;
  late Profile profile;
  String initialCountry = 'TR';
  PhoneNumber number = PhoneNumber();
  bool isLoading = false;
  PhoneNumber? parsedPhoneNumber;
  PhoneNumber? initialPhone;

  String localError = '';
  String localSuccess = '';

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
      localError = '';
      localSuccess = '';
    });

    try {
      final String formattedPhone =
          parsedPhoneNumber?.phoneNumber ?? phoneController.text;

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'isProfileCompleted': true,
            'personal.phone': formattedPhone,
            'personal.firstName': firstNameController.text,
            'personal.lastName': lastNameController.text,
          });
      setState(() {
        localSuccess = AppLocalizations.of(context)!.profileUpdateSuccess;
      });
    } catch (e) {
      setState(() {
        localError = '${AppLocalizations.of(context)!.profileUpdateFailure}$e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

    firstNameController.text = profile.personal.firstName;
    lastNameController.text = profile.personal.lastName;
    phoneController.text = profile.personal.phone;
    photoUrl = profile.personal.photoUrl;
    number = PhoneNumber(phoneNumber: profile.personal.phone);

    // final e164 = profile.personal.phone;
    initialPhone = PhoneNumber(
      isoCode: 'NG',
      phoneNumber: profile.personal.phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.editProfile.toUpperCase(),
      ),
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
                Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Material(
                          color: Colors.transparent,
                          child: photoUrl == ''
                              ? Ink.image(
                                  image: const AssetImage(
                                    'assets/images/avatar.png',
                                  ),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                  child: InkWell(
                                    // onTap: () => Get.to(
                                    //   () => const EditProfilePicture(),
                                    // ),
                                    onTap: () {},
                                  ),
                                )
                              : Ink.image(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                  child: InkWell(
                                    // onTap: () => Get.to(
                                    //   () => const EditProfilePicture(),
                                    // ),
                                    onTap: () {},
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: AppColors.primary,
                                child: InkWell(
                                  onTap: () {},

                                  // Get.to(() => const EditProfilePicture()
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: profileEditKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.firstName,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.firstNameRequiredError;
                          } else if (value != null && value.length < 2) {
                            return AppLocalizations.of(
                              context,
                            )!.firstNameLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: lastNameController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.surname,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.lastNameRequiredError;
                          } else if (value != null && value.length < 2) {
                            return AppLocalizations.of(
                              context,
                            )!.lastNameLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      initialPhone == null
                          ? const CircularProgressIndicator() // while parsing
                          : InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                parsedPhoneNumber =
                                    number; // ✅ save latest parsed phone number
                              },
                              onInputValidated: (bool isValid) {
                                print("Is valid: $isValid");
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.phoneNumberRequiredError;
                                }
                                if (value.length < 10) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.phoneNumberInvalidError;
                                }
                                return null;
                              },
                              selectorConfig: SelectorConfig(
                                selectorType:
                                    PhoneInputSelectorType.BOTTOM_SHEET,
                                useBottomSheetSafeArea: true,
                              ),
                              ignoreBlank: false,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              initialValue: initialPhone,
                              textFieldController: phoneController,
                              formatInput: true,
                              keyboardType: TextInputType.phone,
                              inputDecoration: inputDecoration(
                                context: context,
                                hint: AppLocalizations.of(context)!.phone,
                              ),
                              onSaved: (PhoneNumber number) {
                                parsedPhoneNumber = number;
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
                                if (profileEditKey.currentState!.validate()) {
                                  profileEditKey.currentState!
                                      .save(); // ensures phone is saved
                                  updateProfile();
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
                        child: Text(
                          AppLocalizations.of(context)!.updateProfile,
                        ),
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
