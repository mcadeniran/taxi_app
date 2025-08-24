// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get hi => 'Hi';

  @override
  String get whatWouldYouLikeToDoToday => 'What would you like to do today?';

  @override
  String get requestRide => 'Request Ride';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get settings => 'Settings';

  @override
  String get test => 'Test';

  @override
  String get englishEnglish => 'English';

  @override
  String get englishTurkish => 'Turkish';

  @override
  String get englishRussian => 'Russian';

  @override
  String get changePassword => 'Change Password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get enableDarkMode => 'Enable Dark Mode';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get logOut => 'Log Out';

  @override
  String get appTitle => 'App';

  @override
  String get accountTitle => 'Account';

  @override
  String get supportTitle => 'Support';

  @override
  String get vehicleDetails => 'Vehicle Details';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return 'Use promo code $promoCode to get $percentage% off your next ride!';
  }

  @override
  String get noRideFound => 'Looks like you have no rides yet.';

  @override
  String get rideAccepted => 'Accepted';

  @override
  String get rideArrived => 'Driver has arrived';

  @override
  String get rideOnTrip => 'In Transit';

  @override
  String get rideEnded => 'Completed';

  @override
  String get rideUnknown => 'Status unknown';

  @override
  String callUsername(String username) {
    return 'Call $username';
  }

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get firstName => 'First Name';

  @override
  String get surname => 'Surname';

  @override
  String get phone => 'Phone';

  @override
  String get totalRidesTaken => 'Total Rides Taken';

  @override
  String get carModel => 'Car Model';

  @override
  String get colour => 'Colour';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get totalRidesDriven => 'Total Rides Driven';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get firstNameRequiredError => 'Please enter your first name';

  @override
  String get lastNameRequiredError => 'Please enter your surname';

  @override
  String get firstNameLengthError => 'Your first name needs at least 2 letters';

  @override
  String get lastNameLengthError => 'Your surname needs at least 2 letters';

  @override
  String get phoneNumberRequiredError => 'Please enter your phone number';

  @override
  String get phoneNumberInvalidError => 'Please enter a valid phone number';

  @override
  String get profileUpdateSuccess =>
      'Your profile has been updated successfully';

  @override
  String get profileUpdateFailure =>
      'There was an error updating your profile: ';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get enterDestination => 'Enter Destination';

  @override
  String get changePickup => 'Change Pickup';

  @override
  String get requestARide => 'Request a Ride';

  @override
  String get setCurrentLocation => 'Set Current Location';

  @override
  String get cancel => 'Cancel';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get searchingForDriver => 'Searching for driver...';

  @override
  String get callDriver => 'Call Driver';

  @override
  String get pleaseEnterDestination => 'Please enter destination';

  @override
  String get pleaseEnterPickupAddress => 'Please enter pickup address';

  @override
  String get unknownAddress => 'Unknown Address';

  @override
  String get driverIsComing => 'Driver is coming';

  @override
  String get driverHasArrived => 'Driver has arrived';

  @override
  String get goingTowardsDestination => 'Going towards destination';

  @override
  String get noAvailableDriverNearby => 'No available driver nearby';

  @override
  String get goHome => 'Go Home';

  @override
  String get stay => 'Stay';

  @override
  String get rideCompleted => 'Ride Completed';

  @override
  String get yourRideHasEnded =>
      'Your ride has ended successfully.\n\nDo you want to return to the home screen?';

  @override
  String get couldNotCallDriver => 'Could not call driver';
}
