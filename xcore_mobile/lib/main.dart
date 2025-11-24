import 'package:flutter/material.dart';
import 'package:xcore_mobile/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/screens/login.dart';

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green[700]!,
            primary: Colors.green[700]!,
            secondary: Colors.green[500]!,
          ),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}