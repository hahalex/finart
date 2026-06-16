// Файл: lib/common/widgets/app_initializer.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/default_categories.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../providers/accounts_repository_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_service_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/planned_payment_service_provider.dart';
import '../providers/planned_repository_provider.dart';
import '../../features/profile/providers/user_provider.dart';
import 'main_navigation.dart';

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  late final Future<void> _initializationFuture;
  bool _showOnboarding = false;

  static const _onboardingCompletedKey = 'finart_onboarding_completed';

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _FinArtSplashScreen();
        }

        if (snapshot.hasError) {
          debugPrint('Ошибка при инициализации: ${snapshot.error}');
        }

        if (_showOnboarding) {
          return _FirstLaunchOnboarding(onComplete: _completeOnboarding);
        }

        return const MainNavigation();
      },
    );
  }

  Future<void> _initializeApp() async {
    await ref.read(localeProvider.notifier).loadLanguage();
    await _initAccounts();
    // Онбординг запускается до автозагрузки категорий, чтобы пользователь
    // мог отказаться от дефолтного набора на самом первом старте.
    final needsOnboarding = await _needsOnboarding();
    if (needsOnboarding) {
      _showOnboarding = true;
      return;
    }
    await _initCategories();
    await _finishStartup();
  }

  Future<bool> _needsOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingCompletedKey) ?? false;
    if (completed) return false;

    await ref.read(userProvider.notifier).loadUser();
    final user = ref.read(userProvider).valueOrNull;
    return user == null || user.name.trim().isEmpty;
  }

  Future<void> _finishStartup() async {
    await _processSavingsInterest();
    await _processPlannedPayments();
    await _initNotifications();
  }

  Future<void> _completeOnboarding({
    required String userName,
    required bool addDefaultCategories,
  }) async {
    await ref
        .read(userProvider.notifier)
        .updateProfile(name: userName.trim(), avatarPath: null);

    if (addDefaultCategories) {
      await _seedDefaultCategoriesIfNeeded();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    await _initCategories();
    await _finishStartup();

    if (!mounted) return;
    setState(() => _showOnboarding = false);
  }

  Future<void> _initAccounts() async {
    try {
      await ref.read(accountsRepositoryProvider).ensureMainAccount();
    } catch (error) {
      debugPrint('Ошибка инициализации счетов: $error');
    }
  }

  Future<void> _initCategories() async {
    try {
      final repo = ref.read(categoriesRepositoryProvider);
      final locale = ref.read(localeProvider);
      final hasCategories = await repo.hasCategories();

      if (hasCategories) {
        await repo.syncDefaultCategoryLocalizations(locale);
        await repo.normalizeCategoryColors(
          categoryIds: buildDefaultCategories(
            locale,
          ).map((item) => item.id).toSet(),
        );
      }
    } catch (error) {
      debugPrint('Ошибка инициализации категорий: $error');
    }
  }

  Future<void> _seedDefaultCategoriesIfNeeded() async {
    final repo = ref.read(categoriesRepositoryProvider);
    final hasCategories = await repo.hasCategories();
    if (hasCategories) return;

    final locale = ref.read(localeProvider);
    for (final category in buildDefaultCategories(locale)) {
      await repo.insertCategory(category);
    }

    ref.invalidate(allCategoriesProvider);
    ref.invalidate(expenseCategoriesProvider);
    ref.invalidate(incomeCategoriesProvider);
  }

  Future<void> _processSavingsInterest() async {
    try {
      await ref.read(accountsRepositoryProvider).accrueMonthlySavingsInterest();
    } catch (error) {
      debugPrint('Ошибка начисления процентов по накопительным счетам: $error');
    }
  }

  Future<void> _processPlannedPayments() async {
    try {
      await ref.read(plannedPaymentServiceProvider).processDuePayments();
    } catch (error, stack) {
      debugPrint('Ошибка в PlannedPaymentService: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _initNotifications() async {
    try {
      final service = ref.read(notificationServiceProvider);
      final settings = await service.loadSettings();
      final plannedPayments = await ref
          .read(plannedRepositoryProvider)
          .getAllPlannedPayments();
      final accounts = await ref
          .read(accountsRepositoryProvider)
          .getAllAccounts(includeArchived: true);

      ref.read(notificationSettingsProvider.notifier).setLoaded(settings);

      await service.syncAll(
        settings: settings,
        plannedPayments: plannedPayments
            .where((payment) => payment.isActive)
            .toList(),
        accounts: accounts,
      );
    } catch (error, stack) {
      debugPrint('Ошибка инициализации уведомлений: $error');
      debugPrintStack(stackTrace: stack);
    }
  }
}

class _FirstLaunchOnboarding extends StatefulWidget {
  const _FirstLaunchOnboarding({required this.onComplete});

  final Future<void> Function({
    required String userName,
    required bool addDefaultCategories,
  })
  onComplete;

  @override
  State<_FirstLaunchOnboarding> createState() => _FirstLaunchOnboardingState();
}

class _FirstLaunchOnboardingState extends State<_FirstLaunchOnboarding> {
  final TextEditingController _nameController = TextEditingController();
  bool _addDefaultCategories = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final canContinue = _nameController.text.trim().isNotEmpty && !_isSaving;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _GradientBankIcon()),
                  const SizedBox(height: 28),
                  Text(
                    // Заголовок первого запуска объясняет, что это начальная
                    // настройка, а не обычный экран профиля.
                    strings.isRu
                        ? 'Добро пожаловать в FinArt'
                        : 'Welcome to FinArt',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFFF9140),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    // Поле имени создает пользовательский профиль до входа
                    // в основной навигационный стек приложения.
                    controller: _nameController,
                    enabled: !_isSaving,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: strings.name,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    // Переключатель решает, будут ли созданы стандартные
                    // категории расходов и доходов.
                    value: _addDefaultCategories,
                    onChanged: _isSaving
                        ? null
                        : (value) =>
                              setState(() => _addDefaultCategories = value),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.isRu
                          ? 'Добавить дефолтный набор категорий'
                          : 'Add default category set',
                    ),
                    subtitle: Text(
                      strings.isRu
                          ? 'Если выключить, категории не будут загружены автоматически.'
                          : 'Turn this off to start without preloaded categories.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: canContinue ? _save : null,
                    icon: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(strings.isRu ? 'Продолжить' : 'Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.onComplete(
      userName: _nameController.text,
      addDefaultCategories: _addDefaultCategories,
    );
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

class _FinArtSplashScreen extends ConsumerWidget {
  const _FinArtSplashScreen();

  static const _topColor = Color(0xFFFF9140);
  static const _bottomColor = Color(0xFF34CFBE);
  static const _signatureColor = Color(0xFFF1C75B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagline = language == AppLanguage.russian
        ? 'Искусство финансов'
        : 'The Art of Finance';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12182E)
          : const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(child: _GradientBankIcon()),
              Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(0, -124),
                  child: const Text(
                    'FinArt',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _topColor,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(0, 112),
                  child: Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _bottomColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 8,
                child: Text(
                  'by hahalex',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _signatureColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBankIcon extends StatelessWidget {
  const _GradientBankIcon();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _FinArtSplashScreen._topColor,
          _FinArtSplashScreen._bottomColor,
        ],
      ).createShader(bounds),
      child: const Icon(
        Icons.account_balance_rounded,
        size: 132,
        color: Colors.white,
      ),
    );
  }
}
