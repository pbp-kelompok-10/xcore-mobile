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
        title: const Text("Register"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Center(
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
                    "Register",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Username
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  _buildErrorText("username"),
                  const SizedBox(height: 12),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  _buildErrorText("email"),
                  const SizedBox(height: 12),

                  // Password
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  _buildErrorText("password1"),
                  const SizedBox(height: 12),

                  // Confirm Password
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(),
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
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedImage == null
                                  ? "Pick Profile Picture (optional)"
                                  : "Selected: ${_selectedImage!.path.split('/').last}",
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
                            {"message": "Passwords do not match."}
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

                      final streamed = await requestMultipart.send();
                      final response =
                          await http.Response.fromStream(streamed);

                      final jsonResponse = jsonDecode(response.body);

                      if (jsonResponse["status"] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Successfully registered! Welcome ${jsonResponse['username']}",
                            ),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      } else {
                        // Show field errors
                        setState(() {
                          _errors = jsonResponse["errors"] ?? {};
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(jsonResponse["message"] ??
                                "Registration failed"),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
