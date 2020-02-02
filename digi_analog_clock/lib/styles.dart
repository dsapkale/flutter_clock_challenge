import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle infoTextStyle(
        {Color color, double fontSize, FontWeight fontWeight}) =>
    GoogleFonts.macondoSwashCaps(
        textStyle: TextStyle(
            color: color, fontSize: fontSize, fontWeight: fontWeight));
