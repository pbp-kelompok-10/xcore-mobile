import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Xcore Football',
        theme: ThemeData(
          // Primary Color - Soft Teal/Turquoise (matching Django)
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4AA69B),
            primary: const Color(0xFF4AA69B), // --green-normal
            secondary: const Color(0xFF56BDA9), // --green-dark
            tertiary: const Color(0xFF28574E), // darker teal
            surface: const Color(0xFFFFFFFF),
            background: const Color(0xFFE8F6F4), // --green-light
            error: const Color(0xFFEF4444),
            onPrimary: const Color(0xFFFFFFFF),
            onSecondary: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF2C5F5A),
            onBackground: const Color(0xFF2C5F5A),
            brightness: Brightness.light,
          ),
          
          // Scaffold Background
          scaffoldBackgroundColor: const Color(0xFFE8F6F4),
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4AA69B),
            foregroundColor: Color(0xFFFFFFFF),
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          // Card Theme
          cardTheme: const CardThemeData(
            color: Color(0xFFFFFFFF),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          
          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4AA69B),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          // Text Button Theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4AA69B),
              textStyle: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Outlined Button Theme
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4AA69B),
              side: const BorderSide(
                color: Color(0xFF4AA69B),
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4AA69B),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Nunito Sans',
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Nunito Sans',
              color: Color(0xFF9CA3AF),
            ),
          ),
          
          // Text Theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C5F5A),
            ),
            displayMedium: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            displaySmall: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            headlineLarge: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            titleLarge: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5F5A),
            ),
            titleMedium: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5F5A),
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
            ),
            bodySmall: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B8E8A),
            ),
            labelLarge: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5F5A),
            ),
          ),
          
          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF4AA69B),
            foregroundColor: Color(0xFFFFFFFF),
            elevation: 4,
          ),
          
          // Divider Theme
          dividerTheme: const DividerThemeData(
            color: Color(0xFFD1D5DB),
            thickness: 1,
            space: 1,
          ),
          
          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFFFFFFF),
            selectedItemColor: Color(0xFF4AA69B),
            unselectedItemColor: Color(0xFF9CA3AF),
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Chip Theme
          chipTheme: const ChipThemeData(
            backgroundColor: Color(0xFFE8F6F4),
            selectedColor: Color(0xFF4AA69B),
            disabledColor: Color(0xFFE5E7EB),
            labelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5F5A),
            ),
            secondaryLabelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          
          // Progress Indicator Theme
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFF4AA69B),
          ),
          
          // Tab Bar Theme
          tabBarTheme: const TabBarThemeData(
            labelColor: Color(0xFFFFFFFF),
            unselectedLabelColor: Color(0xFFE8F6F4),
            indicatorColor: Color(0xFFFFFFFF),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          // Snack Bar Theme
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF4AA69B),
            contentTextStyle: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          
          // Dialog Theme
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titleTextStyle: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            contentTextStyle: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B8E8A),
            ),
          ),
          
          // Material 3
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}