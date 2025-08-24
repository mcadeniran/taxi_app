// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Русский';

  @override
  String get hi => 'Привет';

  @override
  String get whatWouldYouLikeToDoToday => 'Что хочешь сделать сегодня?';

  @override
  String get requestRide => 'Заказать поездку';

  @override
  String get rideHistory => 'История поездок';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get test => 'Тест';

  @override
  String get englishEnglish => 'Английский';

  @override
  String get englishTurkish => 'турецкий';

  @override
  String get englishRussian => 'Русский';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get enableDarkMode => 'Включить тёмный режим';

  @override
  String get enableNotifications => 'Включить уведомления';

  @override
  String get contactUs => 'Свяжитесь с нами';

  @override
  String get termsAndConditions => 'Условия и положения';

  @override
  String get logOut => 'Выйти';

  @override
  String get appTitle => 'Приложение';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get vehicleDetails => 'Данные автомобиля';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return 'Используй промокод $promoCode, чтобы получить скидку $percentage% на следующую поездку!';
  }

  @override
  String get noRideFound => 'Похоже, у тебя пока нет поездок.';

  @override
  String get rideAccepted => 'Принято';

  @override
  String get rideArrived => 'Водитель приехал';

  @override
  String get rideOnTrip => 'В пути';

  @override
  String get rideEnded => 'Поездка окончена';

  @override
  String get rideUnknown => 'Статус неизвестен';

  @override
  String callUsername(String username) {
    return 'Позвонить $username';
  }

  @override
  String get rideDetails => 'Детали поездки';

  @override
  String get personalDetails => 'Личные данные';

  @override
  String get username => 'Имя пользователя';

  @override
  String get email => 'Электронная почта';

  @override
  String get firstName => 'Имя';

  @override
  String get surname => 'Фамилия';

  @override
  String get phone => 'Телефон';

  @override
  String get totalRidesTaken => 'Всего поездок';

  @override
  String get carModel => 'Модель автомобиля';

  @override
  String get colour => 'Цвет';

  @override
  String get registrationNumber => 'Номер автомобиля';

  @override
  String get totalRidesDriven => 'Всего поездок';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get updateProfile => 'Обновить профиль';

  @override
  String get firstNameRequiredError => 'Пожалуйста, введите имя';

  @override
  String get lastNameRequiredError => 'Пожалуйста, введите фамилию';

  @override
  String get firstNameLengthError =>
      'Ваше имя должно содержать как минимум 2 буквы';

  @override
  String get lastNameLengthError =>
      'Ваша фамилия должна содержать как минимум 2 буквы';

  @override
  String get phoneNumberRequiredError => 'Пожалуйста, введите номер телефона';

  @override
  String get phoneNumberInvalidError =>
      'Пожалуйста, введите правильный номер телефона';

  @override
  String get profileUpdateSuccess => 'Ваш профиль успешно обновлён';

  @override
  String get profileUpdateFailure =>
      'Произошла ошибка при обновлении профиля: ';

  @override
  String get from => 'Откуда';

  @override
  String get to => 'Куда';

  @override
  String get enterDestination => 'Введите пункт назначения';

  @override
  String get changePickup => 'Изменить пикап';

  @override
  String get requestARide => 'Заказать поездку';

  @override
  String get setCurrentLocation => 'Установить текущее местоположение';

  @override
  String get cancel => 'Отменить';

  @override
  String get pleaseWait => 'Пожалуйста, подождите...';

  @override
  String get searchingForDriver => 'Идёт поиск водителя...';

  @override
  String get callDriver => 'Позвонить водителю';

  @override
  String get pleaseEnterDestination => 'Пожалуйста, введите пункт назначения';

  @override
  String get pleaseEnterPickupAddress => 'Пожалуйста, введите адрес посадки';

  @override
  String get unknownAddress => 'Неизвестный адрес';

  @override
  String get driverIsComing => 'Водитель едет';

  @override
  String get driverHasArrived => 'Водитель приехал';

  @override
  String get goingTowardsDestination => 'Движение к пункту назначения';

  @override
  String get noAvailableDriverNearby => 'Поблизости нет доступных водителей';

  @override
  String get goHome => 'На главный экран';

  @override
  String get stay => 'Остаться';

  @override
  String get rideCompleted => 'Поездка завершена';

  @override
  String get yourRideHasEnded =>
      'Ваша поездка успешно завершена.\n\nХотите вернуться на главный экран?';

  @override
  String get couldNotCallDriver => 'Не удалось позвонить водителю';
}
