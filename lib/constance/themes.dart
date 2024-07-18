// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:adevindustries/constance/global.dart' as globals;
import 'package:google_fonts/google_fonts.dart';

class AllCoustomTheme {
  static ThemeData getThemeData() {
    if (globals.isLight) {
      return buildLightTheme();
    } else {
      return buildDarkTheme();
    }
  }

  static Color getTextThemeColors() {
    if (globals.isLight) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  static Color getsecoundTextThemeColor() {
    return Color(0xFF525a6d);
  }

  static Color boxColor() {
    return Color(0xFF1a202f);
  }

  static Color getBlackAndWhiteThemeColors() {
    if (globals.isLight) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  static Color getReBlackAndWhiteThemeColors() {
    if (globals.isLight) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline6: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headline6!.color,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle1: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.subtitle1!.color,
          fontSize: 16,
        ),
      ),
      subtitle2: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.subtitle2!.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      bodyText2: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyText2!.color,
          fontSize: 16,
        ),
      ),
      bodyText1: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyText1!.color,
          fontSize: 14,
        ),
      ),
      button: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.button!.color, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      caption: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.caption!.color, fontSize: 12),
      ),
      headline4: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.headline4!.color, fontSize: 34),
      ),
      headline3: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headline3!.color,
          fontSize: 48,
        ),
      ),
      headline2: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headline2!.color,
          fontSize: 60,
        ),
      ),
      headline1: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headline1!.color,
          fontSize: 96,
        ),
      ),
      headline5: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headline5!.color,
          fontSize: 24,
        ),
      ),
      overline: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.overline!.color,
          fontSize: 10,
        ),
      ),
    );
  }

  static IconThemeData iconTheme() {
    return IconThemeData(color: getThemeData().primaryColor, opacity: 1.0);
  }

  static ThemeData buildDarkTheme() {
    return buildLightTheme();
  }

  static ThemeData buildLightTheme() {
    Color primaryColor = HexColor(globals.primaryColorString);
    Color secondaryColor = Colors.white;
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFFEFF1F4),
      backgroundColor: const Color(0x101622),
      errorColor: const Color(0xFFB00020),
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
