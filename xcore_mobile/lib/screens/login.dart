import 'package:xcore_mobile/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/screens/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2C5F5A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Log In',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C5F5A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Username Field
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      labelStyle: const TextStyle(
                        fontFamily: 'Nunito Sans',
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF2C5F5A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF2C5F5A),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      labelStyle: const TextStyle(
                        fontFamily: 'Nunito Sans',
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF2C5F5A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF2C5F5A),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        String username = _usernameController.text.trim();
                        String password = _passwordController.text.trim();
                        final response = await request.login(
                          "http://localhost:8000/auth/login/",
                          {
                            'username': username,
                            'password': password,
                          },
                        );
                        if (request.loggedIn && response["status"] == true) {
                          String message = response["message"];
                          String uname = response["username"];

                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainNavigation()),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "$message Selamat datang, $uname!",
                                    style: const TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF4AA69B),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                          }
                        } else {
                          String errorMessage =
                              response["message"] ?? "Login gagal.";

                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  'Login Gagal',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C5F5A),
                                  ),
                                ),
                                content: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4AA69B),
                                        fontSize: 16,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5F5A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          color: Color(0xFF6B7280),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            color: Color(0xFF4AA69B),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}