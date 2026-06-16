// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Roomie';

  @override
  String get appBrand => 'Roomie';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageApp => 'Қосымша тілі';

  @override
  String get settingsTitle => 'Баптаулар';

  @override
  String get save => 'Сақтау';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get close => 'Жабу';

  @override
  String get retry => 'Қайталау';

  @override
  String get loading => 'Жүктелуде...';

  @override
  String get userFallback => 'Пайдаланушы';

  @override
  String get notSpecified => 'Көрсетілмеген';

  @override
  String get errorGeneric => 'Бір қате шықты. Қайтадан көріңіз.';

  @override
  String get errorServer => 'Сервер қатесі. Кейінірек қайталап көріңіз.';

  @override
  String get errorNetwork =>
      'Серверге қосылу мүмкін болмады. Интернетті тексеріңіз.';

  @override
  String get errorInvalidCredentials => 'Логин немесе құпиясөз қате.';

  @override
  String get errorAccountNotVerified =>
      'Аккаунт расталмаған. Кодты тексеруді аяқтаңыз.';

  @override
  String get errorEmailExists => 'Бұл email бұрыннан тіркелген.';

  @override
  String get errorPhoneExists => 'Бұл нөмір бұрыннан тіркелген.';

  @override
  String get errorSessionExpired => 'Сессия мерзімі аяқталды. Қайта кіріңіз.';

  @override
  String get errorValidation =>
      'Енгізілген мәліметтердің дұрыстығын тексеріңіз.';

  @override
  String get errorNoAccess => 'Бұл әрекетке рұқсатыңыз жоқ.';

  @override
  String get errorTooManyAttempts =>
      'Әрекет саны тым көп. Сәл күтіп, қайта көріңіз.';

  @override
  String get errorUserNotFound => 'Пайдаланушы табылмады. Алдымен тіркеліңіз.';

  @override
  String get errorAuthLoginFailed =>
      'Кіру мүмкін болмады. Кейінірек қайталап көріңіз.';

  @override
  String get errorAuthRegisterFailed =>
      'Тіркелу мүмкін болмады. Кейінірек қайталап көріңіз.';

  @override
  String get errorOtpConfirmFailed =>
      'Кодты растау мүмкін болмады. Қайтадан көріңіз.';

  @override
  String get errorOtpResendFailed =>
      'Кодты қайта жіберу мүмкін болмады. Кейінірек көріңіз.';

  @override
  String get errorProfileLoadFailed =>
      'Профильді жүктеу мүмкін болмады. Кейінірек көріңіз.';

  @override
  String get errorSaveStepFailed => 'Қадамды сақтау мүмкін болмады.';

  @override
  String get errorSaveGenderFailed => 'Жынысты сақтау мүмкін болмады.';

  @override
  String get errorSaveCityFailed => 'Қаланы сақтау мүмкін болмады.';

  @override
  String get errorInvalidBirthDate => 'Туған күнді дұрыс енгізіңіз.';

  @override
  String get errorFillAllFields => 'Барлық өрістерді толтырыңыз.';

  @override
  String get socialGoogleCancelled => 'Google арқылы кіру тоқтатылды.';

  @override
  String get socialGoogleConfigError =>
      'Google Sign-In бапталмаған. Баптауды тексеріп, қайта көріңіз.';

  @override
  String get socialGoogleTokenMissing =>
      'Google токен қайтармады. Кейінірек қайталап көріңіз.';

  @override
  String get socialFacebookCancelled => 'Facebook арқылы кіру тоқтатылды.';

  @override
  String get socialFacebookConfigError =>
      'Facebook Login бапталмаған. Баптауды тексеріп, қайта көріңіз.';

  @override
  String get socialFacebookDataError =>
      'Facebook арқылы кіру деректерін алу мүмкін болмады.';

  @override
  String get welcomeTitle => 'Өзіңізге лайық көрші табыңыз';

  @override
  String get welcomeSubtitle =>
      'Тек пәтерді емес, адамдарды да сәйкестендіріңіз.';

  @override
  String get getStarted => 'Бастау';

  @override
  String get authTitle => 'Қайта қош келдіңіз';

  @override
  String get authSubtitle => 'Мінсіз көршіні табу үшін кіріңіз';

  @override
  String get authPhone => 'Телефон';

  @override
  String get authEmail => 'Пошта';

  @override
  String get authPhoneLabel => 'Телефон нөмірі';

  @override
  String get authEmailLabel => 'Пошта';

  @override
  String get authPhoneHint => '+7 (700) 000-00-00';

  @override
  String get authEmailHint => 'you@gmail.com';

  @override
  String get authContinue => 'Жалғастыру';

  @override
  String get authTerms =>
      'Жалғастыру арқылы сіз сервис шарттары мен құпиялылық саясатына келісесіз';

  @override
  String get otpTitle => 'Растау кодын енгізіңіз';

  @override
  String get otpSubtitle => 'Біз сізге код жібердік';

  @override
  String get otpVerify => 'Растау';

  @override
  String get otpResend => 'Кодты қайта жіберу';

  @override
  String get otpDebugCodeTitle => 'Тест коды';

  @override
  String get otpDebugCodeHint =>
      'Егер хат не SMS келмесе, осы кодты пайдаланыңыз. Көшіру үшін басыңыз.';

  @override
  String get otpDebugCodeCopied => 'Код көшірілді';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginButton => 'Кіру';

  @override
  String get loginButtonLoading => 'Кіру...';

  @override
  String get loginRegisterPrefix => 'Аккаунтыңыз жоқ па? ';

  @override
  String get loginRegisterLink => 'Тіркелу';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get registerEmailTab => 'Пошта';

  @override
  String get registerPhoneTab => 'Телефон';

  @override
  String get registerEmailLabel => 'Пошта';

  @override
  String get registerPasswordLabel => 'Құпиясөз';

  @override
  String get registerConfirmLabel => 'Құпиясөзді растаңыз';

  @override
  String get registerEmailHint => 'email@gmail.com';

  @override
  String get registerPasswordHint => 'Құпиясөз';

  @override
  String get registerConfirmHint => 'Құпиясөз';

  @override
  String get registerRemember => 'Есте сақтау';

  @override
  String get registerButton => 'Тіркелу';

  @override
  String get registerButtonLoading => 'Тіркелуде...';

  @override
  String get registerLoginPrefix => 'Аккаунтыңыз бар ма? ';

  @override
  String get registerLoginLink => 'Кіру';

  @override
  String get registerEmailError => 'Пошта форматы қате';

  @override
  String get registerPasswordError => 'Құпиясөзді енгізіңіз';

  @override
  String get registerConfirmError => 'Құпиясөздер сәйкес келмейді';

  @override
  String get verifyTitle => 'Поштаны растаңыз';

  @override
  String get verifySubtitle => 'Поштаңызға жіберілген кодты енгізіңіз:';

  @override
  String get verifyInvalidCode => 'Қате код';

  @override
  String get verifyResendNow => 'Кодты қайта жіберу';

  @override
  String verifyResendIn(int seconds) {
    return 'Жаңа кодты $seconds c кейін алуға болады';
  }

  @override
  String get verifyChangeEmail => 'Поштаны өзгерту';

  @override
  String get verifyConfirm => 'Растау';

  @override
  String get codeResent => 'Код қайта жіберілді';

  @override
  String get profileIntroTitle => 'Сіздің атыңыз кім?';

  @override
  String get profileIntroSubtitle => 'Өзіңіз туралы айтып беріңіз';

  @override
  String get profileNameLabel => 'Атыңыз';

  @override
  String get profileNameHint => 'Иван Иванов';

  @override
  String get profileBirthDateLabel => 'Туған күніңіз';

  @override
  String get profileBirthDateHint => 'кк.аа.жжжж';

  @override
  String get profileContinue => 'Жалғастыру';

  @override
  String get genderTitle => 'Жынысыңызды көрсетіңіз';

  @override
  String get genderMale => 'Ер адам';

  @override
  String get genderFemale => 'Әйел';

  @override
  String get locationTitle => 'Қай қалада тұрасыз?';

  @override
  String get locationYourCity => 'Сіздің қалаңыз';

  @override
  String get locationSkip => 'Өткізіп жіберу';

  @override
  String get locationSearch => 'Іздеу';

  @override
  String get locationPick => 'Таңдау';

  @override
  String get homeTitle => 'Көрші іздеу';

  @override
  String get homeAiSearchTooltip => 'AI-іздеу';

  @override
  String get homeFilteredBanner =>
      'Таңдалған фильтрлер бойынша пайдаланушылар көрсетілуде';

  @override
  String get homeNoUsersByFilters =>
      'Бұл фильтрлер бойынша пайдаланушылар табылмады';

  @override
  String get homeNoVisibleUsers => 'Қазір көрінетін пайдаланушылар жоқ';

  @override
  String get homeUserHidden => 'Пайдаланушы жасырылды';

  @override
  String get homeSavedRemoved => 'Таңдаулылардан өшірілді';

  @override
  String get homeSavedAdded => 'Сақталды';

  @override
  String get homeVerified => 'Расталған';

  @override
  String homeCompatibility(int percent) {
    return 'Сәйкестік: $percent%';
  }

  @override
  String get locationLabel => 'Локация';

  @override
  String get statusLabel => 'Мәртебе';

  @override
  String get budgetLabel => 'Бюджет';

  @override
  String get writeMessage => 'Жазу';

  @override
  String get hide => 'Жасыру';

  @override
  String get saved => 'Сақталған';

  @override
  String get saveAction => 'Сақтау';

  @override
  String get homeStateProfileIncompleteTitle =>
      'Жақсы сәйкестік үшін профильді толтырыңыз';

  @override
  String get homeStateProfileIncompleteSubtitle =>
      'Пайдаланушылар бәрібір көрсетіледі, бірақ анкета толық болғанда ұсыныстар дәлірек болады.';

  @override
  String get homeStateVerificationPendingTitle => 'Тексеру әлі жүріп жатыр';

  @override
  String get homeStateVerificationPendingSubtitle =>
      'Модерация аяқталғанша профиліңіз белсенді күйде қалады.';

  @override
  String get homeStateVerificationRejectedTitle =>
      'Тексеру назарды қажет етеді';

  @override
  String get homeStateVerificationRejectedSubtitle =>
      'Сенім белгісін қайтару үшін верификация деректерін жаңартыңыз.';

  @override
  String get homeStateNoRecommendationsTitle => 'Әзірге күшті сәйкестіктер жоқ';

  @override
  String get homeStateNoRecommendationsSubtitle =>
      'Жаңа сигналдар жиналғанша, кеңірек пайдаланушылар тізімі көрсетіледі.';

  @override
  String get favoritesTitle => 'Таңдаулылар';

  @override
  String get favoritesLoadError =>
      'Таңдаулы пайдаланушыларды жүктеу мүмкін болмады';

  @override
  String get favoritesEmpty => 'Әзірге бос';

  @override
  String get messagesTitle => 'Хабарламалар';

  @override
  String get search => 'Іздеу';

  @override
  String get chatsLoadError => 'Чаттарды жүктеу мүмкін болмады.';

  @override
  String get messagesEmpty => 'Әзірге хабарламаларыңыз жоқ';

  @override
  String get startConversation => 'Хат алмасуды бастаңыз';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileCompleted => 'Профиль 100% толтырылған';

  @override
  String get profileCompletedSubtitle =>
      'Енді сізді басқа пайдаланушылар таба алады';

  @override
  String get profileContinueCompletion => 'Профильді толтыруды жалғастыру';

  @override
  String get profileContinueCompletionSubtitle =>
      'Көбірек сәйкестік алу үшін профильді толықтырыңыз';

  @override
  String get verificationStatusPending => 'Тексерілуде';

  @override
  String get verificationStatusVerified => 'Расталған';

  @override
  String get verificationStatusRejected => 'Қабылданбады';

  @override
  String get verificationStatusNotSent => 'Жіберілмеген';

  @override
  String get verificationIdentityVerified => 'Жеке тұлға расталды';

  @override
  String get verificationTrustSubtitle => 'Профильге деген сенімді арттырады';

  @override
  String get verificationPendingSubtitle => 'Әкімшінің растауын күтіңіз';

  @override
  String get verificationConfirmIdentity => 'Жеке тұлғаны растау';

  @override
  String get paymentRemindersTitle => 'Төлем еске салғыштары';

  @override
  String get paymentRemindersEmpty => 'Қазір күтілетін төлемдер жоқ.';

  @override
  String paymentDueDate(Object date) {
    return 'Төлем мерзімі: $date';
  }

  @override
  String get editProfile => 'Профильді өңдеу';

  @override
  String get myAgreements => 'Менің келісімдерім';

  @override
  String get myCards => 'Менің карталарым';

  @override
  String get myDisputes => 'Менің шағымдарым';

  @override
  String get userDisputes => 'Пайдаланушылар шағымдары';

  @override
  String get notifications => 'Хабарламалар';

  @override
  String get privacy => 'Құпиялылық';

  @override
  String get security => 'Қауіпсіздік';

  @override
  String get support => 'Көмек және қолдау';

  @override
  String get aboutApp => 'Қосымша туралы';

  @override
  String get logout => 'Шығу';

  @override
  String get currentAdmin => 'Ағымдағы admin';

  @override
  String settingsLanguageCurrent(Object title, Object value) {
    return '$title\n$value >';
  }

  @override
  String get disputesTitle => 'Менің шағымдарым';

  @override
  String get disputesLoading => 'Шағымдар жүктелуде...';

  @override
  String get disputesLoadError => 'Шағымдарды жүктеу мүмкін болмады.';

  @override
  String get disputesEmpty => 'Сізде әзірге шағым жоқ';

  @override
  String disputeCreatedAt(Object date) {
    return 'Құрылды: $date';
  }

  @override
  String disputeReviewedAt(Object date) {
    return 'Қаралды: $date';
  }

  @override
  String disputeAdminComment(Object comment) {
    return 'Модератор пікірі: $comment';
  }

  @override
  String get disputeDirectionOutgoing => 'Сіз шағым жібердіңіз';

  @override
  String get disputeDirectionIncoming => 'Сізге шағым түсті';

  @override
  String get disputeDirectionDefault => 'Шағым';

  @override
  String disputeAgainstUser(Object name) {
    return 'Пайдаланушыға қарсы: $name';
  }

  @override
  String disputeFromUser(Object name) {
    return 'Пайдаланушыдан: $name';
  }

  @override
  String get disputeNeedMoreInfo => 'Шағымды қарау үшін қосымша ақпарат қажет.';

  @override
  String get disputeRejectedSummary =>
      'Шағым қабылданбады. Бұзушылық расталмады.';

  @override
  String get disputeCreateTitle => 'Шағым жіберу';

  @override
  String get disputeReason => 'Шағым себебі';

  @override
  String get titleLabel => 'Тақырып';

  @override
  String get descriptionLabel => 'Сипаттама';

  @override
  String get evidenceLabel => 'Дәлелдер';

  @override
  String get evidenceHint => 'Фотоға, видеоға немесе құжатқа сілтеме';

  @override
  String get addLink => 'Сілтеме қосу';

  @override
  String get disputeModerationNotice =>
      'Шағымды модератор қарайды. Тек нақты дәлелдерді тіркеңіз.';

  @override
  String get sendDispute => 'Шағымды жіберу';

  @override
  String get sending => 'Жіберілуде...';

  @override
  String get disputeTitleRequired => 'Шағым тақырыбын көрсетіңіз.';

  @override
  String get disputeDescriptionRequired => 'Мәселені сипаттаңыз.';

  @override
  String get disputeDetailsTitle => 'Шағым туралы толық ақпарат';

  @override
  String get participantsTitle => 'Қатысушылар';

  @override
  String get reporter => 'Шағым беруші';

  @override
  String get accused => 'Қарсы тарап';

  @override
  String get disputeDescriptionTitle => 'Шағым сипаттамасы';

  @override
  String get reviewResultTitle => 'Қарау нәтижесі';

  @override
  String get reasonTitle => 'Себеп';

  @override
  String get resultTitle => 'Нәтиже';

  @override
  String get moderatorComment => 'Модератор пікірі';

  @override
  String get statusTitle => 'Күйі';

  @override
  String get decisionTitle => 'Шешім';

  @override
  String get actionTitle => 'Қолданылған әрекет';

  @override
  String get evidenceTitle => 'Дәлелдер';

  @override
  String get linkTitle => 'Сілтеме';

  @override
  String get addInformation => 'Ақпарат қосу';

  @override
  String get addInformationSoon =>
      'Қосымша ақпарат енгізу келесі жаңартуда қосылады.';

  @override
  String get disputeStatusOpen => 'Ашық';

  @override
  String get disputeStatusInReview => 'Қаралуда';

  @override
  String get disputeStatusResolved => 'Шешілді';

  @override
  String get disputeStatusRejected => 'Қабылданбады';

  @override
  String get disputeStatusClosed => 'Жабық';

  @override
  String get disputeDecisionNone => 'Шешім қабылданбады';

  @override
  String get disputeDecisionAccepted => 'Шағым расталды';

  @override
  String get disputeDecisionRejected => 'Шағым қабылданбады';

  @override
  String get disputeDecisionNeedMoreInfo => 'Қосымша ақпарат қажет';

  @override
  String get disputeActionNone => 'Әрекет қолданылмады';

  @override
  String get disputeActionWarning => 'Ескерту';

  @override
  String get disputeActionTemporaryRestriction => 'Уақытша шектеу';

  @override
  String get disputeActionAccountBan => 'Аккаунтты бұғаттау';

  @override
  String get disputeActionAgreementCancelled => 'Келісім жойылды';

  @override
  String get disputeActionPaymentRequired => 'Төлем қажет';

  @override
  String get disputeActionProfileFlagged => 'Профиль белгіленді';

  @override
  String get disputeReasonPaymentNotPaid => 'Төлем жасамады';

  @override
  String get disputeReasonAgreementViolation => 'Келісімді бұзу';

  @override
  String get disputeReasonPropertyDamage => 'Мүлікке зиян келтіру';

  @override
  String get disputeReasonFakeInformation => 'Жалған ақпарат';

  @override
  String get disputeReasonRudeBehavior => 'Дөрекі әрекет';

  @override
  String get disputeReasonSafetyConcern => 'Қауіпсіздікке қатер';

  @override
  String get disputeReasonOther => 'Басқа';

  @override
  String get aiSearchTitle => 'ИИ арқылы көрші іздеу';

  @override
  String get aiSearchPlaceholderTitle => 'Мінсіз көршіні сипаттаңыз';

  @override
  String get aiSearchPlaceholderSubtitle =>
      'Мысалы: тыныш, темекі шекпейді, тазалықты жақсы көреді және орталықтан үй іздейді.';

  @override
  String get aiSearchErrorTitle => 'Іздеуді орындау мүмкін болмады';

  @override
  String get aiSearchErrorSubtitle => 'Сұранысты қайта жіберіп көріңіз.';

  @override
  String get aiSearchEmptyTitle => 'Ештеңе табылмады';

  @override
  String get aiSearchEmptySubtitle =>
      'Сұранысты басқаша жазыңыз немесе қысқартып көріңіз.';

  @override
  String get aiSearchInputHint =>
      'Мысалы: тыныш көрші, темекі шекпейді, тәртіпті жақсы көреді';

  @override
  String get aiSearchButton => 'Іздеу';

  @override
  String get aiSuggestionQuietNoPets => 'Жануарсыз тыныш көрші қыз';

  @override
  String get aiSuggestionNoSmokingQuiet =>
      'Темекі шекпейтін, тыныш режимдегі көрші';

  @override
  String get lifestyleTitle => 'Өмір салты';

  @override
  String get preferencesTitle => 'Қалаулар';

  @override
  String get profileButton => 'Профиль';

  @override
  String get noDetails => 'Толық мәлімет жоқ';

  @override
  String get cityNotSpecified => 'Қала көрсетілмеген';

  @override
  String get agreementsTitle => 'Менің келісімдерім';

  @override
  String get agreementDetailsTitle => 'Келісім туралы мәлімет';

  @override
  String get agreementEditTitle => 'Келісімді өңдеу';

  @override
  String get agreementSaved => 'Келісім сақталды.';

  @override
  String get agreementSentForConfirmation => 'Келісім растауға жіберілді.';

  @override
  String get agreementCancelled => 'Келісім жойылды.';

  @override
  String get agreementFormLoadError => 'Келісім формасын ашу мүмкін болмады.';

  @override
  String get agreementPrimaryValidation =>
      'Кем дегенде бюджет, қала немесе бірге тұру ережелерін қосыңыз.';

  @override
  String get agreementDisputeTermsRequired =>
      'Даулы жағдайларды шешу тәртібін көрсетіңіз.';

  @override
  String get agreementHousingFound => 'Тұрғын үй табылған';

  @override
  String get agreementHousingFoundYes =>
      'Мекенжай мен көшудің жоспарланған күнін көрсетуге болады.';

  @override
  String get agreementHousingFoundNo =>
      'Мекенжай мен көшу күні әзірге міндетті емес.';

  @override
  String get agreementInfoBanner =>
      'Бұл болашақ көршілер арасындағы келісім. Пәтер табылған болуы мүмкін немесе оны бірге іздей аласыздар.';

  @override
  String get agreementFieldCity => 'Бірге тұратын қала';

  @override
  String get agreementFieldAddress => 'Тұрғын үй мекенжайы';

  @override
  String get agreementFieldMoveInDate =>
      'Бірге тұрудың жоспарланған басталу күні';

  @override
  String get agreementFieldMoveOutDate => 'Тұрудың жоспарланған аяқталу күні';

  @override
  String get agreementFieldMonthlyRent => 'Ай сайынғы бюджет бағдары';

  @override
  String get agreementFieldDeposit => 'Депозит бағдары';

  @override
  String get agreementFieldUtilitySplit =>
      'Коммуналдық төлемдерді қалай бөлу керек';

  @override
  String get agreementFieldFirstUserPercent => 'Бірінші қатысушы пайызы';

  @override
  String get agreementFieldSecondUserPercent => 'Екінші қатысушы пайызы';

  @override
  String get agreementFieldHouseRules => 'Бірге тұру ережелері';

  @override
  String get agreementFieldGuestPolicy => 'Қонақ шақыру ережелері';

  @override
  String get agreementFieldQuietHours => 'Тыныштық уақыты';

  @override
  String get agreementFieldCleaningSchedule => 'Тазалық кестесі';

  @override
  String get agreementFieldSmokingPolicy => 'Темекі шегу ережелері';

  @override
  String get agreementFieldPetPolicy => 'Үй жануарлары';

  @override
  String get agreementFieldNoticePeriod => 'Алдын ала ескерту мерзімі';

  @override
  String get agreementFieldDamageResponsibility =>
      'Ортақ мүлікке жауапкершілік';

  @override
  String get agreementFieldTerminationTerms => 'Бірге тұруды тоқтату тәртібі';

  @override
  String get agreementFieldDisputeTerms => 'Дауды шешу тәртібі';

  @override
  String get agreementUtilityEqual => 'Тең бөлу';

  @override
  String get agreementUtilityPercentage => 'Пайызбен';

  @override
  String get agreementUtilityCustom => 'Жеке түрде';

  @override
  String get agreementStatusDraft => 'Қаралама';

  @override
  String get agreementStatusWaitingSecondParty => 'Екінші қатысушыны күтуде';

  @override
  String get agreementStatusPendingConfirmation => 'Растауды күтуде';

  @override
  String get agreementStatusActive => 'Белсенді';

  @override
  String get agreementStatusCancelled => 'Жойылды';

  @override
  String get agreementStatusCompleted => 'Аяқталды';

  @override
  String get agreementStatusRejected => 'Қабылданбады';

  @override
  String get socialLoginGoogle => 'Google арқылы кіру';

  @override
  String get socialLoginFacebook => 'Facebook арқылы кіру';

  @override
  String get done => 'Дайын';

  @override
  String get profileCompletedSearchCTA => 'Іздеуге өту';

  @override
  String get profileVerificationOptionalCTA =>
      'Жеке тұлғаны растау (міндетті емес)';

  @override
  String get profileVerificationTitle => 'Жеке тұлғаны растау';

  @override
  String get profileVerificationSubtitle =>
      'Расталған қолданушылар көбірек сенім тудырады';

  @override
  String get profileVerificationBenefitBadge => 'Профильдегі көк белгі';

  @override
  String get profileVerificationBenefitPriority => 'Ұсыныстарда басымдық';

  @override
  String get profileVerificationBenefitReplies => 'Көбірек жауап алу';

  @override
  String get profileVerificationUploadTitle => 'Құжатыңызды жүктеңіз';

  @override
  String get profileVerificationUploadSubtitle =>
      'Құжат тек тексеру үшін пайдаланылады және басқа адамдарға көрсетілмейді';

  @override
  String get profileVerificationUploadDocumentLabel =>
      'Құжаттың фотосын жүктеу';

  @override
  String get profileVerificationUploadSelfieTitle => 'Селфи жасаңыз';

  @override
  String get profileVerificationUploadSelfieLabel => 'Селфи жасау';

  @override
  String get profileVerificationChecklistTitle => 'Мыналарға көз жеткізіңіз:';

  @override
  String get profileVerificationChecklistClearPhoto => 'Фото анық болуы керек';

  @override
  String get profileVerificationChecklistNoGlare => 'Жарқыл болмауы керек';

  @override
  String get profileVerificationChecklistAllEdges =>
      'Барлық шеттері көрініп тұруы керек';

  @override
  String get profileVerificationSubmit => 'Тексеруге жіберу';

  @override
  String get profileVerificationSubmitting => 'Жіберілуде...';

  @override
  String get profileVerificationSuccessTitle => 'Құжаттар жіберілді!';

  @override
  String get profileVerificationSuccessSubtitle =>
      'Біз деректерді 24 сағат ішінде тексереміз.';
}
