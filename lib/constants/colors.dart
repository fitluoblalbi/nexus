import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6B5FEA); // Purple
  static const Color primaryDark = Color(0xFF4F3FD1);
  static const Color primaryLight = Color(0xFF9B8FFF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryDark = Color(0xFF0099CC);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF6C757D);
  static const Color greyLight = Color(0xFFF8F9FA);
  static const Color greyLighter = Color(0xFFE9ECEF);
  
  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
