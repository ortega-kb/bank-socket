import 'package:client/core/theme/app_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Constantes
  static final _fontFamily = GoogleFonts.atkinsonHyperlegible().fontFamily;
  static const _useMaterial3 = true;
  static const _pageTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
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
  static ThemeData light = FlexColorScheme.light(
    useMaterial3: _useMaterial3,
    fontFamily: _fontFamily,
    primary: AppColor.blueMarine,
    scaffoldBackground: AppColor.lightGray,
    surface: AppColor.white,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    swapLegacyOnMaterial3: true,
    pageTransitionsTheme: _pageTransitionTheme,
  ).toTheme.copyWith(
    navigationBarTheme: navigationBarTheme(
      AppColor.blueMarine,
      AppColor.blueMarine,
    ),
    navigationRailTheme: navigationRailTheme(
      AppColor.blueMarine,
      AppColor.blueMarine,
    ),
  );

  // Dark mode
  static ThemeData dark = FlexColorScheme.dark(
    useMaterial3: _useMaterial3,
    fontFamily: _fontFamily,
    primary: AppColor.blueMarine,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    swapLegacyOnMaterial3: true,
    pageTransitionsTheme: _pageTransitionTheme,
  ).toTheme.copyWith(
    navigationBarTheme: navigationBarTheme(
      AppColor.blueMarine,
      FlexColorScheme.dark(
        useMaterial3: _useMaterial3,
      ).toTheme.colorScheme.surface,
    ),
    navigationRailTheme: navigationRailTheme(
      AppColor.blueMarine,
      FlexColorScheme.dark(
        useMaterial3: _useMaterial3,
      ).toTheme.colorScheme.surface,
    ),
  );
}
