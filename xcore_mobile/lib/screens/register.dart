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

  // Store errors from Django
  Map<String, dynamic> _errors = {};

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Show ALL error messages for a field
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
                color: Colors.red,
                fontSize: 13,
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
      appBar: AppBar(
        title: const Text(
          'Daftar Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Daftar Akun Baru",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Username
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        hintText: "Masukkan username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                    ),
                    _buildErrorText("username"),
                    const SizedBox(height: 12),

                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Masukkan email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                    ),
                    _buildErrorText("email"),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Masukkan password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      obscureText: true,
                    ),
                    _buildErrorText("password1"),
                    const SizedBox(height: 12),

                    // Confirm Password
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: "Konfirmasi Password",
                        hintText: "Masukkan password kembali",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      obscureText: true,
                    ),
                    _buildErrorText("password2"),
                    const SizedBox(height: 20),

                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image, color: Colors.green[700]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedImage == null
                                    ? "Pilih Foto Profil (opsional)"
                                    : "Terpilih: ${_selectedImage!.path.split('/').last}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _buildErrorText("profile_picture"),

                    const SizedBox(height: 24),

                    // REGISTER BUTTON
                    ElevatedButton(
                      onPressed: () async {
                        // Clear old errors before new request
                        setState(() {
                          _errors = {};
                        });

                        String username = _usernameController.text;
                        String email = _emailController.text;
                        String password1 = _passwordController.text;
                        String password2 = _confirmPasswordController.text;

                        // Local validation
                        if (password1 != password2) {
                          setState(() {
                            _errors["password2"] = [
                              {"message": "Password tidak cocok."}
                            ];
                          });
                          return;
                        }

                        final url =
                            Uri.parse("http://localhost:8000/auth/register/");

                        var requestMultipart =
                            http.MultipartRequest("POST", url);

                        requestMultipart.fields['username'] = username;
                        requestMultipart.fields['email'] = email;
                        requestMultipart.fields['password1'] = password1;
                        requestMultipart.fields['password2'] = password2;

                        if (_selectedImage != null) {
                          print("Adding image file: ${_selectedImage!.path}");
                          requestMultipart.files.add(
                            await http.MultipartFile.fromPath(
                              'profile_picture',
                              _selectedImage!.path,
                            ),
                          );
                        }

                        // Add cookies for Django session
                        requestMultipart.headers['cookie'] =
                            cookieRequest.headers['cookie'] ?? "";

                        try {
                          final streamed = await requestMultipart.send();
                          final response =
                              await http.Response.fromStream(streamed);

                          final jsonResponse = jsonDecode(response.body);

                          if (jsonResponse["status"] == true) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Pendaftaran berhasil! Selamat datang ${jsonResponse['username']}",
                                    ),
                                    backgroundColor: Colors.green[600],
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                            // Show field errors
                            setState(() {
                              _errors = jsonResponse["errors"] ?? {};
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(jsonResponse["message"] ??
                                        "Pendaftaran gagal"),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                            }
                          }
                        } catch (e) {
                          print("Error during registration: $e");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                          }
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[700],
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOGIN PLACEHOLDER
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sudah punya akun? Login",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}