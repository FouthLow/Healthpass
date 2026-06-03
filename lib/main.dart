import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_page.dart';
import 'screens/onboarding_page.dart';
import 'widget/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Passport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const InitializerWidget(),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({super.key});

  @override
  State<InitializerWidget> createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  bool _isLoading = true;
  String? _token;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboarding = prefs.getBool('onboarding_completed') ?? false;
    final token = prefs.getString('token');

    setState(() {
      _onboardingCompleted = onboarding;
      _token = token;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (!_onboardingCompleted) {
      return const OnboardingPage();
    }

    if (_token != null && _token!.isNotEmpty) {
      return MainNavigation(token: _token!);
    }

    return const AuthPage();
  }
}
