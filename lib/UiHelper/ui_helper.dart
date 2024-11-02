//custom sizes
import 'package:flutter/material.dart';

double kSize5 = 5;
double kSize7 = 7;
double kSize9 = 9;
double kSize11 = 11;
double kSize13 = 13;
double kSize15 = 15;
double kSize16 = 16;
double kSize18 = 18;
double kSize22 = 22;
double kSize24 = 24;
double kSize26 = 26;
double kSize28 = 28;
double kSize30 = 30;
double kSize36 = 36;
double kSize42 = 42;
double kSize48 = 48;
double kSize50 = 50;
double kSize60 = 60;
double kSize70 = 70;
double kSize80 = 80;
double kSize90 = 90;
double kSize100 = 100;

//app colors
Color whiteColor = Colors.white;
Color blackColor = Colors.black;
Color lightGrayColor = const Color(0xFFF2F2F2);
Color darkGrayColor = const Color(0xFF4A4A4A);
Color softBlueColor = const Color(0xFF89CFF0);
Color mutedBlueColor = const Color(0xFF3A5A80);
Color paleGreenColor = const Color(0xFFB2E5B2);
const Color lightRed = Color(0xFFFFCDD2); // Light red, great for backgrounds
const Color primaryRed = Color(0xFFF44336);
const Color darkRed = Color(0xFFD32F2F);
Color deepRed = const Color(0xFFB71C1C);
// Whites & Grays
const Color pureWhite = Color(0xFFFFFFFF); // Pure white, clean background
const Color offWhite = Color(0xFFF9F9F9); // Off-white, softer for backgrounds
const Color lightGray =
    Color(0xFFEEEEEE); // Light gray, subtle for dividers and accents
const Color mediumGray =
    Color(0xFFBDBDBD); // Medium gray, ideal for text or borders
const Color darkGray = Color(0xFF757575);
//TextStyle
kTextStyle(double textSize, Color color, bool isBold) => TextStyle(
    fontSize: textSize,
    color: color,
    fontWeight: isBold ? FontWeight.bold : null);

//sizedBox
heightBox(double size) {
  return SizedBox(
    height: size,
  );
}

widthBox(double size) {
  return SizedBox(
    width: size,
  );
}

getBanner() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: kSize42, horizontal: kSize24),
    decoration: BoxDecoration(
      color: primaryRed,
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.4),
        ),
      ],
      border: Border.all(color: lightGray, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(kSize16)),
    ),
    child: Text(
      "YT_DESK",
      style: kTextStyle(kSize80, lightGray, false),
    ),
  );
}

getInputDecoration(String label) {
  return InputDecoration(
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: lightRed,
      ),
      borderRadius: BorderRadius.circular(kSize13),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: darkRed,
      ),
      borderRadius: BorderRadius.circular(kSize13),
    ),
    labelText: label,
    labelStyle: const TextStyle(
      color: lightRed,
    ),
  );
}

kBoxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade300,
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
    border: Border.all(color: lightRed, width: 2),
    borderRadius: BorderRadius.circular(kSize16),
  );
}
