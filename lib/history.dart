import 'package:ecoleaker/firebase_service.dart';
import 'package:ecoleaker/home.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ecoleaker/tips.dart';
import 'package:ecoleaker/setting_page.dart';
import 'package:ecoleaker/profilepage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _history = [];
  double _flowRate = 6.0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadFlowRate();
  }

  // Replace the _loadHistory method in history.dart with this improved version:

  Future<void> _loadHistory() async {
    print('🔵 [HISTORY] Starting to load history...');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if user is authenticated
      if (!_firebaseService.isAuthenticated) {
        print('⚠️ [HISTORY] User not authenticated');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to view history';
        });
        return;
      }

      print(
        '✅ [HISTORY] User authenticated: ${_firebaseService.currentUser?.uid}',
      );

      final prefs = await SharedPreferences.getInstance();

      // ALWAYS load from Firebase first (this is the source of truth)
      print('🔄 [HISTORY] Loading from Firebase...');
      final firebaseHistory = await _firebaseService.getWaterUsageHistory();

      if (firebaseHistory != null && firebaseHistory.isNotEmpty) {
        print(
          '✅ [HISTORY] Loaded ${firebaseHistory.length} records from Firebase',
        );

        // Sync Firebase data to SharedPreferences
        final historyJson = firebaseHistory
            .map((item) => json.encode(item))
            .toList();
        await prefs.setStringList('water_usage_history', historyJson);

        setState(() {
          _history = firebaseHistory;
          _isLoading = false;
        });

        print('✅ [HISTORY] Synced to SharedPreferences');
      } else {
        print('ℹ️ [HISTORY] No Firebase history found');

        // Clear any stale local data
        await prefs.remove('water_usage_history');

        setState(() {
          _history = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [HISTORY] Error loading history: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading history: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadFlowRate() async {
    try {
      // First, try to load from Firebase
      final firebaseFlowRate = await _firebaseService.getFlowRate();

      final prefs = await SharedPreferences.getInstance();

      if (firebaseFlowRate != null) {
        // Sync Firebase data to SharedPreferences
        await prefs.setDouble('flow_rate', firebaseFlowRate);
        setState(() {
          _flowRate = firebaseFlowRate;
        });
      } else {
        // Fallback to SharedPreferences
        setState(() {
          _flowRate = prefs.getDouble('flow_rate') ?? 6.0;
        });
      }
    } catch (e) {
      print('Error loading flow rate: $e');
    }
  }

  Future<void> _saveFlowRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('flow_rate', rate);

    // Save to Firebase
    try {
      await _firebaseService.saveFlowRate(rate);
      print('✅ Flow rate saved to Firebase');
    } catch (e) {
      print('❌ Error saving flow rate to Firebase: $e');
    }

    setState(() {
      _flowRate = rate;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // Clear history from SharedPreferences
        await prefs.remove('water_usage_history');
        await prefs.remove('previous_scenario');

        // Clear from Firebase
        print('🔄 Clearing history from Firebase...');
        await _firebaseService.saveWaterUsageHistory([]);
        print('✅ History cleared from Firebase');

        setState(() {
          _history = [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('History cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ Error clearing history: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ADD: Manual sync button for debugging
  Future<void> _manualSync() async {
    print('🔄 Manual sync initiated...');

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('water_usage_history') ?? [];

      if (historyJson.isEmpty) {
        throw Exception('No local history to sync');
      }

      final historyData = historyJson
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();

      await _firebaseService.saveWaterUsageHistory(historyData);

      print('✅ Manual sync successful');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully synced to Firebase!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload from Firebase to verify
      await _loadHistory();
    } catch (e) {
      print('❌ Manual sync failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFlowRateDialog() {
    final controller = TextEditingController(text: _flowRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Flow Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your tap flow rate (L/min):'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Flow Rate (L/min)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'L/min',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final rate = double.tryParse(controller.text);
              if (rate != null && rate > 0) {
                _saveFlowRate(rate);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D7D),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double _calculateVolume(int durationSeconds) {
    return (_flowRate * durationSeconds) / 60;
  }

  double _calculateCost(double volumeLitres) {
    final volumeM3 = volumeLitres / 1000;

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

    return subtotal + gst;
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
          'Usage History',
          style: TextStyle(
            color: Color(0xFF2E7D7D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF2E7D7D),
            ),
            onPressed: _showFlowRateDialog,
            tooltip: 'Set Flow Rate',
          ),
          // ADD: Manual sync button for debugging
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF2E7D7D)),
            onPressed: _manualSync,
            tooltip: 'Sync to Firebase',
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _history.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flow Rate Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB8E6E6),
                          const Color(0xFF8DD9D9),
                        ],
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
                            Icons.speed,
                            color: Color(0xFF2E7D7D),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Flow Rate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2E7D7D),
                                ),
                              ),
                              Text(
                                '$_flowRate L/min',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D7D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _showFlowRateDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E7D7D),
                          ),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Total Summary
                  _buildTotalSummary(),

                  const SizedBox(height: 24),

                  const Text(
                    'Daily Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D7D),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // History List
                  ...List.generate(_history.length, (index) {
                    final record = _history[_history.length - 1 - index];
                    return _buildHistoryCard(record, _history.length - index);
                  }),

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
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              // Already on Insights/History
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipsPage()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            } else if (index == 4) {
              Navigator.push(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Change scenarios to start tracking',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    double totalCost = 0;
    double totalVolume = 0;
    int totalGreen = 0;
    int totalAmber = 0;
    int totalRed = 0;

    for (var record in _history) {
      totalCost += record['cost'];
      totalVolume += record['volume'];
      totalGreen += record['greenActivations'] as int;
      totalAmber += record['amberActivations'] as int;
      totalRed += record['redActivations'] as int;
    }

    final totalActivations = totalGreen + totalAmber + totalRed;
    final greenPercent = totalActivations > 0
        ? (totalGreen / totalActivations * 100).round()
        : 0;
    final amberPercent = totalActivations > 0
        ? (totalAmber / totalActivations * 100).round()
        : 0;
    final redPercent = totalActivations > 0
        ? (totalRed / totalActivations * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
                  Icons.calculate,
                  color: Color(0xFF2E7D7D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D7D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Cost',
                  '\$${totalCost.toStringAsFixed(2)}',
                  Icons.attach_money,
                  const Color(0xFFE74C3C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Total Volume',
                  '${totalVolume.toStringAsFixed(1)} L',
                  Icons.water_drop,
                  const Color(0xFF3498DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Overall Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPercentBadge(
                '$greenPercent%',
                'Green',
                const Color(0xFF2ECC71),
              ),
              _buildPercentBadge(
                '$amberPercent%',
                'Amber',
                const Color(0xFFFFB84D),
              ),
              _buildPercentBadge(
                '$redPercent%',
                'Red',
                const Color(0xFFE74C3C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentBadge(String percent, String label, Color color) {
    return Column(
      children: [
        Text(
          percent,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record, int dayNumber) {
    final greenPercent = record['greenPercent'] ?? 0.0;
    final amberPercent = record['amberPercent'] ?? 0.0;
    final redPercent = record['redPercent'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D7D),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                record['date'],
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cost and Volume
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Cost',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${record['cost'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water Used',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record['volume'].toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF2ECC71),
                    value: greenPercent,
                    title: '${greenPercent.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFFB84D),
                    value: amberPercent,
                    title: '${amberPercent.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFE74C3C),
                    value: redPercent,
                    title: '${redPercent.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scenario Name
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record['scenarioName'] ?? 'Unknown Scenario',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D7D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
