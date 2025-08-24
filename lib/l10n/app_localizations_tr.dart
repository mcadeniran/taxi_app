// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get language => 'Türkçe';

  @override
  String get hi => 'Merhaba';

  @override
  String get whatWouldYouLikeToDoToday => 'Bugün ne yapmak istersin?';

  @override
  String get requestRide => 'Yolculuk İste';

  @override
  String get rideHistory => 'Yolculuk Geçmişi';

  @override
  String get myProfile => 'Profilim';

  @override
  String get settings => 'Ayarlar';

  @override
  String get test => 'Test';

  @override
  String get englishEnglish => 'İngilizce';

  @override
  String get englishTurkish => 'Türkçe';

  @override
  String get englishRussian => 'Rusça';

  @override
  String get changePassword => 'Şifreyi Değiştir';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get changeLanguage => 'Dili Değiştir';

  @override
  String get enableDarkMode => 'Karanlık Modu Aç';

  @override
  String get enableNotifications => 'Bildirimleri Aç';

  @override
  String get contactUs => 'Bize Ulaş';

  @override
  String get termsAndConditions => 'Şartlar ve Koşullar';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get appTitle => 'Uygulama';

  @override
  String get accountTitle => 'Hesap';

  @override
  String get supportTitle => 'Destek';

  @override
  String get vehicleDetails => 'Araç Bilgileri';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return '$promoCode promosyon kodunu kullan, sonraki yolculuğunda %$percentage indirim kazan!';
  }

  @override
  String get noRideFound => 'Henüz yolculuğun yok gibi görünüyor.';

  @override
  String get rideAccepted => 'Kabul Edildi';

  @override
  String get rideArrived => 'Şoför geldi';

  @override
  String get rideOnTrip => 'Yolda';

  @override
  String get rideEnded => 'Bitti';

  @override
  String get rideUnknown => 'Durum bilinmiyor';

  @override
  String callUsername(String username) {
    return '$username\'ı Ara';
  }

  @override
  String get rideDetails => 'Yolculuk Detayları';

  @override
  String get personalDetails => 'Kişisel Bilgiler';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get email => 'E-posta';

  @override
  String get firstName => 'Ad';

  @override
  String get surname => 'Soyad';

  @override
  String get phone => 'Telefon';

  @override
  String get totalRidesTaken => 'Toplam Yolculuk';

  @override
  String get carModel => 'Araç Modeli';

  @override
  String get colour => 'Renk';

  @override
  String get registrationNumber => 'Plaka Numarası';

  @override
  String get totalRidesDriven => 'Toplam Sürüş';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get updateProfile => 'Profili Güncelle';

  @override
  String get firstNameRequiredError => 'Lütfen adınızı girin';

  @override
  String get lastNameRequiredError => 'Lütfen soyadınızı girin';

  @override
  String get firstNameLengthError => 'Adınız en az 2 harf olmalı';

  @override
  String get lastNameLengthError => 'Soyadınız en az 2 harf olmalı';

  @override
  String get phoneNumberRequiredError => 'Lütfen telefon numaranızı girin';

  @override
  String get phoneNumberInvalidError =>
      'Lütfen geçerli bir telefon numarası girin';

  @override
  String get profileUpdateSuccess => 'Profiliniz başarıyla güncellendi';

  @override
  String get profileUpdateFailure =>
      'Profilinizi güncellerken bir hata oluştu: ';

  @override
  String get from => 'Nereden';

  @override
  String get to => 'Nereye';

  @override
  String get enterDestination => 'Varış noktasını girin';

  @override
  String get changePickup => 'Alış noktasını değiştir';

  @override
  String get requestARide => 'Yolculuk iste';

  @override
  String get setCurrentLocation => 'Mevcut konumu ayarla';

  @override
  String get cancel => 'İptal';

  @override
  String get pleaseWait => 'Lütfen bekleyin...';

  @override
  String get searchingForDriver => 'Sürücü aranıyor...';

  @override
  String get callDriver => 'Şoförü ara';

  @override
  String get pleaseEnterDestination => 'Lütfen varış noktasını girin';

  @override
  String get pleaseEnterPickupAddress => 'Lütfen alma adresini girin';

  @override
  String get unknownAddress => 'Bilinmeyen adres';

  @override
  String get driverIsComing => 'Şoför geliyor';

  @override
  String get driverHasArrived => 'Şoför geldi';

  @override
  String get goingTowardsDestination => 'Varış noktasına gidiliyor';

  @override
  String get noAvailableDriverNearby => 'Yakında uygun sürücü yok';

  @override
  String get goHome => 'Ana ekrana dön';

  @override
  String get stay => 'Kal';

  @override
  String get rideCompleted => 'Yolculuk tamamlandı';

  @override
  String get yourRideHasEnded =>
      'Yolculuğunuz başarıyla tamamlandı.\n\nAna ekrana dönmek ister misiniz?';

  @override
  String get couldNotCallDriver => 'Şoför aranamadı';
}
