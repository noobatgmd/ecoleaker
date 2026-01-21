// ===== SETTINGS PAGE =====
import 'package:ecoleaker/customsetting.dart';
import 'package:ecoleaker/firebase_service.dart';
import 'package:ecoleaker/history.dart';
import 'package:ecoleaker/home.dart';
import 'package:ecoleaker/profilepage.dart';
import 'package:ecoleaker/tips.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _firebaseService = FirebaseService();
  String _selectedScenario = 'majority_green';
  Map<String, String> _customStats = {'Green': '-', 'Amber': '-', 'Red': '-'};

  @override
  void initState() {
    super.initState();
    _loadSelectedScenario();
  }

  Future<void> _loadSelectedScenario() async {
    final prefs = await SharedPreferences.getInstance();

    // Load from Firebase first
    final firebaseData = await _firebaseService.getCustomScenarioData();

    // If Firebase has data, use it and sync to SharedPreferences
    if (firebaseData != null) {
      final totalGreen = firebaseData['totalGreen'] ?? 0;
      final totalAmber = firebaseData['totalAmber'] ?? 0;
      final totalRed = firebaseData['totalRed'] ?? 0;
      final total = totalGreen + totalAmber + totalRed;

      // Sync Firebase data to SharedPreferences
      if (total > 0) {
        await prefs.setInt('custom_totalGreen', totalGreen);
        await prefs.setInt('custom_totalAmber', totalAmber);
        await prefs.setInt('custom_totalRed', totalRed);

        // Save individual activity data
        await prefs.setDouble(
          'custom_washHandsGreen',
          firebaseData['washHandsGreen'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_washHandsAmber',
          firebaseData['washHandsAmber'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_washHandsRed',
          firebaseData['washHandsRed'] ?? 0.0,
        );
        await prefs.setInt(
          'custom_washHandsDuration',
          firebaseData['washHandsDuration'] ?? 0,
        );

        await prefs.setDouble(
          'custom_washVegGreen',
          firebaseData['washVegGreen'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_washVegAmber',
          firebaseData['washVegAmber'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_washVegRed',
          firebaseData['washVegRed'] ?? 0.0,
        );
        await prefs.setInt(
          'custom_washVegDuration',
          firebaseData['washVegDuration'] ?? 0,
        );

        await prefs.setDouble(
          'custom_showerGreen',
          firebaseData['showerGreen'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_showerAmber',
          firebaseData['showerAmber'] ?? 0.0,
        );
        await prefs.setDouble(
          'custom_showerRed',
          firebaseData['showerRed'] ?? 0.0,
        );
        await prefs.setInt(
          'custom_showerDuration',
          firebaseData['showerDuration'] ?? 0,
        );
      }

      setState(() {
        _selectedScenario =
            prefs.getString('water_scenario') ?? 'majority_green';

        if (total > 0) {
          _customStats = {
            'Green': '${(totalGreen / total * 100).round()}%',
            'Amber': '${(totalAmber / total * 100).round()}%',
            'Red': '${(totalRed / total * 100).round()}%',
          };
        } else {
          _customStats = {'Green': '-', 'Amber': '-', 'Red': '-'};
        }
      });
    } else {
      // Fallback to SharedPreferences if Firebase has no data
      final totalGreen = prefs.getInt('custom_totalGreen') ?? 0;
      final totalAmber = prefs.getInt('custom_totalAmber') ?? 0;
      final totalRed = prefs.getInt('custom_totalRed') ?? 0;
      final total = totalGreen + totalAmber + totalRed;

      setState(() {
        _selectedScenario =
            prefs.getString('water_scenario') ?? 'majority_green';

        if (total > 0) {
          _customStats = {
            'Green': '${(totalGreen / total * 100).round()}%',
            'Amber': '${(totalAmber / total * 100).round()}%',
            'Red': '${(totalRed / total * 100).round()}%',
          };
        } else {
          _customStats = {'Green': '-', 'Amber': '-', 'Red': '-'};
        }
      });
    }
  }

  Future<void> _saveScenario(String scenario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('water_scenario', scenario);

    // Mark that a scenario was just selected
    await prefs.setBool('scenario_just_selected', true);

    // Save to Firebase
    try {
      await _firebaseService.saveSelectedScenario(scenario);
    } catch (e) {
      print('Error saving scenario to Firebase: $e');
    }

    setState(() {
      _selectedScenario = scenario;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Scenario selected! It will be saved when you return to Home.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCustomInput() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomInputPage()),
    ).then((_) {
      _loadSelectedScenario();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D7D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF2E7D7D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFB8E6E6), const Color(0xFF8DD9D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Color(0xFF2E7D7D),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Usage Scenarios',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D7D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Disclaimer: This is a prototype demonstration. Please select a scenario to explore different water usage patterns.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E7D7D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Usage Scenario:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D7D),
                ),
              ),
              const SizedBox(height: 16),
              _buildScenarioCard(
                scenario: 'majority_green',
                title: 'Excellent Usage',
                subtitle: 'Majority Green - Water Saver Champion! 🏆',
                description:
                    'You\'re doing an amazing job! Most of your water usage is efficient.',
                icon: Icons.eco,
                iconColor: const Color(0xFF2ECC71),
                stats: {'Green': '70%', 'Amber': '20%', 'Red': '10%'},
                isSelected: _selectedScenario == 'majority_green',
              ),
              const SizedBox(height: 16),
              _buildScenarioCard(
                scenario: 'majority_amber',
                title: 'Moderate Usage',
                subtitle: 'Majority Amber - Room for Improvement ⚠️',
                description:
                    'You\'re using water moderately, but there\'s potential to save more!',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFFB84D),
                stats: {'Green': '25%', 'Amber': '60%', 'Red': '15%'},
                isSelected: _selectedScenario == 'majority_amber',
              ),
              const SizedBox(height: 16),
              _buildScenarioCard(
                scenario: 'majority_red',
                title: 'High Usage',
                subtitle: 'Majority Red - Action Needed! 🚨',
                description:
                    'Your water usage is high. Small changes can make a big difference!',
                icon: Icons.warning,
                iconColor: const Color(0xFFE74C3C),
                stats: {'Green': '15%', 'Amber': '25%', 'Red': '60%'},
                isSelected: _selectedScenario == 'majority_red',
              ),
              const SizedBox(height: 16),
              _buildScenarioCard(
                scenario: 'custom',
                title: 'Custom Scenario',
                subtitle: 'Your personalized water usage pattern 🎯',
                description:
                    'Create your own custom water usage scenario with specific percentages.',
                icon: Icons.tune,
                iconColor: const Color(0xFF2E7D7D),
                stats: _customStats,
                isSelected: _selectedScenario == 'custom',
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D7D), Color(0xFF1E5D5D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D7D).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _navigateToCustomInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Create Custom Scenario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
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
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              // Home - Push to HomePage (as you requested)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              // Insights
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            } else if (index == 2) {
              // Tips
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TipsPage()),
              );
            } else if (index == 3) {
              // Already on Settings page, do nothing
            } else if (index == 4) {
              // Profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
              );
            }
          },
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

  Widget _buildScenarioCard({
    required String scenario,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Map<String, String> stats,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _saveScenario(scenario),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? iconColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 10,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D7D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats.entries.map((entry) {
                  Color statColor;
                  if (entry.key.contains('Green')) {
                    statColor = const Color(0xFF2ECC71);
                  } else if (entry.key.contains('Amber')) {
                    statColor = const Color(0xFFFFB84D);
                  } else if (entry.key.contains('Red')) {
                    statColor = const Color(0xFFE74C3C);
                  } else {
                    statColor = iconColor;
                  }

                  return Column(
                    children: [
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
