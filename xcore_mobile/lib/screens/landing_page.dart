import 'package:flutter/material.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:xcore_mobile/screens/register.dart';
import 'package:xcore_mobile/screens/main_navigation.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkGreen = const Color(0xFF1F3A33);

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const NetworkImage(
                    'https://facts.net/wp-content/uploads/2023/07/9-facts-about-fifa-world-cup-1689836355.jpg'),
                
                fit: BoxFit.cover,              
              ),
            ),
          ),

          // 2. GRADIENT OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1), // Atas lebih terang biar piala jelas
                  Colors.black.withOpacity(0.7), // Bawah gelap biar kotak putih kontras
                ],
              ),
            ),
          ),

          // 3. RESPONSIVE BOTTOM SHEET
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 600;

              return Align(
                alignment: isWideScreen ? Alignment.center : Alignment.bottomCenter,
                child: Container(
                  width: isWideScreen ? 400 : double.infinity,
                  
                  // Margin nol di HP agar nempel full ke bawah
                  margin: isWideScreen ? const EdgeInsets.all(24) : EdgeInsets.zero,
                  
                  // Padding dalam kotak putih
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: isWideScreen
                        ? BorderRadius.circular(30)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: isWideScreen ? const Offset(0, 10) : const Offset(0, -5),
                      )
                    ],
                  ),
                  
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        const Text(
                          "Welcome to Xcore",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Tombol 1: LOG IN
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Tombol 2: REGISTER
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Link Text
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainNavigation()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Continue without an account",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Jarak aman
                        const SizedBox(height: 20), 
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}