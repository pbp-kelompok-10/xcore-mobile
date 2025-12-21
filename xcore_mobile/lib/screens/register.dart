import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> _errors = {};

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Widget _buildErrorText(String field) {
    if (_errors.containsKey(field)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_errors[field].length, (index) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors[field][index]["message"],
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                color: Color(0xFFEF4444),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final cookieRequest = context.watch<CookieRequest>();

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
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C5F5A),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Username Field
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(fontFamily: 'Nunito Sans'),
                    decoration: InputDecoration(
                      labelText: "Username",
                      hintText: "Enter your username",
                      labelStyle: const TextStyle(fontFamily: 'Nunito Sans'),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF4AA69B),
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
                          color: Color(0xFF4AA69B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  _buildErrorText("username"),
                  const SizedBox(height: 16),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(fontFamily: 'Nunito Sans'),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      labelStyle: const TextStyle(fontFamily: 'Nunito Sans'),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF4AA69B),
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
                          color: Color(0xFF4AA69B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  _buildErrorText("email"),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Nunito Sans'),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      labelStyle: const TextStyle(fontFamily: 'Nunito Sans'),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF4AA69B),
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
                          color: Color(0xFF4AA69B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  _buildErrorText("password1"),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Nunito Sans'),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Re-enter your password",
                      labelStyle: const TextStyle(fontFamily: 'Nunito Sans'),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF4AA69B),
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
                          color: Color(0xFF4AA69B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  _buildErrorText("password2"),
                  const SizedBox(height: 20),

                  // Profile Picture Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF4AA69B),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF4AA69B),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImage == null
                                  ? "Select Profile Picture (optional)"
                                  : "Selected: ${_selectedImage!.path.split('/').last}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildErrorText("profile_picture"),

                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _errors = {};
                        });

                        String username = _usernameController.text;
                        String email = _emailController.text;
                        String password1 = _passwordController.text;
                        String password2 = _confirmPasswordController.text;

                        if (password1 != password2) {
                          setState(() {
                            _errors["password2"] = [
                              {"message": "Password tidak cocok."},
                            ];
                          });
                          return;
                        }

                        final url = Uri.parse(
                          "https://alvin-christian-xcore.pbp.cs.ui.ac.id/auth/register/",
                        );

                        var requestMultipart = http.MultipartRequest(
                          "POST",
                          url,
                        );

                        requestMultipart.fields['username'] = username;
                        requestMultipart.fields['email'] = email;
                        requestMultipart.fields['password1'] = password1;
                        requestMultipart.fields['password2'] = password2;

                        if (_selectedImage != null) {
                          requestMultipart.files.add(
                            await http.MultipartFile.fromPath(
                              'profile_picture',
                              _selectedImage!.path,
                            ),
                          );
                        }

                        requestMultipart.headers['cookie'] =
                            cookieRequest.headers['cookie'] ?? "";

                        try {
                          final streamed = await requestMultipart.send();
                          final response = await http.Response.fromStream(
                            streamed,
                          );

                          final jsonResponse = jsonDecode(response.body);

                          if (jsonResponse["status"] == true) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Pendaftaran berhasil! Selamat datang ${jsonResponse['username']}",
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

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              _errors = jsonResponse["errors"] ?? {};
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      jsonResponse["message"] ??
                                          "Pendaftaran gagal",
                                      style: const TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error: $e",
                                    style: const TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFEF4444),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                        "Register",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          color: Color(0xFF6B7280),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
