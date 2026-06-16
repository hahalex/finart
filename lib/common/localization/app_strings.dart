// Файл: lib/common/localization/app_strings.dart.
// Назначение: хранит языковые настройки и строки интерфейса для русского и английского языков.

import 'package:flutter/material.dart';

import 'app_language.dart';

class AppStrings {
  AppStrings._(this._language);

  final AppLanguage _language;

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(AppLanguage.fromCode(locale.languageCode));
  }

  bool get isRu => _language == AppLanguage.russian;

  String get appTitle => 'FinArt';
  String get entries => isRu ? 'Записи' : 'Entries';
  String get accounts => isRu ? 'Счета' : 'Accounts';
  String get accountsComingSoon =>
      isRu ? 'Добавьте первый счет' : 'Add your first account';
  String get accountsPlaceholderDescription => isRu
      ? 'Здесь будет список кошельков, карт и наличных счетов.'
      : 'Wallets, cards, and cash accounts will be shown here.';
  String get addAccount => isRu ? 'Добавить счет' : 'Add account';
  String get editAccount => isRu ? 'Редактировать счет' : 'Edit account';
  String get accountName => isRu ? 'Название счета' : 'Account name';
  String get accountType => isRu ? 'Тип счета' : 'Account type';
  String get balance => isRu ? 'Баланс' : 'Balance';
  String get creditLimit => isRu ? 'Кредитный лимит' : 'Credit limit';
  String get interestRate => isRu ? 'Годовая ставка' : 'Annual rate';
  String get interestRateShort => isRu ? 'Ставка' : 'Rate';
  String get billingDay => isRu ? 'День выписки' : 'Billing day';
  String get paymentDay => isRu ? 'День платежа' : 'Payment day';
  String get paymentDayShort => isRu ? 'Платеж' : 'Payment';
  String get archiveAccount => isRu ? 'Архивировать счет?' : 'Archive account?';
  String get archive => isRu ? 'Архивировать' : 'Archive';
  String get allAccounts => isRu ? 'Все' : 'All';
  String get creditAccounts => isRu ? 'Кредитные' : 'Credit';
  String get savingsAccounts => isRu ? 'Накопительные' : 'Savings';
  String get attachRecurringPayment =>
      isRu ? 'Прикрепить регулярный платеж' : 'Attach recurring payment';
  String get createRecurringPayment =>
      isRu ? 'Создать регулярный платеж' : 'Create recurring payment';
  String get chooseActivePlannedPayment => isRu
      ? 'Выберите активный предстоящий платеж'
      : 'Choose an active upcoming payment';
  String get noActivePlannedPayments => isRu
      ? 'Нет активных предстоящих платежей'
      : 'No active upcoming payments';
  String get linkedPaymentSaved =>
      isRu ? 'Платеж привязан к счету' : 'Payment linked to account';
  String get topUp => isRu ? 'Пополнить' : 'Top up';
  String get withdraw => isRu ? 'Снять' : 'Withdraw';
  String get history => isRu ? 'История' : 'History';
  String get amount => isRu ? 'Сумма' : 'Amount';
  String get note => isRu ? 'Комментарий' : 'Note';
  String get linkedRecurringPayments =>
      isRu ? 'Привязанные регулярные платежи' : 'Linked recurring payments';
  String get accountOperations =>
      isRu ? 'Операции по счету' : 'Account operations';
  String get mainAccountDescription => isRu
      ? 'Основной счет используется приложением по умолчанию для текущих операций.'
      : 'The main account is used by default for current app operations.';
  String get charts => isRu ? 'Графики' : 'Charts';
  String get add => isRu ? 'Добавить' : 'Add';
  String get reports => isRu ? 'Отчёты' : 'Reports';
  String get profile => isRu ? 'Профиль' : 'Profile';
  String get profileFallbackName =>
      isRu ? 'Пользователь FinArt' : 'FinArt User';

  String get lightTheme => isRu ? 'Светлая' : 'Light';
  String get darkTheme => isRu ? 'Тёмная' : 'Dark';
  String get systemTheme => isRu ? 'Системная' : 'System';
  String get chooseTheme => isRu ? 'Выбор темы' : 'Choose theme';
  String get themes => isRu ? 'Темы' : 'Themes';

  String get language => isRu ? 'Язык' : 'Language';
  String get chooseLanguage => isRu ? 'Выбор языка' : 'Choose language';
  String get russian => isRu ? 'Русский' : 'Russian';
  String get english => isRu ? 'Английский' : 'English';

  String get editProfile => isRu ? 'Изменить профиль' : 'Edit profile';
  String get name => isRu ? 'Имя' : 'Name';
  String get avatar => isRu ? 'Аватар' : 'Avatar';
  String get chooseAvatar => isRu ? 'Выбрать аватар' : 'Choose avatar';
  String get removeAvatar => isRu ? 'Удалить аватар' : 'Remove avatar';

  String get categories => isRu ? 'Категории' : 'Categories';
  String get notifications => isRu ? 'Уведомления' : 'Notifications';
  String get uploadData => isRu ? 'Загрузить данные' : 'Import data';
  String get backup => isRu ? 'Бэкап' : 'Backup';

  String get save => isRu ? 'Сохранить' : 'Save';
  String get cancel => isRu ? 'Отмена' : 'Cancel';
  String get close => isRu ? 'Закрыть' : 'Close';

  String get importSuccess =>
      isRu ? 'Данные успешно загружены' : 'Data imported successfully';
  String get exportSuccess =>
      isRu ? 'Файл бэкапа подготовлен' : 'Backup file is ready';
  String get importFailed =>
      isRu ? 'Не удалось загрузить данные' : 'Failed to import data';
  String get exportFailed =>
      isRu ? 'Не удалось выгрузить данные' : 'Failed to export data';

  String get upcomingPayments =>
      isRu ? 'Предстоящие платежи' : 'Upcoming payments';
  String get upcomingPaymentsDescription => isRu
      ? 'Уведомлять о ближайших запланированных платежах'
      : 'Notify about upcoming planned payments';
  String get plannedPaymentsNotificationsInfo => isRu
      ? 'Для активных плановых платежей будут создаваться локальные уведомления.'
      : 'Local notifications will be created for active planned payments.';

  String get reminder => isRu ? 'Напоминание' : 'Reminder';
  String get reminderDescription => isRu
      ? 'Ежедневное уведомление с вашим текстом в выбранное время'
      : 'Daily notification with your text at the selected time';
  String get reminderText => isRu ? 'Текст напоминания' : 'Reminder text';
  String get reminderHint => isRu
      ? 'Например: проверьте бюджет и запишите траты'
      : 'For example: Review your budget and record expenses';
  String get reminderDefaultText => isRu
      ? 'Проверьте финансы и внесите важные операции'
      : 'Review your finances and add important transactions';
  String get reminderTime => isRu ? 'Время напоминания' : 'Reminder time';

  String get top10Categories => isRu ? 'Топ 10 категорий' : 'Top 10 categories';
  String get noData => isRu ? 'Нет данных' : 'No data';

  String get createCategory => isRu ? 'Создать категорию' : 'Create category';
  String get newCategory => isRu ? 'Новая категория' : 'New category';
  String get editCategory => isRu ? 'Редактировать' : 'Edit';
  String get icon => isRu ? 'Иконка' : 'Icon';
  String get color => isRu ? 'Цвет' : 'Color';
  String get subcategory => isRu ? 'Подкатегория' : 'Subcategory';
  String get parentCategory =>
      isRu ? 'Родительская категория *' : 'Parent category *';
  String get categoryNameRequired =>
      isRu ? 'Введите название категории' : 'Enter category name';
  String get chooseParentCategory =>
      isRu ? 'Выберите родительскую категорию' : 'Choose a parent category';
  String get aiTagOptional =>
      isRu ? 'AI-тег (опционально)' : 'AI tag (optional)';
  String get createRootCategoryFirst => isRu
      ? 'Сначала создайте корневую категорию'
      : 'Create a root category first';

  String get devMenu => 'Dev Menu';
  String get devMenuSubtitle => isRu
      ? 'Тестовые сценарии очистки и наполнения данных'
      : 'Testing scenarios for clearing and seeding data';
  String get devMenuDescription => isRu
      ? 'Сценарии для проверки списков, аналитики, отчётов и плановых платежей.'
      : 'Use this menu to run database seeding scenarios for lists, analytics, reports, and planned payments.';
  String get devMenuSeedSection =>
      isRu ? 'Сценарии наполнения' : 'Seed scenarios';
  String get devMenuDangerSection => isRu ? 'Опасная зона' : 'Danger zone';
  String get devMenuRunAction => isRu ? 'Запустить' : 'Run';

  String get devScenarioSmallSet => isRu ? 'Маленький набор' : 'Small data set';
  String get devScenarioSmallSetSubtitle => isRu
      ? 'Небольшое число транзакций для быстрой проверки'
      : 'A small number of transactions for quick manual testing';
  String get devScenarioLargeSet => isRu ? 'Большой набор' : 'Large data set';
  String get devScenarioLargeSetSubtitle => isRu
      ? 'Много операций за длительный период для стресс-теста UI'
      : 'Many transactions across a long period for UI stress testing';
  String get devScenarioSkewed =>
      isRu ? 'Перекос по категориям' : 'Skewed categories';
  String get devScenarioSkewedSubtitle => isRu
      ? 'Большая доля операций в нескольких категориях'
      : 'A heavy concentration of transactions in a few categories';
  String get devScenarioPlanned =>
      isRu ? 'Много плановых платежей' : 'Many planned payments';
  String get devScenarioPlannedSubtitle => isRu
      ? 'Проверка повторяющихся и активных платежей'
      : 'Scenario for testing recurring and active planned payments';
  String get devScenarioMixed => isRu ? 'Смешанный набор' : 'Mixed scenario';
  String get devScenarioMixedSubtitle => isRu
      ? 'Комбинация транзакций, подкатегорий и плановых платежей'
      : 'A mix of transactions, subcategories, and planned payments';
  String get devScenarioMiniForecast =>
      isRu ? 'Мини: прогноз месяца' : 'Mini: month forecast';
  String get devScenarioMiniForecastSubtitle => isRu
      ? 'Небольшой набор, который должен показать прогноз расходов выше нормы'
      : 'Small set that should trigger an above-norm monthly expense forecast';
  String get devScenarioMiniRecurring =>
      isRu ? 'Мини: регулярные расходы' : 'Mini: recurring expenses';
  String get devScenarioMiniRecurringSubtitle => isRu
      ? 'Несколько повторяющихся платежей для проверки подписок и регулярности'
      : 'Repeated payments for testing subscription and recurrence detection';
  String get devScenarioMiniTrend =>
      isRu ? 'Мини: растущая категория' : 'Mini: growing category';
  String get devScenarioMiniTrendSubtitle => isRu
      ? 'Три месяца роста одной категории для проверки тренда'
      : 'Three rising months in one category for trend detection';
  String get devScenarioMiniLargeTransaction =>
      isRu ? 'Мини: крупная операция' : 'Mini: large transaction';
  String get devScenarioMiniLargeTransactionSubtitle => isRu
      ? 'История обычных покупок и одна аномально крупная трата'
      : 'Normal purchase history plus one unusually large expense';
  String get devScenarioMiniConcentration =>
      isRu ? 'Мини: концентрация расходов' : 'Mini: spending concentration';
  String get devScenarioMiniConcentrationSubtitle => isRu
      ? 'Топ-3 категории занимают почти весь расход текущего периода'
      : 'Top 3 categories take almost all spending in the current period';
  String get devScenarioMiniHistory =>
      isRu ? 'Мини: анализ истории' : 'Mini: history analyzer';
  String get devScenarioMiniHistorySubtitle => isRu
      ? 'Проверяет сравнение периодов, падение доходов и расход выше личной нормы'
      : 'Tests period comparison, income drop, and spending above personal norm';

  String get devActionClearDatabase =>
      isRu ? 'Очистить базу данных' : 'Clear database';
  String get devActionClearDatabaseSubtitle => isRu
      ? 'Удалить транзакции, плановые платежи и тестовые данные'
      : 'Remove transactions, planned payments, and test data';
  String get devActionResetDemoData =>
      isRu ? 'Сбросить demo-данные' : 'Reset demo data';
  String get devActionResetDemoDataSubtitle => isRu
      ? 'Подготовить базу к следующему сценарию'
      : 'Prepare the database for the next test scenario';
  String get devActionStubMessage => isRu
      ? 'Интерфейс-заглушка для будущих генераторов данных.'
      : 'This is a placeholder UI for now.';
  String get devDangerStubMessage => isRu
      ? 'Здесь будет подтверждение перед очисткой или сбросом данных.'
      : 'This is where confirmation for clearing or resetting data will live.';
  String get devActionNotImplemented =>
      isRu ? 'Сценарий пока не подключён' : 'Scenario is not connected yet';
  String get devActionSeedConfirm => isRu
      ? 'Будут добавлены тестовые транзакции и плановые платежи поверх текущих данных.'
      : 'Test transactions and planned payments will be added on top of the current data.';
  String get devActionClearConfirm => isRu
      ? 'Будут удалены все транзакции, плановые платежи и обученный AI-словарь. Категории останутся.'
      : 'All transactions, planned payments, and the learned AI dictionary will be deleted. Categories will stay.';
  String get devActionResetConfirm => isRu
      ? 'Текущие транзакции и плановые платежи будут очищены, затем загрузится demo-набор.'
      : 'Current transactions and planned payments will be cleared, then a small demo set will be loaded.';
  String devSeedCompleted(
    int transactions,
    int plannedPayments, [
    int accounts = 0,
  ]) => isRu
      ? 'Готово: $transactions транзакций, $plannedPayments плановых платежей, $accounts счетов'
      : 'Done: $transactions transactions, $plannedPayments planned payments, $accounts accounts';
  String get devClearCompleted =>
      isRu ? 'Тестовые данные очищены' : 'Test data has been cleared';
}
