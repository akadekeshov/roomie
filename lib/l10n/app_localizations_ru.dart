// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Roomie';

  @override
  String get appBrand => 'Roomie';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageApp => 'Язык приложения';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get userFallback => 'Пользователь';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте еще раз.';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errorNetwork => 'Нет подключения к серверу. Проверьте интернет.';

  @override
  String get errorInvalidCredentials => 'Неверный логин или пароль.';

  @override
  String get errorAccountNotVerified =>
      'Аккаунт не подтвержден. Завершите проверку кода.';

  @override
  String get errorEmailExists => 'Этот email уже зарегистрирован.';

  @override
  String get errorPhoneExists => 'Этот номер уже зарегистрирован.';

  @override
  String get errorSessionExpired => 'Сессия истекла. Войдите снова.';

  @override
  String get errorValidation => 'Проверьте корректность введенных данных.';

  @override
  String get errorNoAccess => 'У вас нет доступа к этому действию.';

  @override
  String get errorTooManyAttempts =>
      'Слишком много попыток. Подождите немного и попробуйте снова.';

  @override
  String get errorUserNotFound =>
      'Пользователь не найден. Сначала зарегистрируйтесь.';

  @override
  String get errorAuthLoginFailed => 'Не удалось войти. Попробуйте позже.';

  @override
  String get errorAuthRegisterFailed =>
      'Не удалось зарегистрироваться. Попробуйте позже.';

  @override
  String get errorOtpConfirmFailed =>
      'Не удалось подтвердить код. Попробуйте снова.';

  @override
  String get errorOtpResendFailed =>
      'Не удалось отправить код. Попробуйте позже.';

  @override
  String get errorProfileLoadFailed =>
      'Не удалось загрузить профиль. Попробуйте позже.';

  @override
  String get errorSaveStepFailed => 'Не удалось сохранить шаг.';

  @override
  String get errorSaveGenderFailed => 'Не удалось сохранить пол.';

  @override
  String get errorSaveCityFailed => 'Не удалось сохранить город.';

  @override
  String get errorInvalidBirthDate => 'Введите корректную дату рождения.';

  @override
  String get errorFillAllFields => 'Пожалуйста, заполните все поля.';

  @override
  String get socialGoogleCancelled => 'Вход через Google был отменен.';

  @override
  String get socialGoogleConfigError =>
      'Google Sign-In не настроен. Проверьте конфигурацию и повторите попытку.';

  @override
  String get socialGoogleTokenMissing =>
      'Google не вернул токены. Повторите попытку позже.';

  @override
  String get socialFacebookCancelled => 'Вход через Facebook был отменен.';

  @override
  String get socialFacebookConfigError =>
      'Facebook Login не настроен. Проверьте конфигурацию и повторите попытку.';

  @override
  String get socialFacebookDataError =>
      'Не удалось получить данные для входа через Facebook.';

  @override
  String get welcomeTitle => 'Найдите подходящего соседа';

  @override
  String get welcomeSubtitle => 'Подбирайте людей, а не только квартиры.';

  @override
  String get getStarted => 'Начать';

  @override
  String get authTitle => 'С возвращением';

  @override
  String get authSubtitle => 'Войдите, чтобы найти идеального соседа';

  @override
  String get authPhone => 'Телефон';

  @override
  String get authEmail => 'Почта';

  @override
  String get authPhoneLabel => 'Номер телефона';

  @override
  String get authEmailLabel => 'Почта';

  @override
  String get authPhoneHint => '+7 (700) 000-00-00';

  @override
  String get authEmailHint => 'you@gmail.com';

  @override
  String get authContinue => 'Продолжить';

  @override
  String get authTerms =>
      'Продолжая, вы соглашаетесь с условиями сервиса и политикой конфиденциальности';

  @override
  String get otpTitle => 'Введите код подтверждения';

  @override
  String get otpSubtitle => 'Мы отправили вам код';

  @override
  String get otpVerify => 'Подтвердить';

  @override
  String get otpResend => 'Отправить код еще раз';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginButtonLoading => 'Вход...';

  @override
  String get loginRegisterPrefix => 'Нет аккаунта? ';

  @override
  String get loginRegisterLink => 'Зарегистрироваться';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerEmailTab => 'Почта';

  @override
  String get registerPhoneTab => 'Телефон';

  @override
  String get registerEmailLabel => 'Почта';

  @override
  String get registerPasswordLabel => 'Пароль';

  @override
  String get registerConfirmLabel => 'Подтвердите пароль';

  @override
  String get registerEmailHint => 'email@gmail.com';

  @override
  String get registerPasswordHint => 'Пароль';

  @override
  String get registerConfirmHint => 'Пароль';

  @override
  String get registerRemember => 'Запомнить';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get registerButtonLoading => 'Регистрация...';

  @override
  String get registerLoginPrefix => 'Уже есть аккаунт? ';

  @override
  String get registerLoginLink => 'Войти';

  @override
  String get registerEmailError => 'Неверный формат почты';

  @override
  String get registerPasswordError => 'Введите пароль';

  @override
  String get registerConfirmError => 'Пароли не совпадают';

  @override
  String get verifyTitle => 'Подтвердите почту';

  @override
  String get verifySubtitle =>
      'Введите код из письма, которое мы отправили на вашу почту:';

  @override
  String get verifyInvalidCode => 'Неверный код';

  @override
  String get verifyResendNow => 'Отправить код еще раз';

  @override
  String verifyResendIn(int seconds) {
    return 'Получить новый код через $seconds c';
  }

  @override
  String get verifyChangeEmail => 'Изменить почту';

  @override
  String get verifyConfirm => 'Подтвердить';

  @override
  String get codeResent => 'Код отправлен повторно';

  @override
  String get profileIntroTitle => 'Как вас зовут?';

  @override
  String get profileIntroSubtitle => 'Расскажите нам о себе';

  @override
  String get profileNameLabel => 'Ваше имя';

  @override
  String get profileNameHint => 'Иван Иванов';

  @override
  String get profileBirthDateLabel => 'Дата рождения';

  @override
  String get profileBirthDateHint => 'дд.мм.гггг';

  @override
  String get profileContinue => 'Продолжить';

  @override
  String get genderTitle => 'Укажите ваш пол';

  @override
  String get genderMale => 'Мужчина';

  @override
  String get genderFemale => 'Женщина';

  @override
  String get locationTitle => 'Где вы находитесь?';

  @override
  String get locationYourCity => 'Ваш город';

  @override
  String get locationSkip => 'Пропустить';

  @override
  String get locationSearch => 'Поиск';

  @override
  String get locationPick => 'Выбрать';

  @override
  String get homeTitle => 'Поиск соседей';

  @override
  String get homeAiSearchTooltip => 'AI-поиск';

  @override
  String get homeFilteredBanner =>
      'Показаны пользователи по выбранным фильтрам';

  @override
  String get homeNoUsersByFilters => 'По этим фильтрам пользователи не найдены';

  @override
  String get homeNoVisibleUsers => 'Пока нет видимых пользователей';

  @override
  String get homeUserHidden => 'Пользователь скрыт';

  @override
  String get homeSavedRemoved => 'Удалено из избранного';

  @override
  String get homeSavedAdded => 'Сохранено';

  @override
  String get homeVerified => 'Подтвержден';

  @override
  String homeCompatibility(int percent) {
    return 'Совместимо: $percent%';
  }

  @override
  String get locationLabel => 'Локация';

  @override
  String get statusLabel => 'Статус';

  @override
  String get budgetLabel => 'Бюджет';

  @override
  String get writeMessage => 'Написать';

  @override
  String get hide => 'Скрыть';

  @override
  String get saved => 'Сохранено';

  @override
  String get saveAction => 'Сохранить';

  @override
  String get homeStateProfileIncompleteTitle =>
      'Заполните профиль для лучших совпадений';

  @override
  String get homeStateProfileIncompleteSubtitle =>
      'Пользователи все равно показываются, но рекомендации станут точнее после завершения анкеты.';

  @override
  String get homeStateVerificationPendingTitle => 'Проверка еще идет';

  @override
  String get homeStateVerificationPendingSubtitle =>
      'Ваш профиль остается активным, пока модерация не завершена.';

  @override
  String get homeStateVerificationRejectedTitle => 'Проверка требует внимания';

  @override
  String get homeStateVerificationRejectedSubtitle =>
      'Обновите данные для верификации, чтобы вернуть значок доверия.';

  @override
  String get homeStateNoRecommendationsTitle => 'Пока нет сильных совпадений';

  @override
  String get homeStateNoRecommendationsSubtitle =>
      'Показываем более широкий список пользователей, пока собираются новые сигналы.';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesLoadError =>
      'Не удалось загрузить избранных пользователей';

  @override
  String get favoritesEmpty => 'Пока пусто';

  @override
  String get messagesTitle => 'Сообщения';

  @override
  String get search => 'Поиск';

  @override
  String get chatsLoadError => 'Не удалось загрузить чаты.';

  @override
  String get messagesEmpty => 'У вас пока нет сообщений';

  @override
  String get startConversation => 'Начните переписку';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileCompleted => 'Профиль заполнен на 100%';

  @override
  String get profileCompletedSubtitle =>
      'Теперь вас могут находить другие пользователи';

  @override
  String get profileContinueCompletion => 'Продолжить заполнение профиля';

  @override
  String get profileContinueCompletionSubtitle =>
      'Заполните профиль, чтобы получать больше совпадений';

  @override
  String get verificationStatusPending => 'На проверке';

  @override
  String get verificationStatusVerified => 'Подтвержден';

  @override
  String get verificationStatusRejected => 'Отклонено';

  @override
  String get verificationStatusNotSent => 'Не отправлено';

  @override
  String get verificationIdentityVerified => 'Личность подтверждена';

  @override
  String get verificationTrustSubtitle => 'Повышает доверие к вашему профилю';

  @override
  String get verificationPendingSubtitle =>
      'Ожидайте подтверждения от администратора';

  @override
  String get verificationConfirmIdentity => 'Подтвердить личность';

  @override
  String get paymentRemindersTitle => 'Напоминания об оплате';

  @override
  String get paymentRemindersEmpty => 'Сейчас у вас нет ожидающих оплат.';

  @override
  String paymentDueDate(Object date) {
    return 'Срок оплаты: $date';
  }

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get myAgreements => 'Мои договоры';

  @override
  String get myCards => 'Мои карты';

  @override
  String get myDisputes => 'Мои жалобы';

  @override
  String get userDisputes => 'Жалобы пользователей';

  @override
  String get notifications => 'Уведомления';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get security => 'Безопасность';

  @override
  String get support => 'Помощь и поддержка';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get logout => 'Выход';

  @override
  String get currentAdmin => 'Текущий admin';

  @override
  String settingsLanguageCurrent(Object title, Object value) {
    return '$title\n$value >';
  }

  @override
  String get disputesTitle => 'Мои жалобы';

  @override
  String get disputesLoading => 'Загрузка жалоб...';

  @override
  String get disputesLoadError => 'Не удалось загрузить жалобы.';

  @override
  String get disputesEmpty => 'У вас пока нет жалоб';

  @override
  String disputeCreatedAt(Object date) {
    return 'Создана: $date';
  }

  @override
  String disputeReviewedAt(Object date) {
    return 'Рассмотрена: $date';
  }

  @override
  String disputeAdminComment(Object comment) {
    return 'Комментарий модератора: $comment';
  }

  @override
  String get disputeDirectionOutgoing => 'Вы подали жалобу';

  @override
  String get disputeDirectionIncoming => 'На вас подали жалобу';

  @override
  String get disputeDirectionDefault => 'Жалоба';

  @override
  String disputeAgainstUser(Object name) {
    return 'На пользователя: $name';
  }

  @override
  String disputeFromUser(Object name) {
    return 'От пользователя: $name';
  }

  @override
  String get disputeNeedMoreInfo =>
      'Для рассмотрения жалобы требуется дополнительная информация.';

  @override
  String get disputeRejectedSummary =>
      'Жалоба отклонена. Нарушение не подтверждено.';

  @override
  String get disputeCreateTitle => 'Подать жалобу';

  @override
  String get disputeReason => 'Причина жалобы';

  @override
  String get titleLabel => 'Заголовок';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get evidenceLabel => 'Доказательства';

  @override
  String get evidenceHint => 'Ссылка на фото, видео или документ';

  @override
  String get addLink => 'Добавить ссылку';

  @override
  String get disputeModerationNotice =>
      'Жалоба будет рассмотрена модератором. Прикладывайте только реальные доказательства.';

  @override
  String get sendDispute => 'Отправить жалобу';

  @override
  String get sending => 'Отправляем...';

  @override
  String get disputeTitleRequired => 'Укажите заголовок жалобы.';

  @override
  String get disputeDescriptionRequired => 'Опишите проблему.';

  @override
  String get disputeDetailsTitle => 'Детали жалобы';

  @override
  String get participantsTitle => 'Участники';

  @override
  String get reporter => 'Заявитель';

  @override
  String get accused => 'Против кого';

  @override
  String get disputeDescriptionTitle => 'Описание жалобы';

  @override
  String get reviewResultTitle => 'Результат рассмотрения';

  @override
  String get reasonTitle => 'Причина';

  @override
  String get resultTitle => 'Результат';

  @override
  String get moderatorComment => 'Комментарий модератора';

  @override
  String get statusTitle => 'Статус';

  @override
  String get decisionTitle => 'Решение';

  @override
  String get actionTitle => 'Примененное действие';

  @override
  String get evidenceTitle => 'Доказательства';

  @override
  String get linkTitle => 'Ссылка';

  @override
  String get addInformation => 'Добавить информацию';

  @override
  String get addInformationSoon =>
      'Добавление дополнительной информации появится в следующем обновлении.';

  @override
  String get disputeStatusOpen => 'Открыта';

  @override
  String get disputeStatusInReview => 'На рассмотрении';

  @override
  String get disputeStatusResolved => 'Решена';

  @override
  String get disputeStatusRejected => 'Отклонена';

  @override
  String get disputeStatusClosed => 'Закрыта';

  @override
  String get disputeDecisionNone => 'Решение не принято';

  @override
  String get disputeDecisionAccepted => 'Жалоба подтверждена';

  @override
  String get disputeDecisionRejected => 'Жалоба отклонена';

  @override
  String get disputeDecisionNeedMoreInfo => 'Нужна дополнительная информация';

  @override
  String get disputeActionNone => 'Действие не применено';

  @override
  String get disputeActionWarning => 'Предупреждение';

  @override
  String get disputeActionTemporaryRestriction => 'Временное ограничение';

  @override
  String get disputeActionAccountBan => 'Блокировка аккаунта';

  @override
  String get disputeActionAgreementCancelled => 'Договор отменен';

  @override
  String get disputeActionPaymentRequired => 'Требуется оплата';

  @override
  String get disputeActionProfileFlagged => 'Профиль помечен';

  @override
  String get disputeReasonPaymentNotPaid => 'Не оплатил(а)';

  @override
  String get disputeReasonAgreementViolation => 'Нарушение договора';

  @override
  String get disputeReasonPropertyDamage => 'Порча имущества';

  @override
  String get disputeReasonFakeInformation => 'Ложная информация';

  @override
  String get disputeReasonRudeBehavior => 'Грубое поведение';

  @override
  String get disputeReasonSafetyConcern => 'Угроза безопасности';

  @override
  String get disputeReasonOther => 'Другое';

  @override
  String get aiSearchTitle => 'ИИ-поиск соседей';

  @override
  String get aiSearchPlaceholderTitle => 'Опишите идеального соседа';

  @override
  String get aiSearchPlaceholderSubtitle =>
      'Например: спокойный, не курит, любит чистоту и ищет жилье в центре.';

  @override
  String get aiSearchErrorTitle => 'Не удалось выполнить поиск';

  @override
  String get aiSearchErrorSubtitle => 'Попробуйте отправить запрос еще раз.';

  @override
  String get aiSearchEmptyTitle => 'Ничего не найдено';

  @override
  String get aiSearchEmptySubtitle =>
      'Попробуйте изменить формулировку запроса или сделать его короче.';

  @override
  String get aiSearchInputHint =>
      'Например: тихая соседка, не курит, любит порядок';

  @override
  String get aiSearchButton => 'Искать';

  @override
  String get aiSuggestionQuietNoPets => 'Спокойная соседка без животных';

  @override
  String get aiSuggestionNoSmokingQuiet =>
      'Сосед без курения и с тихим режимом';

  @override
  String get lifestyleTitle => 'Образ жизни';

  @override
  String get preferencesTitle => 'Предпочтения';

  @override
  String get profileButton => 'Профиль';

  @override
  String get noDetails => 'Нет деталей';

  @override
  String get cityNotSpecified => 'Город не указан';

  @override
  String get agreementsTitle => 'Мои договоры';

  @override
  String get agreementDetailsTitle => 'Детали договора';

  @override
  String get agreementEditTitle => 'Редактирование договора';

  @override
  String get agreementSaved => 'Договор сохранен.';

  @override
  String get agreementSentForConfirmation =>
      'Договор отправлен на подтверждение.';

  @override
  String get agreementCancelled => 'Договор отменен.';

  @override
  String get agreementFormLoadError => 'Не удалось открыть форму договора.';

  @override
  String get agreementPrimaryValidation =>
      'Добавьте хотя бы бюджет, город или правила совместного проживания.';

  @override
  String get agreementDisputeTermsRequired =>
      'Укажите порядок решения спорных ситуаций.';

  @override
  String get agreementHousingFound => 'Жилье уже найдено';

  @override
  String get agreementHousingFoundYes =>
      'Можно указать адрес и планируемую дату начала проживания.';

  @override
  String get agreementHousingFoundNo =>
      'Адрес и дата начала проживания пока не обязательны.';

  @override
  String get agreementInfoBanner =>
      'Это соглашение между будущими соседями. Квартира может быть уже найдена или вы можете искать жилье вместе.';

  @override
  String get agreementFieldCity => 'Город для совместного проживания';

  @override
  String get agreementFieldAddress => 'Адрес жилья';

  @override
  String get agreementFieldMoveInDate =>
      'Планируемая дата начала совместного проживания';

  @override
  String get agreementFieldMoveOutDate =>
      'Планируемая дата окончания проживания';

  @override
  String get agreementFieldMonthlyRent => 'Ориентир по ежемесячному бюджету';

  @override
  String get agreementFieldDeposit => 'Ориентир по депозиту';

  @override
  String get agreementFieldUtilitySplit => 'Как делить коммунальные платежи';

  @override
  String get agreementFieldFirstUserPercent => 'Процент первого участника';

  @override
  String get agreementFieldSecondUserPercent => 'Процент второго участника';

  @override
  String get agreementFieldHouseRules => 'Правила совместного проживания';

  @override
  String get agreementFieldGuestPolicy => 'Правила приглашения гостей';

  @override
  String get agreementFieldQuietHours => 'Время тишины';

  @override
  String get agreementFieldCleaningSchedule => 'График уборки';

  @override
  String get agreementFieldSmokingPolicy => 'Правила курения';

  @override
  String get agreementFieldPetPolicy => 'Домашние животные';

  @override
  String get agreementFieldNoticePeriod => 'Срок предварительного уведомления';

  @override
  String get agreementFieldDamageResponsibility =>
      'Ответственность за общее имущество';

  @override
  String get agreementFieldTerminationTerms =>
      'Порядок прекращения совместного проживания';

  @override
  String get agreementFieldDisputeTerms => 'Решение спорных ситуаций';

  @override
  String get agreementUtilityEqual => 'Поровну';

  @override
  String get agreementUtilityPercentage => 'В процентах';

  @override
  String get agreementUtilityCustom => 'Индивидуально';

  @override
  String get agreementStatusDraft => 'Черновик';

  @override
  String get agreementStatusWaitingSecondParty => 'Ожидает второго участника';

  @override
  String get agreementStatusPendingConfirmation => 'Ожидает подтверждения';

  @override
  String get agreementStatusActive => 'Активен';

  @override
  String get agreementStatusCancelled => 'Отменен';

  @override
  String get agreementStatusCompleted => 'Завершен';

  @override
  String get agreementStatusRejected => 'Отклонен';

  @override
  String get socialLoginGoogle => 'Войти через Google';

  @override
  String get socialLoginFacebook => 'Войти через Facebook';

  @override
  String get done => 'Готово';

  @override
  String get profileCompletedSearchCTA => 'Перейти к поиску';

  @override
  String get profileVerificationOptionalCTA =>
      'Подтвердить личность (необязательно)';

  @override
  String get profileVerificationTitle => 'Подтверждение личности';

  @override
  String get profileVerificationSubtitle =>
      'Подтвержденные пользователи вызывают больше доверия';

  @override
  String get profileVerificationBenefitBadge => 'Синяя галочка в профиле';

  @override
  String get profileVerificationBenefitPriority => 'Приоритет в рекомендациях';

  @override
  String get profileVerificationBenefitReplies => 'Больше откликов';

  @override
  String get profileVerificationUploadTitle => 'Загрузите свой документ';

  @override
  String get profileVerificationUploadSubtitle =>
      'Документ используется только для проверки и не отображается другим';

  @override
  String get profileVerificationUploadDocumentLabel =>
      'Загрузить фото документа';

  @override
  String get profileVerificationUploadSelfieTitle => 'Сделайте селфи';

  @override
  String get profileVerificationUploadSelfieLabel => 'Сделать селфи';

  @override
  String get profileVerificationChecklistTitle => 'Убедитесь, что:';

  @override
  String get profileVerificationChecklistClearPhoto => 'Фото четкое';

  @override
  String get profileVerificationChecklistNoGlare => 'Без бликов';

  @override
  String get profileVerificationChecklistAllEdges => 'Все края видны';

  @override
  String get profileVerificationSubmit => 'Отправить на проверку';

  @override
  String get profileVerificationSubmitting => 'Отправка...';

  @override
  String get profileVerificationSuccessTitle => 'Документы отправлены!';

  @override
  String get profileVerificationSuccessSubtitle =>
      'Мы проверим данные в течение 24 часов.';
}
