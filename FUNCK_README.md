# FinArt Functional README

## 1. Overview

`FinArt` is a local-first Flutter app for personal finance tracking. It combines transaction entries, account management, recurring payments, categories, analytics, local notifications, backup/import, profile customization, developer demo data, and AI-assisted transaction categorization.

The app is built around these principles:

- business data is stored locally in SQLite through Drift;
- UI and async state are managed with Riverpod;
- profile, theme, language, notification settings, and first-launch flags use local preferences or app-local files;
- notifications are scheduled locally on the device;
- AI categorization prefers local learned mappings and uses remote providers only for unresolved text;
- backup/import uses a versioned JSON format with checksum and relationship validation.

## 2. Main User Flows

1. First launch: enter profile name and optionally seed default categories.
2. Create expense and income categories, including subcategories.
3. Add a transaction manually, choose its date, account, category, amount, and description.
4. Edit or delete main-account transactions from the Entries list.
5. View Entries by selected month while the summary cards show current main-account state.
6. Assign operations to secondary accounts so they appear in that account history instead of Entries.
7. Open account history, edit or delete account operations, and keep account balance consistent.
8. Add a transaction quickly from an account details page with that account preselected.
9. Manage main, credit, and savings accounts.
10. Link recurring payments to accounts as transfers.
11. Manage upcoming payments with one-time and recurring schedules.
12. Review charts, period analytics, category breakdowns, and transaction drill-downs.
13. Review reports and recommendations for selected periods.
14. Categorize batches of text transactions with local learning and AI fallback.
15. Configure local notifications.
16. Edit profile name/avatar, theme, and language.
17. Export/import a JSON backup.
18. Generate demo data or clear/reset data from the developer menu.

## 3. Technology Stack

- Flutter / Dart / Material 3
- Riverpod for state management
- Drift + SQLite for persistence
- SharedPreferences for lightweight settings
- `flutter_local_notifications` + `timezone` for notifications
- `fl_chart` for analytics visualization
- `file_picker`, `share_plus`, and `crypto` for backup/import
- `image_picker` and `image` for avatar processing
- `http` and provider-specific integrations for AI categorization
- `flutter_localizations` and `intl` for Russian/English localization

Current Drift schema version: `9`.

Main database tables:

- `CategoriesTable`
- `TransactionsTable`
- `UserTable`
- `PlannedPaymentsTable`
- `AiLearning`
- `AccountsTable`
- `AccountOperationsTable`

## 4. Architecture

The project uses a feature-based structure with shared common modules.

- `lib/common` contains database schema, models, repositories, providers, services, shared widgets, localization, utilities, theme, and default data.
- `lib/features` contains user-facing modules:
  - `transactions`
  - `accounts`
  - `analytics`
  - `categories`
  - `planned`
  - `profile`

Typical data flow:

1. A screen reads a Riverpod provider.
2. A provider reads a repository, service, or notifier.
3. Repositories read/write Drift tables.
4. Services coordinate cross-module side effects.
5. Providers are invalidated or notifiers update state.
6. UI rebuilds from fresh state.

Examples:

- Main transaction:
  `AddTransactionScreen -> TransactionsNotifier -> TransactionsRepository -> Drift -> account balance/provider refresh`

- Secondary account operation:
  `AddTransactionScreen -> TransactionsNotifier -> AccountsRepository.applyManualOperation -> AccountOperationsTable -> account balance update`

- Account history edit:
  `AccountDetailsScreen -> AccountsRepository.updateOperation/deleteOperation -> balance delta adjustment -> accounts/history providers invalidated`

- Report:
  `transactionsProvider -> analytics providers -> AnalyticsCalculator -> ReportsScreen`

- Import:
  `ProfileScreen -> DataTransferService -> JSON validation -> Drift transaction -> provider invalidation`

## 5. Startup Flow

Startup is coordinated by `lib/common/widgets/app_initializer.dart`.

1. Flutter bindings and `ProviderScope` are initialized.
2. `FinArtApp` wires theme, locale, and localization delegates.
3. The Flutter splash is displayed while app initialization runs.
4. First-launch onboarding collects the user name and default-category preference.
5. The main account is ensured.
6. Default categories are inserted only when appropriate.
7. Due planned payments and monthly savings interest are processed.
8. Notifications are synchronized.
9. `MainNavigation` opens the tab shell.

## 6. Screen Functional Description

### 6.1 Entries

File: `lib/features/transactions/transactions_screen.dart`

Purpose: show main-account entries for the selected month.

Features:

- month navigation and month picker;
- transactions filtered by selected month;
- transactions grouped by date headers;
- category and subcategory titles, including `Subcategory (Parent)` labels;
- empty state for months with no entries;
- quick navigation to Accounts and Upcoming Payments;
- summary card order: `Income -> Balance -> Expenses`.

Important summary behavior:

- the selected month affects the transaction list only;
- `Income` and `Expenses` summarize all main-account entries currently known to the entries provider;
- `Balance` uses the current main-account balance from `accountsProvider`, with a fallback to `income - expenses`;
- secondary account operations do not appear in Entries.

### 6.2 Add Transaction

File: `lib/features/transactions/add_transaction_screen.dart`

Purpose: create a transaction or account operation manually.

Features:

- expense/income toggle;
- amount input;
- account selector;
- date picker, defaulting to today;
- category picker with subcategory support;
- optional description;
- shortcuts to Upcoming Payments and AI Categorization;
- optional `initialAccountId` so another screen can preselect an account.

Validation:

- amount must be positive;
- category must be selected.

Data behavior:

- main-account transactions are inserted into `TransactionsTable` and appear in Entries;
- secondary-account transactions become account operations in `AccountOperationsTable`;
- selected transaction date is preserved for both main-account entries and secondary account history;
- after save, the app returns to the Entries tab.

### 6.3 Edit Transaction

File: `lib/features/transactions/edit_transaction_sheet.dart`

Purpose: edit an existing transaction from the Entries list.

Features:

- opened from transaction long-press;
- edit amount, account, date, category, and description;
- moving from main account to secondary account removes the entry from Entries and adds account history;
- moving back to main account returns the operation to Entries;
- balance deltas are applied when amount/account changes.

### 6.4 Accounts

File: `lib/features/accounts/accounts_screen.dart`

Purpose: manage accounts and account-related workflows.

Account types:

- `main`
- `credit`
- `savings`

Features:

- main account displayed separately;
- filter for secondary accounts: all, credit, savings;
- create, edit, and archive accounts;
- account cards with balance and configured parameters;
- quick actions for secondary accounts:
  - account info;
  - top up;
  - withdraw;
  - history;
  - attach recurring payment;
  - create recurring payment;
  - archive;
- long-press account card to edit;
- savings interest accrual support;
- credit fields for credit limit, annual rate, billing day, and payment day.

### 6.5 Account Details And History

File: `lib/features/accounts/accounts_screen.dart`

Purpose: show one account's details, linked recurring payments, and operation history.

Features:

- account card at the top;
- linked recurring payments list;
- unlink recurring payment from the account;
- account operation history:
  - top-up;
  - withdrawal;
  - auto-payment;
  - interest;
- floating `+` button opens `AddTransactionScreen` with the current account preselected;
- operation menu with:
  - edit;
  - delete.

Editable operation fields:

- type;
- amount;
- note/comment;
- date.

Balance behavior:

- editing an operation updates account balance by the difference between old and new operation delta;
- deleting an operation subtracts the original operation delta from account balance;
- operation history and account balance stay synchronized.

### 6.6 Categories

File: `lib/features/categories/categories_screen.dart`

Purpose: manage category hierarchy for expenses and income.

Features:

- expense/income mode switch;
- search by category, subcategory, or AI tag;
- create root category;
- edit category;
- add subcategory;
- archive category;
- delete custom category;
- convert subcategory to root category;
- reorder root categories and subcategories;
- category icon/color editing;
- AI tag field for categorization hints.

### 6.7 Upcoming Payments

File: `lib/features/planned/presentation/planned_list_screen.dart`

Purpose: manage scheduled payments and account-linked transfers.

Features:

- filters: all, active, completed;
- search;
- list grouped by date;
- create, edit, complete/deactivate, and delete planned payments;
- start date picker;
- category selection with expense/income switching;
- recurrence:
  - one-time;
  - daily;
  - weekly;
  - monthly;
  - yearly;
  - custom intervals;
  - selected weekdays.

Account-linked behavior:

- standard planned payments affect the main account;
- when opened from Accounts for a selected account, the form creates a transfer payment;
- transfer payments deduct from the main account and add an account operation to the linked account;
- relevant changes trigger notification resync.

### 6.8 Charts

File: `lib/features/analytics/charts_screen.dart`

Purpose: visualize transactions and category statistics.

Features:

- expense/income analytics mode;
- period mode: day, week, month;
- custom date range and reset;
- chart view: bar or area;
- category display mode:
  - all;
  - parent categories only;
  - subcategories only;
- top-10 pie chart;
- category list under chart;
- drill-down transaction details from chart/category interactions.

### 6.9 Reports

File: `lib/features/analytics/reports_screen.dart`

Purpose: show a compact financial report for a selected period.

Features:

- period selector:
  - year;
  - half-year;
  - quarter;
  - current month;
  - custom date range;
- summary card order: `Income -> Balance -> Expenses`;
- savings rate;
- top expense category;
- top 3 expense categories;
- recommendations.

Data behavior:

- report calculations are based on `reportTransactionsProvider`;
- expense rankings exclude income categories.

### 6.10 AI Categorization

File: `lib/features/transactions/ai_categorization_screen.dart`

Purpose: process multiple text transaction lines and save categorized transactions.

Features:

- multiline input, one operation per line;
- local learned dictionary lookup before remote AI;
- provider pipeline with fallback;
- editable result cards;
- edit description, amount, and category;
- category picker with subcategory support;
- remove item from batch;
- save all recognized transactions;
- update local AI dictionary after save;
- developer dictionary inspection.

AI pipeline:

1. Normalize input lines.
2. Check in-memory and persistent local mappings.
3. Send unresolved lines to remote providers.
4. Classify provider/network/parsing errors.
5. Parse provider JSON defensively.
6. Replace invalid categories with fallback categories.
7. Let the user correct results.
8. Save transactions and learn mappings.

### 6.11 Profile And Settings

File: `lib/features/profile/profile_screen.dart`

Purpose: profile, settings, and data utilities.

Features:

- user name and avatar display;
- edit profile name;
- choose/remove avatar;
- avatar processing/loading state;
- open category management;
- theme selection: system, light, dark;
- language selection: Russian, English;
- open notification settings;
- import JSON backup;
- export JSON backup;
- open developer menu.

### 6.12 Notifications

File: `lib/features/profile/notifications_screen.dart`

Purpose: configure local notifications.

Features:

- upcoming payment notifications;
- credit payment day notifications;
- credit debt closed notifications;
- custom daily reminder;
- reminder text;
- reminder time.

Settings are stored in local preferences and applied through `NotificationService.syncAll()`.

### 6.13 Developer Menu

File: `lib/features/profile/dev_menu_screen.dart`

Purpose: seed and reset data for development/demo use.

Features:

- small demo dataset;
- large demo dataset;
- skewed category dataset;
- many planned payments scenario;
- mixed scenario;
- clear database data;
- reset demo data;
- confirmation dialogs and busy state.

## 7. Core Modules

### 7.1 Accounts Module

Important files:

- `lib/common/models/account_model.dart`
- `lib/common/models/account_operation_model.dart`
- `lib/common/database/accounts_table.dart`
- `lib/common/database/account_operations_table.dart`
- `lib/common/repositories/accounts_repository.dart`
- `lib/common/providers/accounts_provider.dart`
- `lib/common/services/account_calculation_service.dart`
- `lib/features/accounts/accounts_screen.dart`

Responsibilities:

- ensure and synchronize the main account;
- manage credit and savings accounts;
- store top-ups, withdrawals, auto-payments, and interest operations;
- edit/delete account operations with balance delta correction;
- calculate summaries and account recommendations;
- integrate with transactions, planned payments, notifications, and backup/import.

### 7.2 Transactions Module

Important files:

- `lib/common/models/transaction_model.dart`
- `lib/common/repositories/transactions_repository.dart`
- `lib/features/transactions/providers/transactions_notifier.dart`
- `lib/features/transactions/transactions_screen.dart`
- `lib/features/transactions/add_transaction_screen.dart`
- `lib/features/transactions/edit_transaction_sheet.dart`

Responsibilities:

- create, edit, and delete regular entries;
- preserve user-selected transaction dates;
- keep main-account entries in Entries;
- route secondary-account operations to account history;
- apply account balance deltas;
- provide data for analytics and reports.

### 7.3 Categories Module

Important files:

- `lib/common/models/category_model.dart`
- `lib/common/data/default_categories.dart`
- `lib/common/repositories/categories_repository.dart`
- `lib/common/providers/categories_provider.dart`
- `lib/features/categories/categories_screen.dart`
- `lib/features/categories/category_form_dialog.dart`
- `lib/common/widgets/category_picker.dart`

Responsibilities:

- manage expense/income categories;
- maintain parent/subcategory hierarchy;
- archive/delete/reorder categories;
- provide category picker UI for entries, planned payments, and AI results.

### 7.4 Planned Payments Module

Important files:

- `lib/common/models/planned_payment_model.dart`
- `lib/common/repositories/planned_repository.dart`
- `lib/common/services/planned_payment_service.dart`
- `lib/common/utils/recurrence_rule.dart`
- `lib/features/planned/presentation/planned_list_screen.dart`
- `lib/features/planned/presentation/category_selection_screen.dart`

Responsibilities:

- store one-time and recurring future payments;
- process due payments on startup;
- integrate with main-account transactions;
- create linked account operations for transfer payments;
- trigger notification synchronization.

### 7.5 Analytics And Reports Module

Important files:

- `lib/features/analytics/providers/analytics_provider.dart`
- `lib/features/analytics/domain/analytics_calculator.dart`
- `lib/features/analytics/charts_screen.dart`
- `lib/features/analytics/reports_screen.dart`
- `lib/features/analytics/widgets/*`

Responsibilities:

- filter transactions by date ranges;
- calculate income, expenses, balance, savings rate, and recommendations;
- prepare chart points and category breakdowns;
- support drill-down views.

### 7.6 AI Module

Important files:

- `lib/common/services/ai_categorization_service.dart`
- `lib/common/services/ai_learning_service.dart`
- `lib/common/data/local/db/ai_learning_table.dart`
- `lib/common/data/local/dao/ai_learning_dao.dart`
- `lib/features/transactions/providers/ai_provider.dart`
- `lib/features/transactions/ai_categorization_screen.dart`

Responsibilities:

- classify raw transaction text;
- use learned local mappings;
- call remote providers when local matching is insufficient;
- fail over between providers;
- persist corrected mappings.

### 7.7 Backup/Import Module

Important file:

- `lib/common/services/data_transfer_service.dart`

Current backup version: `2`.

Backup includes:

- categories and subcategories;
- transactions;
- planned payments;
- AI learning dictionary;
- user profile;
- accounts;
- account operations.

Validation includes:

- version check;
- checksum check;
- duplicate ID checks;
- category references;
- transaction/category type consistency;
- account references;
- planned transfer/account consistency;
- account operation/account references.

Import runs inside a database transaction and is not partially applied on validation failure.

### 7.8 Notifications Module

Important files:

- `lib/common/models/notification_settings.dart`
- `lib/common/services/notification_service.dart`
- `lib/common/providers/notification_settings_provider.dart`
- `lib/features/profile/notifications_screen.dart`

Responsibilities:

- store notification preferences;
- schedule/cancel local notifications;
- sync planned payment reminders;
- sync credit payment/debt notifications;
- sync custom reminders.

### 7.9 Profile Module

Important files:

- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/providers/user_provider.dart`
- `lib/features/profile/data/user_repository.dart`
- `lib/common/services/avatar_service.dart`

Responsibilities:

- store user name;
- process and store avatar files;
- expose theme and language settings;
- provide import/export and developer menu entry points.

## 8. File Map

### Root

- `pubspec.yaml` - metadata, SDK constraints, dependencies.
- `analysis_options.yaml` - lint/static analysis configuration.
- `README.md` - general project/build documentation.
- `FUNCK_README.md` - functional overview.

### App Shell

- `lib/main.dart` - app bootstrap, `ProviderScope`, theme/locale wiring.
- `lib/common/widgets/app_initializer.dart` - splash, onboarding, startup sync.
- `lib/common/widgets/main_navigation.dart` - bottom navigation.
- `lib/common/providers/navigation_provider.dart` - selected tab provider.

### Database

- `lib/common/database/app_database.dart` - Drift database and migrations.
- `lib/common/database/app_database.g.dart` - generated Drift code.
- `lib/common/database/categories_table.dart`
- `lib/common/database/transactions_table.dart`
- `lib/common/database/planned_payments_table.dart`
- `lib/common/database/user_table.dart`
- `lib/common/database/accounts_table.dart`
- `lib/common/database/account_operations_table.dart`
- `lib/common/data/local/db/ai_learning_table.dart`
- `lib/common/data/local/dao/ai_learning_dao.dart`

### Shared Models

- `lib/common/models/account_model.dart`
- `lib/common/models/account_operation_model.dart`
- `lib/common/models/category_model.dart`
- `lib/common/models/transaction_model.dart`
- `lib/common/models/planned_payment_model.dart`
- `lib/common/models/notification_settings.dart`
- `lib/common/models/recommendation_model.dart`
- `lib/common/models/category_prediction.dart`

### Repositories

- `lib/common/repositories/accounts_repository.dart`
- `lib/common/repositories/categories_repository.dart`
- `lib/common/repositories/transactions_repository.dart`
- `lib/common/repositories/planned_repository.dart`
- `lib/common/repositories/test_planned_repository.dart`

### Providers

- `lib/common/providers/database_provider.dart`
- `lib/common/providers/accounts_provider.dart`
- `lib/common/providers/accounts_repository_provider.dart`
- `lib/common/providers/categories_provider.dart`
- `lib/common/providers/transactions_repository_provider.dart`
- `lib/common/providers/planned_repository_provider.dart`
- `lib/common/providers/planned_payments_provider.dart`
- `lib/common/providers/planned_payment_service_provider.dart`
- `lib/common/providers/notification_service_provider.dart`
- `lib/common/providers/notification_settings_provider.dart`
- `lib/common/providers/data_transfer_service_provider.dart`
- `lib/common/providers/avatar_service_provider.dart`
- `lib/common/providers/ai_learning_provider.dart`
- `lib/common/providers/selected_month_provider.dart`
- `lib/common/providers/theme_mode_provider.dart`
- `lib/common/providers/locale_provider.dart`

### Shared Widgets And Utilities

- `lib/common/widgets/summary_card.dart`
- `lib/common/widgets/transaction_tile.dart`
- `lib/common/widgets/date_header.dart`
- `lib/common/widgets/month_navigation.dart`
- `lib/common/widgets/month_picker_dialog.dart`
- `lib/common/widgets/category_picker.dart`
- `lib/common/widgets/category_tile.dart`
- `lib/common/widgets/category_icon.dart`
- `lib/common/utils/app_theme.dart`
- `lib/common/utils/date_grouping.dart`
- `lib/common/utils/recurrence_rule.dart`
- `lib/common/localization/app_strings.dart`
- `lib/common/localization/app_language.dart`
- `lib/common/data/default_categories.dart`

### Feature Files

- `lib/features/accounts/accounts_screen.dart`
- `lib/features/transactions/transactions_screen.dart`
- `lib/features/transactions/add_transaction_screen.dart`
- `lib/features/transactions/edit_transaction_sheet.dart`
- `lib/features/transactions/ai_categorization_screen.dart`
- `lib/features/transactions/providers/transactions_notifier.dart`
- `lib/features/transactions/providers/ai_provider.dart`
- `lib/features/analytics/charts_screen.dart`
- `lib/features/analytics/reports_screen.dart`
- `lib/features/analytics/providers/analytics_provider.dart`
- `lib/features/analytics/providers/category_expenses_provider.dart`
- `lib/features/analytics/domain/analytics_calculator.dart`
- `lib/features/analytics/domain/analytics_models.dart`
- `lib/features/categories/categories_screen.dart`
- `lib/features/categories/category_form_dialog.dart`
- `lib/features/planned/presentation/planned_list_screen.dart`
- `lib/features/planned/presentation/category_selection_screen.dart`
- `lib/features/planned/providers/planned_ui_providers.dart`
- `lib/features/planned/widgets/planned_tile.dart`
- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/notifications_screen.dart`
- `lib/features/profile/dev_menu_screen.dart`
- `lib/features/profile/dev_data_service.dart`
- `lib/features/profile/providers/user_provider.dart`
- `lib/features/profile/data/user_repository.dart`
- `lib/features/profile/domain/user_model.dart`

### Services

- `lib/common/services/account_calculation_service.dart`
- `lib/common/services/ai_categorization_service.dart`
- `lib/common/services/ai_learning_service.dart`
- `lib/common/services/avatar_service.dart`
- `lib/common/services/data_transfer_service.dart`
- `lib/common/services/notification_service.dart`
- `lib/common/services/planned_payment_service.dart`

## 9. Current Feature Inventory

Implemented business features:

- first-launch onboarding;
- local transaction accounting;
- selectable transaction date on create/edit;
- current main-account summary on Entries;
- summary card order `Income -> Balance -> Expenses` on Entries and Reports;
- main, credit, and savings accounts;
- editable/deletable account operation history;
- account details `+` shortcut to preselected Add Transaction;
- account-linked recurring payments/transfers;
- monthly savings interest accrual;
- credit account payment/debt notifications;
- hierarchical expense/income categories;
- monthly entries dashboard;
- analytics charts with period/category filters;
- reports and recommendations;
- upcoming payments with recurrence rules;
- local notifications;
- profile editing with avatar support;
- system/light/dark themes;
- Russian/English localization;
- JSON v2 backup/import;
- backup checksum and relationship validation;
- AI categorization with local learning and provider failover;
- developer seed/reset scenarios.

Implemented technical capabilities:

- Drift migrations through schema version `9`;
- Riverpod state management;
- transactional backup import;
- provider invalidation after cross-module writes;
- local avatar files with cache-safe filenames;
- notification resync after relevant data changes;
- recurrence rule engine;
- account balance delta correction for account operation edits/deletes;
- AI provider failover and error classification;
- module smoke tests and focused service/model tests.

## 10. Maintenance Notes

Keep these areas synchronized when changing the app:

1. Add new user-facing text to `app_strings.dart`.
2. Add new persisted data to Drift schema, backup export, backup import, and validation.
3. Update schema version and migration when changing tables.
4. Generated files such as `app_database.g.dart` should be changed through generation.
5. Planned payment changes should consider `NotificationService.syncAll()`.
6. Account changes should consider transactions, planned payments, account operations, backup/import, and notifications.
7. Account operation edits/deletes must update account balance by delta, not by overwriting blindly.
8. Main-account and secondary-account flows differ: main entries go to `TransactionsTable`, secondary account operations go to `AccountOperationsTable`.
9. Built-in category changes should consider both Russian and English defaults.
10. AI dictionary changes should be included in backup/import if they must be portable.
11. Manual Dart files in `lib` use Russian header comments.
12. UI changes should use `AppTheme`, shared widgets, and existing spacing/radius conventions.

## 11. Recommended Reading Path

For a new developer, read in this order:

1. `pubspec.yaml`
2. `lib/main.dart`
3. `lib/common/widgets/app_initializer.dart`
4. `lib/common/widgets/main_navigation.dart`
5. `lib/common/database/app_database.dart`
6. `lib/common/utils/app_theme.dart`
7. `lib/common/providers/*`
8. `lib/common/repositories/accounts_repository.dart`
9. `lib/features/accounts/accounts_screen.dart`
10. `lib/features/transactions/transactions_screen.dart`
11. `lib/features/transactions/add_transaction_screen.dart`
12. `lib/features/transactions/edit_transaction_sheet.dart`
13. `lib/features/planned/presentation/planned_list_screen.dart`
14. `lib/features/analytics/charts_screen.dart`
15. `lib/features/analytics/reports_screen.dart`
16. `lib/features/profile/profile_screen.dart`
17. `lib/common/services/*`

This gives the fastest overview of startup, navigation, persistence, account integration, transaction flow, planned payments, analytics, AI categorization, backup/import, and notifications.
