import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/route_config/route_config.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/l10n/app_localizations.dart';

class TravelTales extends StatelessWidget {
  const TravelTales({super.key});

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
                foregroundColor: Colors.white
              ),
            ),

            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all(Color(0xFF95B1CC)),
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
                iconColor: WidgetStateProperty.all(Color(0xFF95B1CC)),
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
                  foregroundColor: Colors.white
              ),
            ),

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
          ),

          initialRoute: AuthRouteName.loginScreen,
          onGenerateRoute: RouteConfig.generateRoute,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [const Locale('en'), const Locale('ne')],
          locale: const Locale('en'),
        );
      },
    );
  }
}
