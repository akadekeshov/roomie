import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Roomie'**
  String get appName;

  /// No description provided for @appBrand.
  ///
  /// In ru, this message translates to:
  /// **'Roomie'**
  String get appBrand;

  /// No description provided for @languageKazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get languageKazakh;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageApp.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageApp;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @userFallback.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get userFallback;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get notSpecified;

  /// No description provided for @errorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте еще раз.'**
  String get errorGeneric;

  /// No description provided for @errorServer.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера. Попробуйте позже.'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к серверу. Проверьте интернет.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный логин или пароль.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountNotVerified.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт не подтвержден. Завершите проверку кода.'**
  String get errorAccountNotVerified;

  /// No description provided for @errorEmailExists.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован.'**
  String get errorEmailExists;

  /// No description provided for @errorPhoneExists.
  ///
  /// In ru, this message translates to:
  /// **'Этот номер уже зарегистрирован.'**
  String get errorPhoneExists;

  /// No description provided for @errorSessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла. Войдите снова.'**
  String get errorSessionExpired;

  /// No description provided for @errorValidation.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте корректность введенных данных.'**
  String get errorValidation;

  /// No description provided for @errorNoAccess.
  ///
  /// In ru, this message translates to:
  /// **'У вас нет доступа к этому действию.'**
  String get errorNoAccess;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Подождите немного и попробуйте снова.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorUserNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не найден. Сначала зарегистрируйтесь.'**
  String get errorUserNotFound;

  /// No description provided for @errorAuthLoginFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти. Попробуйте позже.'**
  String get errorAuthLoginFailed;

  /// No description provided for @errorAuthRegisterFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось зарегистрироваться. Попробуйте позже.'**
  String get errorAuthRegisterFailed;

  /// No description provided for @errorOtpConfirmFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подтвердить код. Попробуйте снова.'**
  String get errorOtpConfirmFailed;

  /// No description provided for @errorOtpResendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить код. Попробуйте позже.'**
  String get errorOtpResendFailed;

  /// No description provided for @errorProfileLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить профиль. Попробуйте позже.'**
  String get errorProfileLoadFailed;

  /// No description provided for @errorSaveStepFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить шаг.'**
  String get errorSaveStepFailed;

  /// No description provided for @errorSaveGenderFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить пол.'**
  String get errorSaveGenderFailed;

  /// No description provided for @errorSaveCityFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить город.'**
  String get errorSaveCityFailed;

  /// No description provided for @errorInvalidBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную дату рождения.'**
  String get errorInvalidBirthDate;

  /// No description provided for @errorFillAllFields.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, заполните все поля.'**
  String get errorFillAllFields;

  /// No description provided for @socialGoogleCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Вход через Google был отменен.'**
  String get socialGoogleCancelled;

  /// No description provided for @socialGoogleConfigError.
  ///
  /// In ru, this message translates to:
  /// **'Google Sign-In не настроен. Проверьте конфигурацию и повторите попытку.'**
  String get socialGoogleConfigError;

  /// No description provided for @socialGoogleTokenMissing.
  ///
  /// In ru, this message translates to:
  /// **'Google не вернул токены. Повторите попытку позже.'**
  String get socialGoogleTokenMissing;

  /// No description provided for @socialFacebookCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Вход через Facebook был отменен.'**
  String get socialFacebookCancelled;

  /// No description provided for @socialFacebookConfigError.
  ///
  /// In ru, this message translates to:
  /// **'Facebook Login не настроен. Проверьте конфигурацию и повторите попытку.'**
  String get socialFacebookConfigError;

  /// No description provided for @socialFacebookDataError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить данные для входа через Facebook.'**
  String get socialFacebookDataError;

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Найдите подходящего соседа'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подбирайте людей, а не только квартиры.'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get getStarted;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'С возвращением'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы найти идеального соседа'**
  String get authSubtitle;

  /// No description provided for @authPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get authPhone;

  /// No description provided for @authEmail.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get authEmail;

  /// No description provided for @authPhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get authPhoneLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get authEmailLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'+7 (700) 000-00-00'**
  String get authPhoneHint;

  /// No description provided for @authEmailHint.
  ///
  /// In ru, this message translates to:
  /// **'you@gmail.com'**
  String get authEmailHint;

  /// No description provided for @authContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get authContinue;

  /// No description provided for @authTerms.
  ///
  /// In ru, this message translates to:
  /// **'Продолжая, вы соглашаетесь с условиями сервиса и политикой конфиденциальности'**
  String get authTerms;

  /// No description provided for @otpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите код подтверждения'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили вам код'**
  String get otpSubtitle;

  /// No description provided for @otpVerify.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get otpVerify;

  /// No description provided for @otpResend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код еще раз'**
  String get otpResend;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @loginButtonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Вход...'**
  String get loginButtonLoading;

  /// No description provided for @loginRegisterPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? '**
  String get loginRegisterPrefix;

  /// No description provided for @loginRegisterLink.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get loginRegisterLink;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerEmailTab.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get registerEmailTab;

  /// No description provided for @registerPhoneTab.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get registerPhoneTab;

  /// No description provided for @registerEmailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get registerConfirmLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In ru, this message translates to:
  /// **'email@gmail.com'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmHint.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get registerConfirmHint;

  /// No description provided for @registerRemember.
  ///
  /// In ru, this message translates to:
  /// **'Запомнить'**
  String get registerRemember;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @registerButtonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация...'**
  String get registerButtonLoading;

  /// No description provided for @registerLoginPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? '**
  String get registerLoginPrefix;

  /// No description provided for @registerLoginLink.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get registerLoginLink;

  /// No description provided for @registerEmailError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный формат почты'**
  String get registerEmailError;

  /// No description provided for @registerPasswordError.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get registerPasswordError;

  /// No description provided for @registerConfirmError.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get registerConfirmError;

  /// No description provided for @verifyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите почту'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите код из письма, которое мы отправили на вашу почту:'**
  String get verifySubtitle;

  /// No description provided for @verifyInvalidCode.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код'**
  String get verifyInvalidCode;

  /// No description provided for @verifyResendNow.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код еще раз'**
  String get verifyResendNow;

  /// No description provided for @verifyResendIn.
  ///
  /// In ru, this message translates to:
  /// **'Получить новый код через {seconds} c'**
  String verifyResendIn(int seconds);

  /// No description provided for @verifyChangeEmail.
  ///
  /// In ru, this message translates to:
  /// **'Изменить почту'**
  String get verifyChangeEmail;

  /// No description provided for @verifyConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get verifyConfirm;

  /// No description provided for @codeResent.
  ///
  /// In ru, this message translates to:
  /// **'Код отправлен повторно'**
  String get codeResent;

  /// No description provided for @profileIntroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут?'**
  String get profileIntroTitle;

  /// No description provided for @profileIntroSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Расскажите нам о себе'**
  String get profileIntroSubtitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Иван Иванов'**
  String get profileNameHint;

  /// No description provided for @profileBirthDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get profileBirthDateLabel;

  /// No description provided for @profileBirthDateHint.
  ///
  /// In ru, this message translates to:
  /// **'дд.мм.гггг'**
  String get profileBirthDateHint;

  /// No description provided for @profileContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get profileContinue;

  /// No description provided for @genderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите ваш пол'**
  String get genderTitle;

  /// No description provided for @genderMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужчина'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женщина'**
  String get genderFemale;

  /// No description provided for @locationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Где вы находитесь?'**
  String get locationTitle;

  /// No description provided for @locationYourCity.
  ///
  /// In ru, this message translates to:
  /// **'Ваш город'**
  String get locationYourCity;

  /// No description provided for @locationSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get locationSkip;

  /// No description provided for @locationSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get locationSearch;

  /// No description provided for @locationPick.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get locationPick;

  /// No description provided for @homeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поиск соседей'**
  String get homeTitle;

  /// No description provided for @homeAiSearchTooltip.
  ///
  /// In ru, this message translates to:
  /// **'AI-поиск'**
  String get homeAiSearchTooltip;

  /// No description provided for @homeFilteredBanner.
  ///
  /// In ru, this message translates to:
  /// **'Показаны пользователи по выбранным фильтрам'**
  String get homeFilteredBanner;

  /// No description provided for @homeNoUsersByFilters.
  ///
  /// In ru, this message translates to:
  /// **'По этим фильтрам пользователи не найдены'**
  String get homeNoUsersByFilters;

  /// No description provided for @homeNoVisibleUsers.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет видимых пользователей'**
  String get homeNoVisibleUsers;

  /// No description provided for @homeUserHidden.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь скрыт'**
  String get homeUserHidden;

  /// No description provided for @homeSavedRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Удалено из избранного'**
  String get homeSavedRemoved;

  /// No description provided for @homeSavedAdded.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get homeSavedAdded;

  /// No description provided for @homeVerified.
  ///
  /// In ru, this message translates to:
  /// **'Подтвержден'**
  String get homeVerified;

  /// No description provided for @homeCompatibility.
  ///
  /// In ru, this message translates to:
  /// **'Совместимо: {percent}%'**
  String homeCompatibility(int percent);

  /// No description provided for @locationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Локация'**
  String get locationLabel;

  /// No description provided for @statusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// No description provided for @budgetLabel.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет'**
  String get budgetLabel;

  /// No description provided for @writeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get writeMessage;

  /// No description provided for @hide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get hide;

  /// No description provided for @saved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get saved;

  /// No description provided for @saveAction.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get saveAction;

  /// No description provided for @homeStateProfileIncompleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль для лучших совпадений'**
  String get homeStateProfileIncompleteTitle;

  /// No description provided for @homeStateProfileIncompleteSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Пользователи все равно показываются, но рекомендации станут точнее после завершения анкеты.'**
  String get homeStateProfileIncompleteSubtitle;

  /// No description provided for @homeStateVerificationPendingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверка еще идет'**
  String get homeStateVerificationPendingTitle;

  /// No description provided for @homeStateVerificationPendingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш профиль остается активным, пока модерация не завершена.'**
  String get homeStateVerificationPendingSubtitle;

  /// No description provided for @homeStateVerificationRejectedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверка требует внимания'**
  String get homeStateVerificationRejectedTitle;

  /// No description provided for @homeStateVerificationRejectedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновите данные для верификации, чтобы вернуть значок доверия.'**
  String get homeStateVerificationRejectedSubtitle;

  /// No description provided for @homeStateNoRecommendationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сильных совпадений'**
  String get homeStateNoRecommendationsTitle;

  /// No description provided for @homeStateNoRecommendationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Показываем более широкий список пользователей, пока собираются новые сигналы.'**
  String get homeStateNoRecommendationsSubtitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favoritesTitle;

  /// No description provided for @favoritesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить избранных пользователей'**
  String get favoritesLoadError;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто'**
  String get favoritesEmpty;

  /// No description provided for @messagesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get messagesTitle;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @chatsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить чаты.'**
  String get chatsLoadError;

  /// No description provided for @messagesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет сообщений'**
  String get messagesEmpty;

  /// No description provided for @startConversation.
  ///
  /// In ru, this message translates to:
  /// **'Начните переписку'**
  String get startConversation;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Профиль заполнен на 100%'**
  String get profileCompleted;

  /// No description provided for @profileCompletedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Теперь вас могут находить другие пользователи'**
  String get profileCompletedSubtitle;

  /// No description provided for @profileContinueCompletion.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить заполнение профиля'**
  String get profileContinueCompletion;

  /// No description provided for @profileContinueCompletionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль, чтобы получать больше совпадений'**
  String get profileContinueCompletionSubtitle;

  /// No description provided for @verificationStatusPending.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get verificationStatusPending;

  /// No description provided for @verificationStatusVerified.
  ///
  /// In ru, this message translates to:
  /// **'Подтвержден'**
  String get verificationStatusVerified;

  /// No description provided for @verificationStatusRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонено'**
  String get verificationStatusRejected;

  /// No description provided for @verificationStatusNotSent.
  ///
  /// In ru, this message translates to:
  /// **'Не отправлено'**
  String get verificationStatusNotSent;

  /// No description provided for @verificationIdentityVerified.
  ///
  /// In ru, this message translates to:
  /// **'Личность подтверждена'**
  String get verificationIdentityVerified;

  /// No description provided for @verificationTrustSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Повышает доверие к вашему профилю'**
  String get verificationTrustSubtitle;

  /// No description provided for @verificationPendingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ожидайте подтверждения от администратора'**
  String get verificationPendingSubtitle;

  /// No description provided for @verificationConfirmIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить личность'**
  String get verificationConfirmIdentity;

  /// No description provided for @paymentRemindersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания об оплате'**
  String get paymentRemindersTitle;

  /// No description provided for @paymentRemindersEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас у вас нет ожидающих оплат.'**
  String get paymentRemindersEmpty;

  /// No description provided for @paymentDueDate.
  ///
  /// In ru, this message translates to:
  /// **'Срок оплаты: {date}'**
  String paymentDueDate(Object date);

  /// No description provided for @editProfile.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get editProfile;

  /// No description provided for @myAgreements.
  ///
  /// In ru, this message translates to:
  /// **'Мои договоры'**
  String get myAgreements;

  /// No description provided for @myCards.
  ///
  /// In ru, this message translates to:
  /// **'Мои карты'**
  String get myCards;

  /// No description provided for @myDisputes.
  ///
  /// In ru, this message translates to:
  /// **'Мои жалобы'**
  String get myDisputes;

  /// No description provided for @userDisputes.
  ///
  /// In ru, this message translates to:
  /// **'Жалобы пользователей'**
  String get userDisputes;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In ru, this message translates to:
  /// **'Конфиденциальность'**
  String get privacy;

  /// No description provided for @security.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность'**
  String get security;

  /// No description provided for @support.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и поддержка'**
  String get support;

  /// No description provided for @aboutApp.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get logout;

  /// No description provided for @currentAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Текущий admin'**
  String get currentAdmin;

  /// No description provided for @settingsLanguageCurrent.
  ///
  /// In ru, this message translates to:
  /// **'{title}\n{value} >'**
  String settingsLanguageCurrent(Object title, Object value);

  /// No description provided for @disputesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои жалобы'**
  String get disputesTitle;

  /// No description provided for @disputesLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка жалоб...'**
  String get disputesLoading;

  /// No description provided for @disputesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить жалобы.'**
  String get disputesLoadError;

  /// No description provided for @disputesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет жалоб'**
  String get disputesEmpty;

  /// No description provided for @disputeCreatedAt.
  ///
  /// In ru, this message translates to:
  /// **'Создана: {date}'**
  String disputeCreatedAt(Object date);

  /// No description provided for @disputeReviewedAt.
  ///
  /// In ru, this message translates to:
  /// **'Рассмотрена: {date}'**
  String disputeReviewedAt(Object date);

  /// No description provided for @disputeAdminComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий модератора: {comment}'**
  String disputeAdminComment(Object comment);

  /// No description provided for @disputeDirectionOutgoing.
  ///
  /// In ru, this message translates to:
  /// **'Вы подали жалобу'**
  String get disputeDirectionOutgoing;

  /// No description provided for @disputeDirectionIncoming.
  ///
  /// In ru, this message translates to:
  /// **'На вас подали жалобу'**
  String get disputeDirectionIncoming;

  /// No description provided for @disputeDirectionDefault.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба'**
  String get disputeDirectionDefault;

  /// No description provided for @disputeAgainstUser.
  ///
  /// In ru, this message translates to:
  /// **'На пользователя: {name}'**
  String disputeAgainstUser(Object name);

  /// No description provided for @disputeFromUser.
  ///
  /// In ru, this message translates to:
  /// **'От пользователя: {name}'**
  String disputeFromUser(Object name);

  /// No description provided for @disputeNeedMoreInfo.
  ///
  /// In ru, this message translates to:
  /// **'Для рассмотрения жалобы требуется дополнительная информация.'**
  String get disputeNeedMoreInfo;

  /// No description provided for @disputeRejectedSummary.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отклонена. Нарушение не подтверждено.'**
  String get disputeRejectedSummary;

  /// No description provided for @disputeCreateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подать жалобу'**
  String get disputeCreateTitle;

  /// No description provided for @disputeReason.
  ///
  /// In ru, this message translates to:
  /// **'Причина жалобы'**
  String get disputeReason;

  /// No description provided for @titleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get descriptionLabel;

  /// No description provided for @evidenceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Доказательства'**
  String get evidenceLabel;

  /// No description provided for @evidenceHint.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на фото, видео или документ'**
  String get evidenceHint;

  /// No description provided for @addLink.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ссылку'**
  String get addLink;

  /// No description provided for @disputeModerationNotice.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба будет рассмотрена модератором. Прикладывайте только реальные доказательства.'**
  String get disputeModerationNotice;

  /// No description provided for @sendDispute.
  ///
  /// In ru, this message translates to:
  /// **'Отправить жалобу'**
  String get sendDispute;

  /// No description provided for @sending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем...'**
  String get sending;

  /// No description provided for @disputeTitleRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите заголовок жалобы.'**
  String get disputeTitleRequired;

  /// No description provided for @disputeDescriptionRequired.
  ///
  /// In ru, this message translates to:
  /// **'Опишите проблему.'**
  String get disputeDescriptionRequired;

  /// No description provided for @disputeDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали жалобы'**
  String get disputeDetailsTitle;

  /// No description provided for @participantsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get participantsTitle;

  /// No description provided for @reporter.
  ///
  /// In ru, this message translates to:
  /// **'Заявитель'**
  String get reporter;

  /// No description provided for @accused.
  ///
  /// In ru, this message translates to:
  /// **'Против кого'**
  String get accused;

  /// No description provided for @disputeDescriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Описание жалобы'**
  String get disputeDescriptionTitle;

  /// No description provided for @reviewResultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Результат рассмотрения'**
  String get reviewResultTitle;

  /// No description provided for @reasonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Причина'**
  String get reasonTitle;

  /// No description provided for @resultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get resultTitle;

  /// No description provided for @moderatorComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий модератора'**
  String get moderatorComment;

  /// No description provided for @statusTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusTitle;

  /// No description provided for @decisionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Решение'**
  String get decisionTitle;

  /// No description provided for @actionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Примененное действие'**
  String get actionTitle;

  /// No description provided for @evidenceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доказательства'**
  String get evidenceTitle;

  /// No description provided for @linkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка'**
  String get linkTitle;

  /// No description provided for @addInformation.
  ///
  /// In ru, this message translates to:
  /// **'Добавить информацию'**
  String get addInformation;

  /// No description provided for @addInformationSoon.
  ///
  /// In ru, this message translates to:
  /// **'Добавление дополнительной информации появится в следующем обновлении.'**
  String get addInformationSoon;

  /// No description provided for @disputeStatusOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыта'**
  String get disputeStatusOpen;

  /// No description provided for @disputeStatusInReview.
  ///
  /// In ru, this message translates to:
  /// **'На рассмотрении'**
  String get disputeStatusInReview;

  /// No description provided for @disputeStatusResolved.
  ///
  /// In ru, this message translates to:
  /// **'Решена'**
  String get disputeStatusResolved;

  /// No description provided for @disputeStatusRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонена'**
  String get disputeStatusRejected;

  /// No description provided for @disputeStatusClosed.
  ///
  /// In ru, this message translates to:
  /// **'Закрыта'**
  String get disputeStatusClosed;

  /// No description provided for @disputeDecisionNone.
  ///
  /// In ru, this message translates to:
  /// **'Решение не принято'**
  String get disputeDecisionNone;

  /// No description provided for @disputeDecisionAccepted.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба подтверждена'**
  String get disputeDecisionAccepted;

  /// No description provided for @disputeDecisionRejected.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отклонена'**
  String get disputeDecisionRejected;

  /// No description provided for @disputeDecisionNeedMoreInfo.
  ///
  /// In ru, this message translates to:
  /// **'Нужна дополнительная информация'**
  String get disputeDecisionNeedMoreInfo;

  /// No description provided for @disputeActionNone.
  ///
  /// In ru, this message translates to:
  /// **'Действие не применено'**
  String get disputeActionNone;

  /// No description provided for @disputeActionWarning.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get disputeActionWarning;

  /// No description provided for @disputeActionTemporaryRestriction.
  ///
  /// In ru, this message translates to:
  /// **'Временное ограничение'**
  String get disputeActionTemporaryRestriction;

  /// No description provided for @disputeActionAccountBan.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка аккаунта'**
  String get disputeActionAccountBan;

  /// No description provided for @disputeActionAgreementCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Договор отменен'**
  String get disputeActionAgreementCancelled;

  /// No description provided for @disputeActionPaymentRequired.
  ///
  /// In ru, this message translates to:
  /// **'Требуется оплата'**
  String get disputeActionPaymentRequired;

  /// No description provided for @disputeActionProfileFlagged.
  ///
  /// In ru, this message translates to:
  /// **'Профиль помечен'**
  String get disputeActionProfileFlagged;

  /// No description provided for @disputeReasonPaymentNotPaid.
  ///
  /// In ru, this message translates to:
  /// **'Не оплатил(а)'**
  String get disputeReasonPaymentNotPaid;

  /// No description provided for @disputeReasonAgreementViolation.
  ///
  /// In ru, this message translates to:
  /// **'Нарушение договора'**
  String get disputeReasonAgreementViolation;

  /// No description provided for @disputeReasonPropertyDamage.
  ///
  /// In ru, this message translates to:
  /// **'Порча имущества'**
  String get disputeReasonPropertyDamage;

  /// No description provided for @disputeReasonFakeInformation.
  ///
  /// In ru, this message translates to:
  /// **'Ложная информация'**
  String get disputeReasonFakeInformation;

  /// No description provided for @disputeReasonRudeBehavior.
  ///
  /// In ru, this message translates to:
  /// **'Грубое поведение'**
  String get disputeReasonRudeBehavior;

  /// No description provided for @disputeReasonSafetyConcern.
  ///
  /// In ru, this message translates to:
  /// **'Угроза безопасности'**
  String get disputeReasonSafetyConcern;

  /// No description provided for @disputeReasonOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get disputeReasonOther;

  /// No description provided for @aiSearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-поиск соседей'**
  String get aiSearchTitle;

  /// No description provided for @aiSearchPlaceholderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Опишите идеального соседа'**
  String get aiSearchPlaceholderTitle;

  /// No description provided for @aiSearchPlaceholderSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Например: спокойный, не курит, любит чистоту и ищет жилье в центре.'**
  String get aiSearchPlaceholderSubtitle;

  /// No description provided for @aiSearchErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить поиск'**
  String get aiSearchErrorTitle;

  /// No description provided for @aiSearchErrorSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте отправить запрос еще раз.'**
  String get aiSearchErrorSubtitle;

  /// No description provided for @aiSearchEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get aiSearchEmptyTitle;

  /// No description provided for @aiSearchEmptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить формулировку запроса или сделать его короче.'**
  String get aiSearchEmptySubtitle;

  /// No description provided for @aiSearchInputHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: тихая соседка, не курит, любит порядок'**
  String get aiSearchInputHint;

  /// No description provided for @aiSearchButton.
  ///
  /// In ru, this message translates to:
  /// **'Искать'**
  String get aiSearchButton;

  /// No description provided for @aiSuggestionQuietNoPets.
  ///
  /// In ru, this message translates to:
  /// **'Спокойная соседка без животных'**
  String get aiSuggestionQuietNoPets;

  /// No description provided for @aiSuggestionNoSmokingQuiet.
  ///
  /// In ru, this message translates to:
  /// **'Сосед без курения и с тихим режимом'**
  String get aiSuggestionNoSmokingQuiet;

  /// No description provided for @lifestyleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Образ жизни'**
  String get lifestyleTitle;

  /// No description provided for @preferencesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Предпочтения'**
  String get preferencesTitle;

  /// No description provided for @profileButton.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileButton;

  /// No description provided for @noDetails.
  ///
  /// In ru, this message translates to:
  /// **'Нет деталей'**
  String get noDetails;

  /// No description provided for @cityNotSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Город не указан'**
  String get cityNotSpecified;

  /// No description provided for @agreementsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои договоры'**
  String get agreementsTitle;

  /// No description provided for @agreementDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали договора'**
  String get agreementDetailsTitle;

  /// No description provided for @agreementEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование договора'**
  String get agreementEditTitle;

  /// No description provided for @agreementSaved.
  ///
  /// In ru, this message translates to:
  /// **'Договор сохранен.'**
  String get agreementSaved;

  /// No description provided for @agreementSentForConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Договор отправлен на подтверждение.'**
  String get agreementSentForConfirmation;

  /// No description provided for @agreementCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Договор отменен.'**
  String get agreementCancelled;

  /// No description provided for @agreementFormLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть форму договора.'**
  String get agreementFormLoadError;

  /// No description provided for @agreementPrimaryValidation.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы бюджет, город или правила совместного проживания.'**
  String get agreementPrimaryValidation;

  /// No description provided for @agreementDisputeTermsRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите порядок решения спорных ситуаций.'**
  String get agreementDisputeTermsRequired;

  /// No description provided for @agreementHousingFound.
  ///
  /// In ru, this message translates to:
  /// **'Жилье уже найдено'**
  String get agreementHousingFound;

  /// No description provided for @agreementHousingFoundYes.
  ///
  /// In ru, this message translates to:
  /// **'Можно указать адрес и планируемую дату начала проживания.'**
  String get agreementHousingFoundYes;

  /// No description provided for @agreementHousingFoundNo.
  ///
  /// In ru, this message translates to:
  /// **'Адрес и дата начала проживания пока не обязательны.'**
  String get agreementHousingFoundNo;

  /// No description provided for @agreementInfoBanner.
  ///
  /// In ru, this message translates to:
  /// **'Это соглашение между будущими соседями. Квартира может быть уже найдена или вы можете искать жилье вместе.'**
  String get agreementInfoBanner;

  /// No description provided for @agreementFieldCity.
  ///
  /// In ru, this message translates to:
  /// **'Город для совместного проживания'**
  String get agreementFieldCity;

  /// No description provided for @agreementFieldAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес жилья'**
  String get agreementFieldAddress;

  /// No description provided for @agreementFieldMoveInDate.
  ///
  /// In ru, this message translates to:
  /// **'Планируемая дата начала совместного проживания'**
  String get agreementFieldMoveInDate;

  /// No description provided for @agreementFieldMoveOutDate.
  ///
  /// In ru, this message translates to:
  /// **'Планируемая дата окончания проживания'**
  String get agreementFieldMoveOutDate;

  /// No description provided for @agreementFieldMonthlyRent.
  ///
  /// In ru, this message translates to:
  /// **'Ориентир по ежемесячному бюджету'**
  String get agreementFieldMonthlyRent;

  /// No description provided for @agreementFieldDeposit.
  ///
  /// In ru, this message translates to:
  /// **'Ориентир по депозиту'**
  String get agreementFieldDeposit;

  /// No description provided for @agreementFieldUtilitySplit.
  ///
  /// In ru, this message translates to:
  /// **'Как делить коммунальные платежи'**
  String get agreementFieldUtilitySplit;

  /// No description provided for @agreementFieldFirstUserPercent.
  ///
  /// In ru, this message translates to:
  /// **'Процент первого участника'**
  String get agreementFieldFirstUserPercent;

  /// No description provided for @agreementFieldSecondUserPercent.
  ///
  /// In ru, this message translates to:
  /// **'Процент второго участника'**
  String get agreementFieldSecondUserPercent;

  /// No description provided for @agreementFieldHouseRules.
  ///
  /// In ru, this message translates to:
  /// **'Правила совместного проживания'**
  String get agreementFieldHouseRules;

  /// No description provided for @agreementFieldGuestPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Правила приглашения гостей'**
  String get agreementFieldGuestPolicy;

  /// No description provided for @agreementFieldQuietHours.
  ///
  /// In ru, this message translates to:
  /// **'Время тишины'**
  String get agreementFieldQuietHours;

  /// No description provided for @agreementFieldCleaningSchedule.
  ///
  /// In ru, this message translates to:
  /// **'График уборки'**
  String get agreementFieldCleaningSchedule;

  /// No description provided for @agreementFieldSmokingPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Правила курения'**
  String get agreementFieldSmokingPolicy;

  /// No description provided for @agreementFieldPetPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Домашние животные'**
  String get agreementFieldPetPolicy;

  /// No description provided for @agreementFieldNoticePeriod.
  ///
  /// In ru, this message translates to:
  /// **'Срок предварительного уведомления'**
  String get agreementFieldNoticePeriod;

  /// No description provided for @agreementFieldDamageResponsibility.
  ///
  /// In ru, this message translates to:
  /// **'Ответственность за общее имущество'**
  String get agreementFieldDamageResponsibility;

  /// No description provided for @agreementFieldTerminationTerms.
  ///
  /// In ru, this message translates to:
  /// **'Порядок прекращения совместного проживания'**
  String get agreementFieldTerminationTerms;

  /// No description provided for @agreementFieldDisputeTerms.
  ///
  /// In ru, this message translates to:
  /// **'Решение спорных ситуаций'**
  String get agreementFieldDisputeTerms;

  /// No description provided for @agreementUtilityEqual.
  ///
  /// In ru, this message translates to:
  /// **'Поровну'**
  String get agreementUtilityEqual;

  /// No description provided for @agreementUtilityPercentage.
  ///
  /// In ru, this message translates to:
  /// **'В процентах'**
  String get agreementUtilityPercentage;

  /// No description provided for @agreementUtilityCustom.
  ///
  /// In ru, this message translates to:
  /// **'Индивидуально'**
  String get agreementUtilityCustom;

  /// No description provided for @agreementStatusDraft.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get agreementStatusDraft;

  /// No description provided for @agreementStatusWaitingSecondParty.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает второго участника'**
  String get agreementStatusWaitingSecondParty;

  /// No description provided for @agreementStatusPendingConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает подтверждения'**
  String get agreementStatusPendingConfirmation;

  /// No description provided for @agreementStatusActive.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get agreementStatusActive;

  /// No description provided for @agreementStatusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменен'**
  String get agreementStatusCancelled;

  /// No description provided for @agreementStatusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершен'**
  String get agreementStatusCompleted;

  /// No description provided for @agreementStatusRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонен'**
  String get agreementStatusRejected;

  /// No description provided for @socialLoginGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get socialLoginGoogle;

  /// No description provided for @socialLoginFacebook.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Facebook'**
  String get socialLoginFacebook;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @profileCompletedSearchCTA.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к поиску'**
  String get profileCompletedSearchCTA;

  /// No description provided for @profileVerificationOptionalCTA.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить личность (необязательно)'**
  String get profileVerificationOptionalCTA;

  /// No description provided for @profileVerificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение личности'**
  String get profileVerificationTitle;

  /// No description provided for @profileVerificationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвержденные пользователи вызывают больше доверия'**
  String get profileVerificationSubtitle;

  /// No description provided for @profileVerificationBenefitBadge.
  ///
  /// In ru, this message translates to:
  /// **'Синяя галочка в профиле'**
  String get profileVerificationBenefitBadge;

  /// No description provided for @profileVerificationBenefitPriority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет в рекомендациях'**
  String get profileVerificationBenefitPriority;

  /// No description provided for @profileVerificationBenefitReplies.
  ///
  /// In ru, this message translates to:
  /// **'Больше откликов'**
  String get profileVerificationBenefitReplies;

  /// No description provided for @profileVerificationUploadTitle.
  ///
  /// In ru, this message translates to:
  /// **'Загрузите свой документ'**
  String get profileVerificationUploadTitle;

  /// No description provided for @profileVerificationUploadSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Документ используется только для проверки и не отображается другим'**
  String get profileVerificationUploadSubtitle;

  /// No description provided for @profileVerificationUploadDocumentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить фото документа'**
  String get profileVerificationUploadDocumentLabel;

  /// No description provided for @profileVerificationUploadSelfieTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сделайте селфи'**
  String get profileVerificationUploadSelfieTitle;

  /// No description provided for @profileVerificationUploadSelfieLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сделать селфи'**
  String get profileVerificationUploadSelfieLabel;

  /// No description provided for @profileVerificationChecklistTitle.
  ///
  /// In ru, this message translates to:
  /// **'Убедитесь, что:'**
  String get profileVerificationChecklistTitle;

  /// No description provided for @profileVerificationChecklistClearPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото четкое'**
  String get profileVerificationChecklistClearPhoto;

  /// No description provided for @profileVerificationChecklistNoGlare.
  ///
  /// In ru, this message translates to:
  /// **'Без бликов'**
  String get profileVerificationChecklistNoGlare;

  /// No description provided for @profileVerificationChecklistAllEdges.
  ///
  /// In ru, this message translates to:
  /// **'Все края видны'**
  String get profileVerificationChecklistAllEdges;

  /// No description provided for @profileVerificationSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Отправить на проверку'**
  String get profileVerificationSubmit;

  /// No description provided for @profileVerificationSubmitting.
  ///
  /// In ru, this message translates to:
  /// **'Отправка...'**
  String get profileVerificationSubmitting;

  /// No description provided for @profileVerificationSuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Документы отправлены!'**
  String get profileVerificationSuccessTitle;

  /// No description provided for @profileVerificationSuccessSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы проверим данные в течение 24 часов.'**
  String get profileVerificationSuccessSubtitle;
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
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
