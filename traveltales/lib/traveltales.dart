import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traveltales/core/route_config/route_config.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/l10n/app_localizations.dart';

class TravelTales extends StatefulWidget {
  const TravelTales({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_TravelTalesState>();
    state?._setLocale(locale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_TravelTalesState>();
    state?._setThemeMode(mode);
  }

  @override
  State<TravelTales> createState() => _TravelTalesState();
}

class _TravelTalesState extends State<TravelTales> {
  final _storage = const FlutterSecureStorage();
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final saved = await _storage.read(key: "app_theme_mode");
    if (saved == "light") setState(() => _themeMode = ThemeMode.light);
    if (saved == "dark") setState(() => _themeMode = ThemeMode.dark);
    if (saved == "system" || saved == null)
      setState(() => _themeMode = ThemeMode.system);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);

    final value = switch (mode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "system",
    };
    await _storage.write(key: "app_theme_mode", value: value);
  }

  Future<void> _loadSavedLocale() async {
    final code = await _storage.read(key: "app_language");
    if (code != null && (code == "en" || code == "ne")) {
      setState(() => _locale = Locale(code));
    }
  }

  Future<void> _setLocale(Locale locale) async {
    setState(() => _locale = locale);
    await _storage.write(key: "app_language", value: locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Travel Tales',

          locale: _locale,

          themeMode: _themeMode,
          // themeMode: ,
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Color(0xFFF7FCFF),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A6FF),
              onPrimary: Colors.white,
              secondary: Color(0xFF0A2A4A),
              onSecondary: Colors.white,
              surface: Color(0xFF00A6FF),
              onSurface: Color(0xFF95B1CC),
              brightness: Brightness.light,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                foregroundColor: Colors.white,
              ),
            ),

            dividerTheme: DividerThemeData(color: Colors.grey[200]),

            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all(Color(0xFF0A2A4A)),
              ),
            ),

            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF0A2A4A)),
              bodyMedium: TextStyle(color: Color(0xFF0A2A4A)),
              bodySmall: TextStyle(color: Color(0xFF95B1CC)),

              titleLarge: TextStyle(color: Color(0xFF0A2A4A)),
              titleMedium: TextStyle(color: Color(0xFF0A2A4A)),
              titleSmall: TextStyle(color: Color(0xFF95B1CC)),
            ),

            // iconTheme: const IconThemeData(
            //   color: Color(0xFF95B1CC),
            // ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF7FCFF),
              titleTextStyle: TextStyle(fontSize: 16, color: Color(0xFF0A2A4A)),
            ),

            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
              elevation: 3,
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFFE9FCFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(
                color: Color(0xFF95B1CC),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Color(0xFFE9FCFF),
              contentTextStyle: TextStyle(
                color: Color(0xFF0A2A4A),
                fontSize: 14.sp,
              ),
              behavior: SnackBarBehavior.floating,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Color(0xFFEDF0F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              titleTextStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A2A4A),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Color(0xFFEDF0F7),

              headerBackgroundColor: Color(0xFF00A6FF),
              headerForegroundColor: Colors.white,

              dayForegroundColor: WidgetStateProperty.all(Color(0xFF0A2A4A)),

              todayForegroundColor: WidgetStateProperty.all(Color(0xFF00A6FF)),

              todayBackgroundColor: WidgetStateProperty.all(Color(0x3300A6FF)),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xFFEDF0F7),


              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Color(0xFF0A2A4A),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00A6FF),
              onPrimary: Colors.white,
              secondary: Color(0xFF0A2A4A),
              onSecondary: Colors.white,
              surface: Color(0xFF00A6FF),
              onSurface: Color(0xFF95B1CC),
              brightness: Brightness.dark,
            ),

            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all(Color(0xFFF7FCFF)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                foregroundColor: Colors.white,
              ),
            ),

            dividerTheme: DividerThemeData(color: Color(0xFF184A6A)),

            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFF7FCFF)),
              bodyMedium: TextStyle(color: Color(0xFFF7FCFF)),
              bodySmall: TextStyle(color: Color(0xFF95B1CC)),

              titleLarge: TextStyle(color: Color(0xFFF7FCFF)),
              titleMedium: TextStyle(color: Color(0xFFF7FCFF)),
              titleSmall: TextStyle(color: Color(0xFF95B1CC)),
            ),

            // iconTheme: const IconThemeData(
            //   color: Color(0xFF95B1CC),
            // ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF0A2A4A),
              titleTextStyle: TextStyle(fontSize: 16, color: Color(0xFF95B1CC)),
            ),

            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.transparent,
              elevation: 3,
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFF0A2A4A),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              hintStyle: TextStyle(
                color: Color(0xFF95B1CC),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),

            dialogTheme: DialogThemeData(
              backgroundColor: Color(0xFF0C3047),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              titleTextStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF7FCFF),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Color(0xFFEDF0F7),

              headerBackgroundColor: Color(0xFF00A6FF),
              headerForegroundColor: Colors.white,

              dayForegroundColor: WidgetStateProperty.all(Color(0xFF0A2A4A)),

              todayForegroundColor: WidgetStateProperty.all(Color(0xFF00A6FF)),

              todayBackgroundColor: WidgetStateProperty.all(Color(0x3300A6FF)),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xFFEDF0F7),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          initialRoute: AuthRouteName.loginScreen,
          // initialRoute: RouteName.adminDashboardScreen,
          onGenerateRoute: RouteConfig.generateRoute,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [const Locale('en'), const Locale('ne')],
        );
      },
    );
  }
}
