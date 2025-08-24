import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// The Current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// Greeting for the landing page
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// Message asking users what they want
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get whatWouldYouLikeToDoToday;

  /// Menu Item to request a ride
  ///
  /// In en, this message translates to:
  /// **'Request Ride'**
  String get requestRide;

  /// Menu Item to view rides history
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// Menu Item to view profile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Menu Item to view settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Menu Item to test widgets
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// English translation in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishEnglish;

  /// Turkish translation in English
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get englishTurkish;

  /// Russian translation in English
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get englishRussian;

  /// Menu item to Change Password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Menu item to Delete Account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Menu item to Change Language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Menu item to Enable Dark Mode
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enableDarkMode;

  /// Menu item to Change Password
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Menu item to Contact Us
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Menu item to Terms & Conditions
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Menu item to Log Out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Menu item to App
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appTitle;

  /// Menu item to Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Menu item to Support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// Menu item to Vehicle Details
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// Promo code when available
  ///
  /// In en, this message translates to:
  /// **'Use promo code {promoCode} to get {percentage}% off your next ride!'**
  String usePromoCode(String promoCode, int percentage);

  /// Message to display when user has no ride history
  ///
  /// In en, this message translates to:
  /// **'Looks like you have no rides yet.'**
  String get noRideFound;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get rideAccepted;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get rideArrived;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get rideOnTrip;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rideEnded;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Status unknown'**
  String get rideUnknown;

  /// Message to prompt user to call the other party
  ///
  /// In en, this message translates to:
  /// **'Call {username}'**
  String callUsername(String username);

  /// Title showing ride details
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// Sub-menu title
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Username item title
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Email item title
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// First Name item title
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Surname item title
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// Phone item title
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Total Rides Taken item title
  ///
  /// In en, this message translates to:
  /// **'Total Rides Taken'**
  String get totalRidesTaken;

  /// Car Model item title
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get carModel;

  /// Colour item title
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// Registration Number item title
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// Total Rides Driven item title
  ///
  /// In en, this message translates to:
  /// **'Total Rides Driven'**
  String get totalRidesDriven;

  /// Edit Profile Page Title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Update Profile action button
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// First name required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequiredError;

  /// Surname required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your surname'**
  String get lastNameRequiredError;

  /// First name length error message
  ///
  /// In en, this message translates to:
  /// **'Your first name needs at least 2 letters'**
  String get firstNameLengthError;

  /// Surname length error message
  ///
  /// In en, this message translates to:
  /// **'Your surname needs at least 2 letters'**
  String get lastNameLengthError;

  /// Phone number required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneNumberRequiredError;

  /// Invalid phone number error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneNumberInvalidError;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Your profile has been updated successfully'**
  String get profileUpdateSuccess;

  /// Profile update failure message
  ///
  /// In en, this message translates to:
  /// **'There was an error updating your profile: '**
  String get profileUpdateFailure;

  /// Shows the pickup location
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// Shows the dropoff location
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Shows the dropoff location
  ///
  /// In en, this message translates to:
  /// **'Enter Destination'**
  String get enterDestination;

  /// Change pickup location action button label
  ///
  /// In en, this message translates to:
  /// **'Change Pickup'**
  String get changePickup;

  /// Request a ride action button label
  ///
  /// In en, this message translates to:
  /// **'Request a Ride'**
  String get requestARide;

  /// Set current location action button label
  ///
  /// In en, this message translates to:
  /// **'Set Current Location'**
  String get setCurrentLocation;

  /// Cancel request ride action button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Loading screen message
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Loading screen message
  ///
  /// In en, this message translates to:
  /// **'Searching for driver...'**
  String get searchingForDriver;

  /// Action prompt for rider to call assigned driver
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// Prompt rider to enter destination
  ///
  /// In en, this message translates to:
  /// **'Please enter destination'**
  String get pleaseEnterDestination;

  /// Prompt rider to enter pickup address
  ///
  /// In en, this message translates to:
  /// **'Please enter pickup address'**
  String get pleaseEnterPickupAddress;

  /// Display address error
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get unknownAddress;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Driver is coming'**
  String get driverIsComing;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrived;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Going towards destination'**
  String get goingTowardsDestination;

  /// Prompt user of driver availability in the area
  ///
  /// In en, this message translates to:
  /// **'No available driver nearby'**
  String get noAvailableDriverNearby;

  /// Prompts the user to go to main screen
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Prompts the user to remain on current screen
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Prompts the user to about the end of the ride
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get rideCompleted;

  /// Prompts the user about the final status of the ride
  ///
  /// In en, this message translates to:
  /// **'Your ride has ended successfully.\n\nDo you want to return to the home screen?'**
  String get yourRideHasEnded;

  /// Error message if calling driver fails
  ///
  /// In en, this message translates to:
  /// **'Could not call driver'**
  String get couldNotCallDriver;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
