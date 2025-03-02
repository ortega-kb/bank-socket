import 'package:client/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Constantes
  static final _fontFamily = '';
  static const _useMaterial3 = true;
  static const _pageTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // Styles réutilisables
  static WidgetStateProperty<IconThemeData?> iconTheme(Color color) =>
      WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected)
                ? IconThemeData(color: color)
                : null,
      );

  static WidgetStateProperty<TextStyle?> labelTextStyle(Color color) =>
      WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected)
                ? TextStyle(color: color)
                : null,
      );

  // Thème pour la Navigation Bar
  static NavigationBarThemeData navigationBarTheme(
    Color color,
    Color background,
  ) => NavigationBarThemeData(
    elevation: 2,
    backgroundColor: background,
    surfaceTintColor: background,
    indicatorColor: Colors.transparent,
    iconTheme: iconTheme(color),
    labelTextStyle: labelTextStyle(color),
  );

  // Thème pour la Navigation Rail
  static NavigationRailThemeData navigationRailTheme(
    Color color,
    Color background,
  ) => NavigationRailThemeData(
    elevation: 2,
    backgroundColor: background,
    useIndicator: false,
    selectedIconTheme: IconThemeData(color: color),
    selectedLabelTextStyle: TextStyle(color: color),
  );

  // Light mode
  static ThemeData light = ThemeData(
    useMaterial3: _useMaterial3,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: AppColor.lightGray,
    cardTheme: CardTheme(
      surfaceTintColor: AppColor.white,
      color: AppColor.white,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: _pageTransitionTheme,
  );

  // Dark mode
  static ThemeData dark = ThemeData(
    useMaterial3: _useMaterial3,
    fontFamily: _fontFamily,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: _pageTransitionTheme,
  );
}
