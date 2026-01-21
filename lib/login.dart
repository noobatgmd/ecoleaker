import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecoleaker/auth_service.dart';
import 'package:ecoleaker/createaccount.dart';
import 'package:ecoleaker/forgot_password.dart';
import 'package:ecoleaker/home.dart';
import 'package:ecoleaker/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  // NEW: Load user data from Firebase after successful login
  Future<void> _loadUserDataFromFirebase() async {
    try {
      print('🔄 Loading user data from Firebase...');
      final prefs = await SharedPreferences.getInstance();

      // Load user profile
      final profile = await _firebaseService.getUserProfile();
      if (profile != null) {
        await prefs.setString('name', profile['name'] ?? '');
        await prefs.setString('admNo', profile['admNo'] ?? '');
        if (profile['profileImageBase64'] != null) {
          await prefs.setString(
            'profileImageBase64',
            profile['profileImageBase64'],
          );
        }
        print('✅ User profile loaded');
      }

      // Load water usage history
      final history = await _firebaseService.getWaterUsageHistory();
      if (history != null && history.isNotEmpty) {
        final historyJson = history.map((item) => json.encode(item)).toList();
        await prefs.setStringList('water_usage_history', historyJson);
        print('✅ History loaded: ${history.length} records');
      } else {
        // Clear any stale history
        await prefs.remove('water_usage_history');
        print('ℹ️ No history found');
      }

      // Load flow rate
      final flowRate = await _firebaseService.getFlowRate();
      if (flowRate != null) {
        await prefs.setDouble('flow_rate', flowRate);
        print('✅ Flow rate loaded: $flowRate');
      }

      // Load selected scenario
      final scenario = await _firebaseService.getSelectedScenario();
      if (scenario != null) {
        await prefs.setString('water_scenario', scenario);
        await prefs.setString('previous_scenario', scenario);
        print('✅ Scenario loaded: $scenario');
      } else {
        // Set default scenario for new users
        await prefs.setString('water_scenario', 'majority_green');
        await prefs.setString('previous_scenario', 'majority_green');
        print('ℹ️ Default scenario set');
      }

      // Load custom scenario data if it exists
      final customData = await _firebaseService.getCustomScenarioData();
      if (customData != null) {
        await prefs.setDouble(
          'custom_washHandsGreen',
          customData['washHandsGreen'] ?? 50.0,
        );
        await prefs.setDouble(
          'custom_washHandsAmber',
          customData['washHandsAmber'] ?? 30.0,
        );
        await prefs.setDouble(
          'custom_washHandsRed',
          customData['washHandsRed'] ?? 20.0,
        );
        await prefs.setInt(
          'custom_washHandsDuration',
          customData['washHandsAvgDuration'] ?? 45,
        );

        await prefs.setDouble(
          'custom_washVegGreen',
          customData['washVegGreen'] ?? 50.0,
        );
        await prefs.setDouble(
          'custom_washVegAmber',
          customData['washVegAmber'] ?? 30.0,
        );
        await prefs.setDouble(
          'custom_washVegRed',
          customData['washVegRed'] ?? 20.0,
        );
        await prefs.setInt(
          'custom_washVegDuration',
          customData['washVegAvgDuration'] ?? 40,
        );

        await prefs.setDouble(
          'custom_showerGreen',
          customData['showerGreen'] ?? 50.0,
        );
        await prefs.setDouble(
          'custom_showerAmber',
          customData['showerAmber'] ?? 30.0,
        );
        await prefs.setDouble(
          'custom_showerRed',
          customData['showerRed'] ?? 20.0,
        );
        await prefs.setInt(
          'custom_showerDuration',
          customData['showerAvgDuration'] ?? 6,
        );

        await prefs.setInt(
          'custom_totalGreen',
          customData['totalGreenActivations'] ?? 40,
        );
        await prefs.setInt(
          'custom_totalAmber',
          customData['totalAmberActivations'] ?? 30,
        );
        await prefs.setInt(
          'custom_totalRed',
          customData['totalRedActivations'] ?? 20,
        );
        print('✅ Custom scenario data loaded');
      }

      print('🎉 All user data loaded from Firebase successfully');
    } catch (e) {
      print('❌ Error loading user data from Firebase: $e');
      // Don't throw error - allow user to continue with defaults
    }
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FA), // background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'EcoLeaker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F7A7E), // primary title
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/img/Ecoleaker.jpeg',
                    width: 280,
                    height: 280,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6F8A8A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'email@domain.com',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF4CAF50),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7DCDC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7DCDC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2FA4A9),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEAF5F4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF4CAF50),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7DCDC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB7DCDC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2FA4A9),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEAF5F4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2FA4A9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  // Validate inputs
                                  if (_emailController.text.trim().isEmpty ||
                                      _passwordController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter email and password',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);

                                  try {
                                    // Attempt login
                                    final message = await AuthService().login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );

                                    if (message != null &&
                                        message.contains('Success')) {
                                      // Login successful - load user data from Firebase
                                      print(
                                        '✅ Login successful, loading user data...',
                                      );

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final uid = FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.uid;

                                      if (uid != null) {
                                        await prefs.setString('lastUser', uid);

                                        // Load all user data from Firebase
                                        await _loadUserDataFromFirebase();
                                      }

                                      if (mounted) {
                                        // Show success message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Login successful! Loading your data...',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        // Navigate to home
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Login failed
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              message ?? 'Login failed',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print('❌ Login error: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Login error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text.rich(
                        TextSpan(
                          text: 'By clicking continue, you agree to our ',
                          style: TextStyle(
                            color: Color(0xFF6F8A8A),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F7A7E),
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F7A7E),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateAccount(),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xFFD0ECEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color(0xFF1F7A7E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
