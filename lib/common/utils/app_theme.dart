// Файл: lib/common/utils/app_theme.dart.
// Назначение: центральная настройка цветов, типографики, радиусов, палитр и общих декораций интерфейса.

import 'package:flutter/material.dart';

// Набор дополнительных цветов приложения, который хранится внутри ThemeData.
// Эти значения удобнее брать через AppTheme.colorsOf(context), чем напрямую
// из ColorScheme, потому что здесь есть бизнес-смыслы: доходы, расходы, счета.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Основной акцент: кнопки, активные вкладки, выбранные элементы.
  final Color primary;

  // Вторичный акцент: вспомогательные выделения и контрастные элементы.
  final Color secondary;

  // Семантический цвет доходов.
  final Color income;

  // Семантический цвет расходов и опасных действий.
  final Color expense;

  // Отдельный акцент для модуля "Счета".
  final Color accounts;

  // Фон всего экрана Scaffold.
  final Color background;

  // Основная поверхность карточек, диалогов и полей ввода.
  final Color surface;

  // Мягкая поверхность для snackBar, вторичных блоков и подсветок.
  final Color surfaceSoft;

  // Цвет границ, разделителей и outline-кнопок.
  final Color border;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.income,
    required this.expense,
    required this.accounts,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.border,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? income,
    Color? expense,
    Color? accounts,
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? border,
  }) {
    // copyWith нужен ThemeExtension для точечного переопределения цветов,
    // например при тестах или будущих пользовательских темах.
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      accounts: accounts ?? this.accounts,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      border: border ?? this.border,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    // lerp отвечает за плавную анимацию между светлой и темной темой.
    return AppColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      accounts: Color.lerp(accounts, other.accounts, t) ?? accounts,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t) ?? surfaceSoft,
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}

// Центральный файл темы. Если нужно изменить визуальный стиль приложения,
// начинать лучше отсюда: палитры ниже задают базовые цвета, а _buildTheme
// превращает их в готовые ThemeData для Material-компонентов.
class AppTheme {
  // Общие отступы и радиусы. Эти константы помогают держать одинаковую
  // геометрию на всех экранах без ручного подбора в каждом виджете.
  static const double pagePadding = 16;
  static const double sectionGap = 20;
  static const double itemGap = 12;
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;

  // Акцентная палитра светлой темы.
  // Порядок важен: индексы используются ниже в lightColors и графиках.
  // 0 - основной цвет, 1 - вторичный, 2 - доходы, 3 - расходы,
  // 4 - баланс, 5 - дополнительный зеленый, 6 - счета, 7 - желтый акцент.
  static const List<Color> lightAccentPalette = [
    Color(0xFFFF9140),
    Color(0xFF172CAF),
    Color(0xFF34CFBE),
    Color(0xFFFF9140),
    Color(0xFFF1C75B),
    Color(0xFF009E8E),
    Color(0xFF4B5ED7),
    Color(0xFFFFC940),
  ];

  // Акцентная палитра темной темы с теми же смысловыми индексами,
  // что и у lightAccentPalette.
  static const List<Color> darkAccentPalette = [
    Color(0xFFFFAE73),
    Color(0xFF4B5ED7),
    Color(0xFF5DCFC3),
    Color(0xFFFF9140),
    Color(0xFFF1C75B),
    Color(0xFF34CFBE),
    Color(0xFF707ED7),
    Color(0xFFFFD773),
  ];

  // Нейтральная палитра светлой темы:
  // 0 - фон экрана, 1 - карточки/поля, 2 - мягкая поверхность,
  // 3 - границы, 4 - fallback для неизвестных категорий.
  static const List<Color> lightNeutralPalette = [
    Color(0xFFFFF7EF),
    Color(0xFFFFFFFF),
    Color(0xFFFFF0DE),
    Color(0xFFFFD5AD),
    Color(0xFF90A4AE),
  ];

  // Нейтральная палитра темной темы с теми же смысловыми индексами.
  static const List<Color> darkNeutralPalette = [
    Color(0xFF12182E),
    Color(0xFF1A2140),
    Color(0xFF252F5B),
    Color(0xFF3F4B82),
    Color(0xFF90A4AE),
  ];

  // Семантические цвета светлой темы. Если нужно быстро поменять цвет
  // доходов/расходов/счетов во всем приложении, меняйте соответствующий индекс
  // в lightAccentPalette или привязку здесь.
  static final AppColors lightColors = AppColors(
    primary: lightAccentPalette[0],
    secondary: lightAccentPalette[1],
    income: lightAccentPalette[2],
    expense: lightAccentPalette[3],
    accounts: lightAccentPalette[6],
    background: lightNeutralPalette[0],
    surface: lightNeutralPalette[1],
    surfaceSoft: lightNeutralPalette[2],
    border: lightNeutralPalette[3],
  );

  // Семантические цвета темной темы. Должны повторять роли lightColors,
  // но с оттенками, которые читаются на темном фоне.
  static final AppColors darkColors = AppColors(
    primary: darkAccentPalette[0],
    secondary: darkAccentPalette[1],
    income: darkAccentPalette[2],
    expense: darkAccentPalette[3],
    accounts: darkAccentPalette[6],
    background: darkNeutralPalette[0],
    surface: darkNeutralPalette[1],
    surfaceSoft: darkNeutralPalette[2],
    border: darkNeutralPalette[3],
  );

  // Готовые ThemeData кешируются один раз, чтобы не пересобирать тему
  // на каждом build.
  static final ThemeData _lightTheme = _buildTheme(
    brightness: Brightness.light,
    colors: lightColors,
  );

  static final ThemeData _darkTheme = _buildTheme(
    brightness: Brightness.dark,
    colors: darkColors,
  );

  static ThemeData get lightTheme => _lightTheme;

  static ThemeData get darkTheme => _darkTheme;

  // Цвета для специализированных сценариев, которые не входят напрямую
  // в ColorScheme: акцент баланса и fallback для категории без цвета.
  static final Color lightBalanceAccent = lightAccentPalette[4];
  static final Color darkBalanceAccent = darkAccentPalette[4];
  static final Color unknownCategoryColor = lightNeutralPalette[4];

  // Старые геттеры оставлены для совместимости с экранами, которые еще
  // не переведены на AppTheme.colorsOf(context).
  static Color get primaryColor => lightColors.primary;
  static Color get incomeColor => lightColors.income;
  static Color get expenseColor => lightColors.expense;
  static Color get backgroundColor => lightColors.background;

  // Набор иконок, доступных при создании/редактировании категорий.
  // Добавлять новые иконки лучше в конец списка, чтобы не менять визуальный
  // порядок уже выбранных пользователем пресетов.
  static const List<IconData> categoryPresetIcons = [
    Icons.fastfood,
    Icons.local_cafe,
    Icons.shopping_cart,
    Icons.storefront,
    Icons.restaurant,
    Icons.lunch_dining,
    Icons.local_bar,
    Icons.cake,
    Icons.icecream,
    Icons.directions_bus,
    Icons.local_taxi,
    Icons.train,
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.flight,
    Icons.pedal_bike,
    Icons.movie,
    Icons.sports_esports,
    Icons.music_note,
    Icons.theaters,
    Icons.celebration,
    Icons.home,
    Icons.chair,
    Icons.lightbulb,
    Icons.water_drop,
    Icons.wifi,
    Icons.work,
    Icons.school,
    Icons.menu_book,
    Icons.computer,
    Icons.favorite,
    Icons.health_and_safety,
    Icons.local_hospital,
    Icons.medication,
    Icons.fitness_center,
    Icons.spa,
    Icons.payments,
    Icons.account_balance,
    Icons.savings,
    Icons.attach_money,
    Icons.credit_card,
    Icons.receipt_long,
    Icons.card_giftcard,
    Icons.redeem,
    Icons.pets,
    Icons.child_care,
    Icons.shopping_bag,
    Icons.checkroom,
    Icons.phone_android,
    Icons.devices,
    Icons.book_online,
    Icons.workspace_premium,
    Icons.brush_rounded,
    Icons.palette_outlined,
    Icons.auto_awesome,
    Icons.clean_hands_outlined,
    Icons.self_improvement,
    Icons.beach_access_rounded,
    Icons.park_outlined,
    Icons.landscape_rounded,
    Icons.liquor_rounded,
    Icons.ramen_dining_rounded,
    Icons.bakery_dining_rounded,
    Icons.set_meal_rounded,
    Icons.kebab_dining_rounded,
    Icons.dinner_dining_rounded,
    Icons.emoji_transportation_rounded,
    Icons.electric_bike_rounded,
    Icons.directions_subway_rounded,
    Icons.local_shipping_rounded,
    Icons.inventory_2_rounded,
    Icons.shopping_basket_rounded,
    Icons.sell_rounded,
    Icons.volunteer_activism_rounded,
    Icons.family_restroom_rounded,
    Icons.elderly_rounded,
    Icons.toys_rounded,
    Icons.rocket_launch_rounded,
    Icons.public_rounded,
    Icons.travel_explore_rounded,
    Icons.hotel_rounded,
    Icons.campaign_rounded,
    Icons.photo_camera_back_rounded,
    Icons.headphones_rounded,
    Icons.tv_rounded,
    Icons.sports_soccer_rounded,
    Icons.pool_rounded,
    Icons.roller_skating_rounded,
    Icons.psychology_alt_rounded,
    Icons.paid_rounded,
    Icons.currency_exchange_rounded,
    Icons.price_change_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.security_rounded,
    Icons.gpp_good_rounded,
    Icons.pets_rounded,
    Icons.eco_rounded,
    Icons.category,
  ];

  // Цветовые пресеты категорий для светлой темы. Они намеренно разнообразные,
  // чтобы список категорий не выглядел как одна однотонная палитра.
  static const List<Color> lightCategoryPresetColors = [
    Color(0xFFE7A28A),
    Color(0xFFE8BE63),
    Color(0xFFD8D46A),
    Color(0xFFB7D889),
    Color(0xFF95D6A4),
    Color(0xFF7FD2BE),
    Color(0xFF7CCFCE),
    Color(0xFF84C3E6),
    Color(0xFF93B4EC),
    Color(0xFFA6A6EE),
    Color(0xFFC0A0EA),
    Color(0xFFD6A2E8),
    Color(0xFFE7A6D2),
    Color(0xFFE7A6BA),
    Color(0xFFD8AF9B),
    Color(0xFFBFAE98),
    Color(0xFF9FB4B8),
    Color(0xFFA0C4B0),
  ];

  // Цветовые пресеты категорий для темной темы: чуть приглушены, чтобы
  // не слепить на темных поверхностях.
  static const List<Color> darkCategoryPresetColors = [
    Color(0xFFD38E7C),
    Color(0xFFD5B45A),
    Color(0xFFC4C05F),
    Color(0xFFA4BF7B),
    Color(0xFF87B990),
    Color(0xFF72B7A6),
    Color(0xFF67B5B8),
    Color(0xFF73A7CC),
    Color(0xFF8098D6),
    Color(0xFF938FDD),
    Color(0xFFAE8BDA),
    Color(0xFFC290D6),
    Color(0xFFD294C1),
    Color(0xFFD396AA),
    Color(0xFFC59D8C),
    Color(0xFFA79E8D),
    Color(0xFF8898A4),
    Color(0xFF86A898),
  ];

  // Палитра графиков светлой темы. Порядок влияет на первые категории
  // в диаграммах, поэтому самые различимые цвета стоят в начале.
  static final List<Color> lightAnalyticsChartPalette = [
    lightAccentPalette[0],
    lightAccentPalette[2],
    lightAccentPalette[1],
    lightAccentPalette[7],
    lightAccentPalette[3],
    lightAccentPalette[5],
    lightAccentPalette[6],
    lightBalanceAccent,
    Color(0xFF5DCFC3),
    Color(0xFFFFAE73),
  ];

  // Палитра графиков темной темы с контрастом под темные поверхности.
  static final List<Color> darkAnalyticsChartPalette = [
    darkAccentPalette[0],
    darkAccentPalette[5],
    darkAccentPalette[1],
    darkAccentPalette[7],
    Color(0xFFBF6D30),
    darkAccentPalette[2],
    darkAccentPalette[6],
    darkBalanceAccent,
    Color(0xFF009E8E),
    darkAccentPalette[0],
  ];

  // Собирает единую Material-тему из наших семантических цветов.
  // Большинство экранов должны опираться на Theme.of(context), а не задавать
  // цвета вручную: так переключение светлой/темной темы работает автоматически.
  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColors colors,
  }) {
    // ColorScheme нужен Material 3-компонентам. copyWith фиксирует ключевые
    // цвета, чтобы Flutter не вывел их только из seedColor.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: brightness,
        ).copyWith(
          primary: colors.primary,
          onPrimary: Colors.white,
          secondary: colors.secondary,
          onSecondary: const Color(0xFF0D2431),
          error: colors.expense,
          onError: const Color(0xFF3E2B00),
          surface: colors.surface,
          onSurface: brightness == Brightness.light
              ? const Color(0xFF2C241C)
              : const Color(0xFFF4F6FF),
        );

    // Базовая ThemeData дает стандартные размеры и состояния Material 3.
    // Ниже copyWith переопределяет только то, что нужно FinArt.
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      extensions: const [],
    );

    return base.copyWith(
      // ThemeExtension подключает AppColors к Theme.of(context).
      extensions: [colors],
      cardColor: colors.surface,
      canvasColor: colors.surface,
      dividerColor: colors.border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      // Типографика: здесь задаются только вес, высота строки и вторичный
      // цвет bodySmall. Размеры оставлены стандартными Material, чтобы текст
      // лучше адаптировался к системным настройкам.
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: brightness == Brightness.light
              ? const Color(0xFF72685D)
              : const Color(0xFFB8C0E8),
          height: 1.3,
        ),
      ),
      // Нижняя навигация и NavigationBar используют одни и те же акценты,
      // поэтому переключение вкладок выглядит одинаково во всех разделах.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.58),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.14,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return base.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected
                ? colors.primary
                : scheme.onSurface.withValues(alpha: 0.64),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colors.primary
                : scheme.onSurface.withValues(alpha: 0.68),
            size: 22,
          );
        }),
        elevation: 0,
        height: 76,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Карточки, диалоги и поля ввода используют общие радиусы из AppTheme,
      // чтобы интерфейс оставался визуально цельным.
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.primary,
        textColor: scheme.onSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceSoft,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      // Кнопки настроены централизованно: новые экраны получают тот же стиль,
      // если используют стандартные Elevated/Filled/OutlinedButton.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primary.withValues(alpha: 0.16);
            }
            return colors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primary;
            }
            return scheme.onSurface;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
        ),
      ),
    );
  }

  // Возвращает AppColors текущей темы. Это главный способ получить цвета
  // доходов, расходов, счетов, поверхностей и границ внутри UI.
  static AppColors colorsOf(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ??
      (Theme.of(context).brightness == Brightness.dark
          ? darkColors
          : lightColors);

  // Акцент баланса зависит от темы, чтобы одинаково хорошо читаться
  // на светлом и темном фоне.
  static Color balanceAccentOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBalanceAccent
      : lightBalanceAccent;

  // Цвета пресетов категорий подбираются отдельно для светлого и темного режима.
  static List<Color> categoryPresetColorsOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkCategoryPresetColors
      : lightCategoryPresetColors;

  // Палитра графиков также зависит от темы, иначе часть сегментов теряет
  // контраст на темном фоне.
  static List<Color> analyticsChartPaletteOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkAnalyticsChartPalette
      : lightAnalyticsChartPalette;

  // Подбирает черный или белый текст под произвольный цвет фона.
  // Используется для цветных категорий и бейджей.
  static Color getContrastText(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // Делает цвет полупрозрачным для мягких фонов, плашек и подсветок.
  static Color softenColor(Color color, [double opacity = 0.12]) {
    return color.withValues(alpha: opacity);
  }

  // Единый приглушенный цвет текста для вторичных подписей.
  static Color mutedTextOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: isDark ? 0.74 : 0.62);
  }

  // Ненавязчивая тень: в темной теме она немного плотнее, в светлой почти
  // незаметна, чтобы карточки не выглядели тяжелыми.
  static Color subtleShadowOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withValues(alpha: isDark ? 0.18 : 0.05);
  }

  // Стандартная декорация карточки на поверхности. Используйте ее для
  // обычных информационных блоков, чтобы не дублировать border/shadow/radius.
  static BoxDecoration surfaceCardDecoration(
    BuildContext context, {
    double radius = radiusLg,
    Color? color,
    Color? borderColor,
  }) {
    final colors = colorsOf(context);
    return BoxDecoration(
      color: color ?? colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? colors.border),
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          offset: const Offset(0, 8),
          color: subtleShadowOf(context),
        ),
      ],
    );
  }

  // Декорация карточки с цветным акцентом. Хорошо подходит для важных
  // состояний: счета, предупреждения, итоги, выделенные рекомендации.
  static BoxDecoration accentCardDecoration(
    BuildContext context, {
    required Color accent,
    double radius = radiusLg,
  }) {
    final colors = colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: accent.withValues(alpha: isDark ? 0.16 : 0.16),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        width: 1.5,
        color: accent.withValues(alpha: isDark ? 0.34 : 0.22),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          offset: const Offset(0, 8),
          color: subtleShadowOf(context),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: isDark ? 0.18 : 0.16),
          colors.surface,
        ],
      ),
    );
  }
}
