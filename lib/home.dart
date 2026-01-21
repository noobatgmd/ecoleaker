import 'package:ecoleaker/firebase_service.dart';
import 'package:ecoleaker/login.dart';
import 'package:ecoleaker/profilepage.dart';
import 'package:ecoleaker/firebase_service.dart';
import 'package:ecoleaker/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ecoleaker/tips.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoleaker/history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firebaseService = FirebaseService();
  int _selectedIndex = 0;

  // Cache for user data
  String _userName = 'User';
  Uint8List? _userPhotoBytes;
  bool _isLoadingProfile = true;
  String _userStatus = 'No status set';

  // Wash Hands Data (now mutable for scenarios)
  double washHandsGreen = 62.5;
  double washHandsAmber = 12.0;
  double washHandsRed = 25.5;
  int washHandsAvgDuration = 42; // seconds

  // Wash Vegetables Data (now mutable for scenarios)
  double washVegGreen = 55.0;
  double washVegAmber = 30.0;
  double washVegRed = 15.0;
  int washVegAvgDuration = 38; // seconds

  // Showering Data (now mutable for scenarios)
  double showerGreen = 45.0;
  double showerAmber = 35.0;
  double showerRed = 20.0;
  int showerAvgDuration = 7; // minutes

  // Total activations across ALL activities (now mutable for scenarios)
  int totalGreenActivations = 45;
  int totalAmberActivations = 28;
  int totalRedActivations = 12;

  double _avgWaterUsage = 0.0; // Average volume per month
  double _avgCostPerDay = 0.0; // Average cost per day

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadScenarioData();
    _initializePreviousScenario();
    _calculateAverages(); // ADD THIS LINE
  }

  Future<void> _calculateAverages() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('water_usage_history') ?? [];

    if (historyJson.isEmpty) {
      // No history yet, use default values
      setState(() {
        _avgWaterUsage = 0.0;
        _avgCostPerDay = 0.0;
      });
      print('ℹ️ No history found, averages set to 0');
      return;
    }

    // Parse history and calculate totals
    double totalVolume = 0;
    double totalCost = 0;
    int monthCount = historyJson.length;

    for (String recordJson in historyJson) {
      final record = json.decode(recordJson) as Map<String, dynamic>;
      totalVolume += record['volume'] ?? 0.0;
      totalCost += record['cost'] ?? 0.0;
    }

    // Calculate averages
    final avgVolume = totalVolume / monthCount;
    final avgCost = totalCost / monthCount;

    setState(() {
      _avgWaterUsage = avgVolume;
      _avgCostPerDay = avgCost;
    });

    print('📊 History Analysis:');
    print('   - Total Months: $monthCount');
    print('   - Total Volume: ${totalVolume.toStringAsFixed(1)} L');
    print('   - Total Cost: \$${totalCost.toStringAsFixed(2)}');
    print('💧 Avg Volume/Month: ${_avgWaterUsage.toStringAsFixed(1)} L');
    print('💰 Avg Cost/Day: \$${_avgCostPerDay.toStringAsFixed(2)}');
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);

    try {
      final profile = await _firebaseService.getUserProfile();

      if (profile != null && mounted) {
        setState(() {
          _userName = profile['name'] ?? 'User';
          _userStatus = profile['admNo'] ?? 'No status set'; // Load status

          // Decode base64 image if available
          final base64Image = profile['profileImageBase64'];
          if (base64Image != null && base64Image.isNotEmpty) {
            try {
              _userPhotoBytes = base64Decode(base64Image);
            } catch (e) {
              print('Error decoding image: $e');
              _userPhotoBytes = null;
            }
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<Map<String, dynamic>> _getScenarioData() async {
    final prefs = await SharedPreferences.getInstance();
    final scenario = prefs.getString('water_scenario') ?? 'majority_green';

    switch (scenario) {
      case 'majority_green':
        return {
          // Wash Hands
          'washHandsGreen': 70.0,
          'washHandsAmber': 20.0,
          'washHandsRed': 10.0,
          'washHandsAvgDuration': 30,

          // Wash Vegetables
          'washVegGreen': 68.0,
          'washVegAmber': 22.0,
          'washVegRed': 10.0,
          'washVegAvgDuration': 32,

          // Showering
          'showerGreen': 72.0,
          'showerAmber': 18.0,
          'showerRed': 10.0,
          'showerAvgDuration': 5,

          // Total activations
          'totalGreenActivations': 65,
          'totalAmberActivations': 20,
          'totalRedActivations': 10,
        };

      case 'majority_amber':
        return {
          // Wash Hands
          'washHandsGreen': 25.0,
          'washHandsAmber': 60.0,
          'washHandsRed': 15.0,
          'washHandsAvgDuration': 55,

          // Wash Vegetables
          'washVegGreen': 28.0,
          'washVegAmber': 57.0,
          'washVegRed': 15.0,
          'washVegAvgDuration': 58,

          // Showering
          'showerGreen': 22.0,
          'showerAmber': 63.0,
          'showerRed': 15.0,
          'showerAvgDuration': 8,

          // Total activations
          'totalGreenActivations': 22,
          'totalAmberActivations': 58,
          'totalRedActivations': 15,
        };

      case 'majority_red':
        return {
          // Wash Hands
          'washHandsGreen': 15.0,
          'washHandsAmber': 25.0,
          'washHandsRed': 60.0,
          'washHandsAvgDuration': 85,

          // Wash Vegetables
          'washVegGreen': 18.0,
          'washVegAmber': 22.0,
          'washVegRed': 60.0,
          'washVegAvgDuration': 95,

          // Showering
          'showerGreen': 12.0,
          'showerAmber': 28.0,
          'showerRed': 60.0,
          'showerAvgDuration': 12,

          // Total activations
          'totalGreenActivations': 15,
          'totalAmberActivations': 25,
          'totalRedActivations': 58,
        };

      case 'custom':
        return {
          'washHandsGreen': prefs.getDouble('custom_washHandsGreen') ?? 50.0,
          'washHandsAmber': prefs.getDouble('custom_washHandsAmber') ?? 30.0,
          'washHandsRed': prefs.getDouble('custom_washHandsRed') ?? 20.0,
          'washHandsAvgDuration':
              prefs.getInt('custom_washHandsDuration') ?? 45,

          'washVegGreen': prefs.getDouble('custom_washVegGreen') ?? 50.0,
          'washVegAmber': prefs.getDouble('custom_washVegAmber') ?? 30.0,
          'washVegRed': prefs.getDouble('custom_washVegRed') ?? 20.0,
          'washVegAvgDuration': prefs.getInt('custom_washVegDuration') ?? 40,

          'showerGreen': prefs.getDouble('custom_showerGreen') ?? 50.0,
          'showerAmber': prefs.getDouble('custom_showerAmber') ?? 30.0,
          'showerRed': prefs.getDouble('custom_showerRed') ?? 20.0,
          'showerAvgDuration': prefs.getInt('custom_showerDuration') ?? 6,

          'totalGreenActivations': prefs.getInt('custom_totalGreen') ?? 40,
          'totalAmberActivations': prefs.getInt('custom_totalAmber') ?? 30,
          'totalRedActivations': prefs.getInt('custom_totalRed') ?? 20,
        };

      default:
        return {
          // Default to majority_green
          'washHandsGreen': 70.0,
          'washHandsAmber': 20.0,
          'washHandsRed': 10.0,
          'washHandsAvgDuration': 30,
          'washVegGreen': 68.0,
          'washVegAmber': 22.0,
          'washVegRed': 10.0,
          'washVegAvgDuration': 32,
          'showerGreen': 72.0,
          'showerAmber': 18.0,
          'showerRed': 10.0,
          'showerAvgDuration': 5,
          'totalGreenActivations': 65,
          'totalAmberActivations': 20,
          'totalRedActivations': 10,
        };
    }
  }

  // Update _loadScenarioData method
  Future<void> _loadScenarioData() async {
    // First, try to load from Firebase
    final firebaseScenario = await _firebaseService.getSelectedScenario();

    final prefs = await SharedPreferences.getInstance();

    // If Firebase has a scenario, use it and sync to SharedPreferences
    String scenario;
    if (firebaseScenario != null) {
      scenario = firebaseScenario;
      await prefs.setString('water_scenario', firebaseScenario);
    } else {
      // Otherwise use local preference
      scenario = prefs.getString('water_scenario') ?? 'majority_green';
    }

    // Get scenario data
    final data = await _getScenarioDataForScenario(scenario);

    if (mounted) {
      setState(() {
        washHandsGreen = data['washHandsGreen'];
        washHandsAmber = data['washHandsAmber'];
        washHandsRed = data['washHandsRed'];
        washHandsAvgDuration = data['washHandsAvgDuration'];

        washVegGreen = data['washVegGreen'];
        washVegAmber = data['washVegAmber'];
        washVegRed = data['washVegRed'];
        washVegAvgDuration = data['washVegAvgDuration'];

        showerGreen = data['showerGreen'];
        showerAmber = data['showerAmber'];
        showerRed = data['showerRed'];
        showerAvgDuration = data['showerAvgDuration'];

        totalGreenActivations = data['totalGreenActivations'];
        totalAmberActivations = data['totalAmberActivations'];
        totalRedActivations = data['totalRedActivations'];
      });

      print('=== LOADED SCENARIO DATA ===');
      print('Scenario: $scenario');
      print(
        'Wash Hands: G:$washHandsGreen%, A:$washHandsAmber%, R:$washHandsRed%',
      );
      print('Wash Veg: G:$washVegGreen%, A:$washVegAmber%, R:$washVegRed%');
      print('Shower: G:$showerGreen%, A:$showerAmber%, R:$showerRed%');
      print(
        'Total Activations: G:$totalGreenActivations, A:$totalAmberActivations, R:$totalRedActivations',
      );
      print('============================');
      await _calculateAverages();
    }
  }

  Future<Map<String, dynamic>> _getScenarioDataForScenario(
    String scenario,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    switch (scenario) {
      case 'majority_green':
        return {
          'washHandsGreen': 70.0,
          'washHandsAmber': 20.0,
          'washHandsRed': 10.0,
          'washHandsAvgDuration': 30,
          'washVegGreen': 68.0,
          'washVegAmber': 22.0,
          'washVegRed': 10.0,
          'washVegAvgDuration': 32,
          'showerGreen': 72.0,
          'showerAmber': 18.0,
          'showerRed': 10.0,
          'showerAvgDuration': 5,
          'totalGreenActivations': 65,
          'totalAmberActivations': 20,
          'totalRedActivations': 10,
        };

      case 'majority_amber':
        return {
          'washHandsGreen': 25.0,
          'washHandsAmber': 60.0,
          'washHandsRed': 15.0,
          'washHandsAvgDuration': 55,
          'washVegGreen': 28.0,
          'washVegAmber': 57.0,
          'washVegRed': 15.0,
          'washVegAvgDuration': 58,
          'showerGreen': 22.0,
          'showerAmber': 63.0,
          'showerRed': 15.0,
          'showerAvgDuration': 8,
          'totalGreenActivations': 22,
          'totalAmberActivations': 58,
          'totalRedActivations': 15,
        };

      case 'majority_red':
        return {
          'washHandsGreen': 15.0,
          'washHandsAmber': 25.0,
          'washHandsRed': 60.0,
          'washHandsAvgDuration': 85,
          'washVegGreen': 18.0,
          'washVegAmber': 22.0,
          'washVegRed': 60.0,
          'washVegAvgDuration': 95,
          'showerGreen': 12.0,
          'showerAmber': 28.0,
          'showerRed': 60.0,
          'showerAvgDuration': 12,
          'totalGreenActivations': 15,
          'totalAmberActivations': 25,
          'totalRedActivations': 58,
        };

      case 'custom':
        return {
          'washHandsGreen': prefs.getDouble('custom_washHandsGreen') ?? 50.0,
          'washHandsAmber': prefs.getDouble('custom_washHandsAmber') ?? 30.0,
          'washHandsRed': prefs.getDouble('custom_washHandsRed') ?? 20.0,
          'washHandsAvgDuration':
              prefs.getInt('custom_washHandsDuration') ?? 45,
          'washVegGreen': prefs.getDouble('custom_washVegGreen') ?? 50.0,
          'washVegAmber': prefs.getDouble('custom_washVegAmber') ?? 30.0,
          'washVegRed': prefs.getDouble('custom_washVegRed') ?? 20.0,
          'washVegAvgDuration': prefs.getInt('custom_washVegDuration') ?? 40,
          'showerGreen': prefs.getDouble('custom_showerGreen') ?? 50.0,
          'showerAmber': prefs.getDouble('custom_showerAmber') ?? 30.0,
          'showerRed': prefs.getDouble('custom_showerRed') ?? 20.0,
          'showerAvgDuration': prefs.getInt('custom_showerDuration') ?? 6,
          'totalGreenActivations': prefs.getInt('custom_totalGreen') ?? 40,
          'totalAmberActivations': prefs.getInt('custom_totalAmber') ?? 30,
          'totalRedActivations': prefs.getInt('custom_totalRed') ?? 20,
        };

      default:
        return {
          'washHandsGreen': 70.0,
          'washHandsAmber': 20.0,
          'washHandsRed': 10.0,
          'washHandsAvgDuration': 30,
          'washVegGreen': 68.0,
          'washVegAmber': 22.0,
          'washVegRed': 10.0,
          'washVegAvgDuration': 32,
          'showerGreen': 72.0,
          'showerAmber': 18.0,
          'showerRed': 10.0,
          'showerAvgDuration': 5,
          'totalGreenActivations': 65,
          'totalAmberActivations': 20,
          'totalRedActivations': 10,
        };
    }
  }

  // Determine overall dominant color based on total activations
  Color get dominantColor {
    if (totalGreenActivations >= totalAmberActivations &&
        totalGreenActivations >= totalRedActivations) {
      return const Color(0xFF2ECC71); // Green
    } else if (totalAmberActivations >= totalGreenActivations &&
        totalAmberActivations >= totalRedActivations) {
      return const Color(0xFFFFB84D); // Amber
    } else {
      return const Color(0xFFE74C3C); // Red
    }
  }

  String get statusMessage {
    if (totalGreenActivations >= totalAmberActivations &&
        totalGreenActivations >= totalRedActivations) {
      return "Great job! You're using water efficiently! 💧";
    } else if (totalAmberActivations >= totalGreenActivations &&
        totalAmberActivations >= totalRedActivations) {
      return "Good effort! Try to reduce your water usage time.";
    } else {
      return "⚠️ High water usage detected. Consider using water wisely!";
    }
  }

  // Replace your _saveToHistory method in home.dart with this:

  Future<void> _saveToHistory(String scenarioName) async {
    print('🔵 Starting _saveToHistory for: $scenarioName');

    final prefs = await SharedPreferences.getInstance();

    // Calculate total duration in seconds
    final totalDurationSeconds =
        (washHandsAvgDuration + washVegAvgDuration + (showerAvgDuration * 60));

    print('📊 Total duration: $totalDurationSeconds seconds');

    // Calculate volume using flow rate
    final flowRate = prefs.getDouble('flow_rate') ?? 6.0;
    final volume = (flowRate * totalDurationSeconds) / 60;

    print(
      '💧 Volume: ${volume.toStringAsFixed(2)} L (Flow rate: $flowRate L/min)',
    );

    // Calculate cost
    final volumeM3 = volume / 1000;
    double tariff, conservationTax, waterborneTax;

    if (volumeM3 <= 40) {
      tariff = volumeM3 * 1.43;
      conservationTax = tariff * 0.50;
      waterborneTax = volumeM3 * 1.09;
    } else {
      tariff = volumeM3 * 1.81;
      conservationTax = tariff * 0.65;
      waterborneTax = volumeM3 * 1.40;
    }

    final subtotal = tariff + conservationTax + waterborneTax;
    final gst = subtotal * 0.09;
    final totalCost = subtotal + gst;

    print('💰 Cost: \$${totalCost.toStringAsFixed(2)}');

    // Calculate overall percentages
    final totalActivations =
        totalGreenActivations + totalAmberActivations + totalRedActivations;
    final greenPercent = totalActivations > 0
        ? (totalGreenActivations / totalActivations * 100)
        : 0.0;
    final amberPercent = totalActivations > 0
        ? (totalAmberActivations / totalActivations * 100)
        : 0.0;
    final redPercent = totalActivations > 0
        ? (totalRedActivations / totalActivations * 100)
        : 0.0;

    print(
      '📈 Distribution - Green: ${greenPercent.toStringAsFixed(1)}%, Amber: ${amberPercent.toStringAsFixed(1)}%, Red: ${redPercent.toStringAsFixed(1)}%',
    );

    final record = {
      'date': DateTime.now().toString().substring(0, 10),
      'scenarioName': scenarioName,
      'cost': totalCost,
      'volume': volume,
      'greenPercent': greenPercent,
      'amberPercent': amberPercent,
      'redPercent': redPercent,
      'greenActivations': totalGreenActivations,
      'amberActivations': totalAmberActivations,
      'redActivations': totalRedActivations,
    };

    print('📝 Record created: ${json.encode(record)}');

    // Load existing history
    final historyList = prefs.getStringList('water_usage_history') ?? [];
    print('📚 Current history count: ${historyList.length}');

    // Add new record
    historyList.add(json.encode(record));

    // Save to SharedPreferences
    await prefs.setStringList('water_usage_history', historyList);
    print('✅ Saved to SharedPreferences. New count: ${historyList.length}');

    // Save to Firebase
    try {
      final historyData = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();

      await _firebaseService.saveWaterUsageHistory(historyData);
      print(
        '✅ Successfully saved to Firebase. Total records: ${historyData.length}',
      );
    } catch (e) {
      print('❌ Error saving history to Firebase: $e');
    }

    print('🎉 _saveToHistory completed!');
  }

  Future<void> _addNextMonth() async {
    print('📅 Adding next month entry...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentScenario =
          prefs.getString('water_scenario') ?? 'majority_green';

      String scenarioName;
      switch (currentScenario) {
        case 'majority_green':
          scenarioName = 'Excellent Usage';
          break;
        case 'majority_amber':
          scenarioName = 'Moderate Usage';
          break;
        case 'majority_red':
          scenarioName = 'High Usage';
          break;
        case 'custom':
          scenarioName = 'Custom Scenario';
          break;
        default:
          scenarioName = 'Unknown';
      }

      print('📅 Adding month with scenario: $scenarioName');

      // Save current scenario as a monthly record
      await _saveToHistory(scenarioName);
      await _calculateAverages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Day added: $scenarioName')),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D7D),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding day: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // NEW: Save all user data before logout
  Future<void> _saveAllDataBeforeLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save current scenario
      final scenario = prefs.getString('water_scenario') ?? 'majority_green';
      await _firebaseService.saveSelectedScenario(scenario);

      // Save flow rate
      final flowRate = prefs.getDouble('flow_rate') ?? 6.0;
      await _firebaseService.saveFlowRate(flowRate);

      // Save water usage history
      final historyList = prefs.getStringList('water_usage_history') ?? [];
      final historyData = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
      await _firebaseService.saveWaterUsageHistory(historyData);

      // Save custom scenario data if exists
      if (scenario == 'custom') {
        final customData = {
          'washHandsGreen': prefs.getDouble('custom_washHandsGreen') ?? 50.0,
          'washHandsAmber': prefs.getDouble('custom_washHandsAmber') ?? 30.0,
          'washHandsRed': prefs.getDouble('custom_washHandsRed') ?? 20.0,
          'washHandsAvgDuration':
              prefs.getInt('custom_washHandsDuration') ?? 45,
          'washVegGreen': prefs.getDouble('custom_washVegGreen') ?? 50.0,
          'washVegAmber': prefs.getDouble('custom_washVegAmber') ?? 30.0,
          'washVegRed': prefs.getDouble('custom_washVegRed') ?? 20.0,
          'washVegAvgDuration': prefs.getInt('custom_washVegDuration') ?? 40,
          'showerGreen': prefs.getDouble('custom_showerGreen') ?? 50.0,
          'showerAmber': prefs.getDouble('custom_showerAmber') ?? 30.0,
          'showerRed': prefs.getDouble('custom_showerRed') ?? 20.0,
          'showerAvgDuration': prefs.getInt('custom_showerDuration') ?? 6,
          'totalGreenActivations': prefs.getInt('custom_totalGreen') ?? 40,
          'totalAmberActivations': prefs.getInt('custom_totalAmber') ?? 30,
          'totalRedActivations': prefs.getInt('custom_totalRed') ?? 20,
        };
        await _firebaseService.saveCustomScenarioData(customData);
      }

      print('All data saved successfully before logout');
    } catch (e) {
      print('Error saving data before logout: $e');
    }
  }

  // NEW: Clear all local data when logging out
  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all user-specific data
      await prefs.remove('name');
      await prefs.remove('Status');
      await prefs.remove('profileImageBase64');
      await prefs.remove('water_usage_history');
      await prefs.remove('water_scenario');
      await prefs.remove('previous_scenario');
      await prefs.remove('flow_rate');

      // Clear custom scenario data
      await prefs.remove('custom_washHandsGreen');
      await prefs.remove('custom_washHandsAmber');
      await prefs.remove('custom_washHandsRed');
      await prefs.remove('custom_washHandsDuration');
      await prefs.remove('custom_washVegGreen');
      await prefs.remove('custom_washVegAmber');
      await prefs.remove('custom_washVegRed');
      await prefs.remove('custom_washVegDuration');
      await prefs.remove('custom_showerGreen');
      await prefs.remove('custom_showerAmber');
      await prefs.remove('custom_showerRed');
      await prefs.remove('custom_showerDuration');
      await prefs.remove('custom_totalGreen');
      await prefs.remove('custom_totalAmber');
      await prefs.remove('custom_totalRed');

      print('✅ Local data cleared successfully');
    } catch (e) {
      print('❌ Error clearing local data: $e');
    }
  }

  // UPDATED: Modified _handleLogout method
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? All your data will be saved to the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // 1. Save current data to Firebase
      await _saveAllDataBeforeLogout();

      // 2. Clear all local SharedPreferences data
      await _clearLocalData();

      // 3. Sign out from Firebase
      await _firebaseService.signOut();

      // 4. Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
      ).then((_) {
        _loadUserProfile();
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TipsPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryPage()),
      ).then((_) {
        // Recalculate averages in case history was cleared
        _calculateAverages();
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ).then((_) async {
        print('🔙 Returned from Settings page');
        final prefs = await SharedPreferences.getInstance();
        // Get the OLD scenario BEFORE loading new data
        final oldScenario = prefs.getString('water_scenario');
        print('📋 OLD scenario (from previous_scenario): $oldScenario');

        // FIRST: Load the new scenario data
        await _loadScenarioData();

        // Get the new scenario
        final newScenario =
            prefs.getString('water_scenario') ?? 'majority_green';
        print('📋 NEW scenario (from water_scenario): $newScenario');

        await prefs.setString('previous_scenario', newScenario);

        // ONLY save to history if scenario actually changed
        if (oldScenario != newScenario) {
          print('✅ Scenario changed! Saving to history...');

          String scenarioName;
          switch (oldScenario) {
            case 'majority_green':
              scenarioName = 'Excellent Usage';
              break;
            case 'majority_amber':
              scenarioName = 'Moderate Usage';
              break;
            case 'majority_red':
              scenarioName = 'High Usage';
              break;
            case 'custom':
              scenarioName = 'Custom Scenario';
              break;
            default:
              scenarioName = 'Unknown';
          }
          print('💾 Saving old scenario to history: $scenarioName');
          // Save to history
          await _saveToHistory(scenarioName);
          await _calculateAverages();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Saved "$scenarioName" to history'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (oldScenario == null) {
          print('ℹ️ First time - no previous scenario to save');
          // Initialize previous_scenario for next time
          await prefs.setString('previous_scenario', newScenario);
        } else {
          print('ℹ️ Scenario unchanged ($oldScenario == $newScenario)');
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _initializePreviousScenario() async {
    final prefs = await SharedPreferences.getInstance();
    final currentScenario =
        prefs.getString('water_scenario') ?? 'majority_green';
    final previousScenario = prefs.getString('previous_scenario');

    // If there's no previous scenario stored, set it to current
    if (previousScenario == null) {
      print('🔧 Initializing previous_scenario to: $currentScenario');
      await prefs.setString('previous_scenario', currentScenario);
    } else {
      print('✅ Previous scenario already set: $previousScenario');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _firebaseService.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFB8E6E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Color(0xFF2E7D7D),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'EcoLeaker',
              style: TextStyle(
                color: Color(0xFF2E7D7D),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF2E7D7D),
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2E7D7D)),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNextMonth,
        backgroundColor: const Color(0xFFB8E6E6),
        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2E7D7D)),
        label: Text('Add Day', style: TextStyle(color: Color(0xFF2E7D7D))),
        tooltip: 'Add current scenario as next day',
      ),
      body: !isLoggedIn
          ? const Center(
              child: Text(
                'Please login to view your profile',
                style: TextStyle(fontSize: 16),
              ),
            )
          : _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Greeting Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB8E6E6),
                          const Color(0xFF8DD9D9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: _userPhotoBytes != null
                                ? MemoryImage(_userPhotoBytes!)
                                : null,
                            child: _userPhotoBytes == null
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFF2E7D7D),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Good Morning,',
                                style: TextStyle(
                                  color: Color(0xFF2E7D7D),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$_userName!',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D7D),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // In your build method, update the display to use the dynamic values:
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Avg Usage/Day: ${_avgWaterUsage.toStringAsFixed(1)} L',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D7D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Avg Cost/Day: \$${_avgCostPerDay.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D7D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Status (NEW)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.badge,
                                      size: 12,
                                      color: Color(0xFF2E7D7D),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _userStatus,
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D7D),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Info Box (Dynamic Color)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: dominantColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dominantColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: dominantColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          totalGreenActivations >= totalAmberActivations &&
                                  totalGreenActivations >= totalRedActivations
                              ? Icons.check_circle
                              : totalAmberActivations >=
                                        totalGreenActivations &&
                                    totalAmberActivations >= totalRedActivations
                              ? Icons.warning_amber_rounded
                              : Icons.error,
                          color: dominantColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            statusMessage,
                            style: TextStyle(
                              color: dominantColor.computeLuminance() > 0.5
                                  ? Colors.black87
                                  : dominantColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PIE CHART 1: Wash Hands
                  _buildPieChartCard(
                    title: 'Wash Hands',
                    icon: Icons.wash_outlined,
                    greenValue: washHandsGreen,
                    amberValue: washHandsAmber,
                    redValue: washHandsRed,
                    avgDuration: washHandsAvgDuration,
                    durationUnit: 'seconds',
                    greenLabel: 'Green (0-44s)',
                    amberLabel: 'Amber (45s-1m 9s)',
                    redLabel: 'Red (>1m 10s)',
                  ),

                  const SizedBox(height: 16),

                  // PIE CHART 2: Wash Vegetables
                  _buildPieChartCard(
                    title: 'Wash Vegetables',
                    icon: Icons.eco_outlined,
                    greenValue: washVegGreen,
                    amberValue: washVegAmber,
                    redValue: washVegRed,
                    avgDuration: washVegAvgDuration,
                    durationUnit: 'seconds',
                    greenLabel: 'Green (0-49s)',
                    amberLabel: 'Amber (50s-1m)',
                    redLabel: 'Red (>1m 30s)',
                  ),

                  const SizedBox(height: 16),

                  // PIE CHART 3: Showering
                  _buildPieChartCard(
                    title: 'Showering',
                    icon: Icons.shower_outlined,
                    greenValue: showerGreen,
                    amberValue: showerAmber,
                    redValue: showerRed,
                    avgDuration: showerAvgDuration,
                    durationUnit: 'minutes',
                    greenLabel: 'Green (≤5 min)',
                    amberLabel: 'Amber (≤8 min)',
                    redLabel: 'Red (>10 min)',
                  ),

                  const SizedBox(height: 16),

                  // Total Usage Breakdown (All Activities Combined)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8E6E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.analytics_outlined,
                                color: Color(0xFF2E7D7D),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Total Usage Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D7D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Combined activations across all activities',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        _buildActivationBar(
                          'Green Activations',
                          totalGreenActivations,
                          const Color(0xFF2ECC71),
                        ),
                        const SizedBox(height: 12),
                        _buildActivationBar(
                          'Amber Activations',
                          totalAmberActivations,
                          const Color(0xFFFFB84D),
                        ),
                        const SizedBox(height: 12),
                        _buildActivationBar(
                          'Red Activations',
                          totalRedActivations,
                          const Color(0xFFE74C3C),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D7D),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              label: 'Tips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard({
    required String title,
    required IconData icon,
    required double greenValue,
    required double amberValue,
    required double redValue,
    required int avgDuration,
    required String durationUnit,
    required String greenLabel,
    required String amberLabel,
    required String redLabel,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Activity Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D7D), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D7D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF2ECC71),
                    value: greenValue,
                    title: '${greenValue.toStringAsFixed(1)}%',
                    radius: 130,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFFB84D),
                    value: amberValue,
                    title: '${amberValue.toStringAsFixed(1)}%',
                    radius: 130,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFE74C3C),
                    value: redValue,
                    title: '${redValue.toStringAsFixed(1)}%',
                    radius: 130,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend(greenLabel, const Color(0xFF2ECC71)),
              _buildLegend(amberLabel, const Color(0xFFFFB84D)),
              _buildLegend(redLabel, const Color(0xFFE74C3C)),
            ],
          ),
          const SizedBox(height: 24),

          // Average Duration
          const Text(
            'Average Water Usage Duration:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D7D).withOpacity(0.1),
                  const Color(0xFF2E7D7D).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$avgDuration $durationUnit',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D7D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 2),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActivationBar(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
