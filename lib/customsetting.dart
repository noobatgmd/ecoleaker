import 'package:ecoleaker/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomInputPage extends StatefulWidget {
  const CustomInputPage({super.key});

  @override
  State<CustomInputPage> createState() => _CustomInputPageState();
}

class _CustomInputPageState extends State<CustomInputPage> {
  final _firebaseService = FirebaseService();

  // Wash Hands
  final _washHandsTotalController = TextEditingController();
  final _washHandsGreenController = TextEditingController();
  final _washHandsAmberController = TextEditingController();
  final _washHandsRedController = TextEditingController();

  // Wash Vegetables
  final _washVegTotalController = TextEditingController();
  final _washVegGreenController = TextEditingController();
  final _washVegAmberController = TextEditingController();
  final _washVegRedController = TextEditingController();

  // Showering
  final _showerTotalController = TextEditingController();
  final _showerGreenController = TextEditingController();
  final _showerAmberController = TextEditingController();
  final _showerRedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomData();

    // Add listeners to update activations when values change
    _washHandsTotalController.addListener(() => setState(() {}));
    _washHandsGreenController.addListener(() => setState(() {}));
    _washHandsAmberController.addListener(() => setState(() {}));
    _washHandsRedController.addListener(() => setState(() {}));

    _washVegTotalController.addListener(() => setState(() {}));
    _washVegGreenController.addListener(() => setState(() {}));
    _washVegAmberController.addListener(() => setState(() {}));
    _washVegRedController.addListener(() => setState(() {}));

    _showerTotalController.addListener(() => setState(() {}));
    _showerGreenController.addListener(() => setState(() {}));
    _showerAmberController.addListener(() => setState(() {}));
    _showerRedController.addListener(() => setState(() {}));
  }

  int _calculateActivation(String totalText, String percentText) {
    final total = int.tryParse(totalText) ?? 0;
    final percent = double.tryParse(percentText) ?? 0;
    return (total * percent / 100).round();
  }

  int get washHandsGreenAct => _calculateActivation(
    _washHandsTotalController.text,
    _washHandsGreenController.text,
  );
  int get washHandsAmberAct => _calculateActivation(
    _washHandsTotalController.text,
    _washHandsAmberController.text,
  );
  int get washHandsRedAct => _calculateActivation(
    _washHandsTotalController.text,
    _washHandsRedController.text,
  );

  int get washVegGreenAct => _calculateActivation(
    _washVegTotalController.text,
    _washVegGreenController.text,
  );
  int get washVegAmberAct => _calculateActivation(
    _washVegTotalController.text,
    _washVegAmberController.text,
  );
  int get washVegRedAct => _calculateActivation(
    _washVegTotalController.text,
    _washVegRedController.text,
  );

  int get showerGreenAct => _calculateActivation(
    _showerTotalController.text,
    _showerGreenController.text,
  );
  int get showerAmberAct => _calculateActivation(
    _showerTotalController.text,
    _showerAmberController.text,
  );
  int get showerRedAct => _calculateActivation(
    _showerTotalController.text,
    _showerRedController.text,
  );

  int get totalGreen => washHandsGreenAct + washVegGreenAct + showerGreenAct;
  int get totalAmber => washHandsAmberAct + washVegAmberAct + showerAmberAct;
  int get totalRed => washHandsRedAct + washVegRedAct + showerRedAct;

  int _calculateDuration(
    double green,
    double amber,
    double red,
    List<int> thresholds,
  ) {
    if (green >= amber && green >= red) {
      return thresholds[0];
    } else if (amber >= green && amber >= red) {
      return thresholds[1];
    } else {
      return thresholds[2];
    }
  }

  Future<void> _loadCustomData() async {
    // Load from Firebase first
    final firebaseData = await _firebaseService.getCustomScenarioData();

    if (firebaseData != null) {
      // Load from Firebase
      setState(() {
        _washHandsTotalController.text =
            firebaseData['washHandsTotal']?.toString() ?? '26';
        _washHandsGreenController.text =
            firebaseData['washHandsGreen']?.toString() ?? '30';
        _washHandsAmberController.text =
            firebaseData['washHandsAmber']?.toString() ?? '50';
        _washHandsRedController.text =
            firebaseData['washHandsRed']?.toString() ?? '20';

        _washVegTotalController.text =
            firebaseData['washVegTotal']?.toString() ?? '20';
        _washVegGreenController.text =
            firebaseData['washVegGreen']?.toString() ?? '35';
        _washVegAmberController.text =
            firebaseData['washVegAmber']?.toString() ?? '40';
        _washVegRedController.text =
            firebaseData['washVegRed']?.toString() ?? '25';

        _showerTotalController.text =
            firebaseData['showerTotal']?.toString() ?? '18';
        _showerGreenController.text =
            firebaseData['showerGreen']?.toString() ?? '40';
        _showerAmberController.text =
            firebaseData['showerAmber']?.toString() ?? '35';
        _showerRedController.text =
            firebaseData['showerRed']?.toString() ?? '25';
      });
    } else {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _washHandsTotalController.text =
            prefs.getInt('custom_washHandsTotal')?.toString() ?? '26';
        _washHandsGreenController.text =
            prefs.getDouble('custom_washHandsGreen')?.toString() ?? '30';
        _washHandsAmberController.text =
            prefs.getDouble('custom_washHandsAmber')?.toString() ?? '50';
        _washHandsRedController.text =
            prefs.getDouble('custom_washHandsRed')?.toString() ?? '20';

        _washVegTotalController.text =
            prefs.getInt('custom_washVegTotal')?.toString() ?? '20';
        _washVegGreenController.text =
            prefs.getDouble('custom_washVegGreen')?.toString() ?? '35';
        _washVegAmberController.text =
            prefs.getDouble('custom_washVegAmber')?.toString() ?? '40';
        _washVegRedController.text =
            prefs.getDouble('custom_washVegRed')?.toString() ?? '25';

        _showerTotalController.text =
            prefs.getInt('custom_showerTotal')?.toString() ?? '18';
        _showerGreenController.text =
            prefs.getDouble('custom_showerGreen')?.toString() ?? '40';
        _showerAmberController.text =
            prefs.getDouble('custom_showerAmber')?.toString() ?? '35';
        _showerRedController.text =
            prefs.getDouble('custom_showerRed')?.toString() ?? '25';
      });
    }
  }

  Future<void> _saveCustomData() async {
    final prefs = await SharedPreferences.getInstance();

    // Validate percentages
    final washHandsTotal =
        (double.tryParse(_washHandsGreenController.text) ?? 0) +
        (double.tryParse(_washHandsAmberController.text) ?? 0) +
        (double.tryParse(_washHandsRedController.text) ?? 0);

    final washVegTotal =
        (double.tryParse(_washVegGreenController.text) ?? 0) +
        (double.tryParse(_washVegAmberController.text) ?? 0) +
        (double.tryParse(_washVegRedController.text) ?? 0);

    final showerTotal =
        (double.tryParse(_showerGreenController.text) ?? 0) +
        (double.tryParse(_showerAmberController.text) ?? 0) +
        (double.tryParse(_showerRedController.text) ?? 0);

    if ((washHandsTotal - 100).abs() > 0.1 ||
        (washVegTotal - 100).abs() > 0.1 ||
        (showerTotal - 100).abs() > 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percentages for each activity must add up to 100%!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate durations
    final washHandsGreen = double.parse(_washHandsGreenController.text);
    final washHandsAmber = double.parse(_washHandsAmberController.text);
    final washHandsRed = double.parse(_washHandsRedController.text);
    final washHandsDuration = _calculateDuration(
      washHandsGreen,
      washHandsAmber,
      washHandsRed,
      [44, 45, 70],
    );

    final washVegGreen = double.parse(_washVegGreenController.text);
    final washVegAmber = double.parse(_washVegAmberController.text);
    final washVegRed = double.parse(_washVegRedController.text);
    final washVegDuration = _calculateDuration(
      washVegGreen,
      washVegAmber,
      washVegRed,
      [49, 50, 91],
    );

    final showerGreen = double.parse(_showerGreenController.text);
    final showerAmber = double.parse(_showerAmberController.text);
    final showerRed = double.parse(_showerRedController.text);
    final showerDuration = _calculateDuration(
      showerGreen,
      showerAmber,
      showerRed,
      [5, 6, 11],
    );

    // Prepare data for Firebase
    final customScenarioData = {
      'washHandsTotal': int.tryParse(_washHandsTotalController.text) ?? 0,
      'washHandsGreen': washHandsGreen,
      'washHandsAmber': washHandsAmber,
      'washHandsRed': washHandsRed,
      'washHandsDuration': washHandsDuration,
      'washHandsGreenAct': washHandsGreenAct,
      'washHandsAmberAct': washHandsAmberAct,
      'washHandsRedAct': washHandsRedAct,

      'washVegTotal': int.tryParse(_washVegTotalController.text) ?? 0,
      'washVegGreen': washVegGreen,
      'washVegAmber': washVegAmber,
      'washVegRed': washVegRed,
      'washVegDuration': washVegDuration,
      'washVegGreenAct': washVegGreenAct,
      'washVegAmberAct': washVegAmberAct,
      'washVegRedAct': washVegRedAct,

      'showerTotal': int.tryParse(_showerTotalController.text) ?? 0,
      'showerGreen': showerGreen,
      'showerAmber': showerAmber,
      'showerRed': showerRed,
      'showerDuration': showerDuration,
      'showerGreenAct': showerGreenAct,
      'showerAmberAct': showerAmberAct,
      'showerRedAct': showerRedAct,

      'totalGreen': totalGreen,
      'totalAmber': totalAmber,
      'totalRed': totalRed,
    };

    // Save to Firebase
    try {
      await _firebaseService.saveCustomScenarioData(customScenarioData);
    } catch (e) {
      print('Error saving to Firebase: $e');
    }

    // Also save to SharedPreferences for offline access
    await prefs.setInt(
      'custom_washHandsTotal',
      int.tryParse(_washHandsTotalController.text) ?? 0,
    );
    await prefs.setDouble('custom_washHandsGreen', washHandsGreen);
    await prefs.setDouble('custom_washHandsAmber', washHandsAmber);
    await prefs.setDouble('custom_washHandsRed', washHandsRed);
    await prefs.setInt('custom_washHandsDuration', washHandsDuration);
    await prefs.setInt('custom_washHandsGreenAct', washHandsGreenAct);
    await prefs.setInt('custom_washHandsAmberAct', washHandsAmberAct);
    await prefs.setInt('custom_washHandsRedAct', washHandsRedAct);

    await prefs.setInt(
      'custom_washVegTotal',
      int.tryParse(_washVegTotalController.text) ?? 0,
    );
    await prefs.setDouble('custom_washVegGreen', washVegGreen);
    await prefs.setDouble('custom_washVegAmber', washVegAmber);
    await prefs.setDouble('custom_washVegRed', washVegRed);
    await prefs.setInt('custom_washVegDuration', washVegDuration);
    await prefs.setInt('custom_washVegGreenAct', washVegGreenAct);
    await prefs.setInt('custom_washVegAmberAct', washVegAmberAct);
    await prefs.setInt('custom_washVegRedAct', washVegRedAct);

    await prefs.setInt(
      'custom_showerTotal',
      int.tryParse(_showerTotalController.text) ?? 0,
    );
    await prefs.setDouble('custom_showerGreen', showerGreen);
    await prefs.setDouble('custom_showerAmber', showerAmber);
    await prefs.setDouble('custom_showerRed', showerRed);
    await prefs.setInt('custom_showerDuration', showerDuration);
    await prefs.setInt('custom_showerGreenAct', showerGreenAct);
    await prefs.setInt('custom_showerAmberAct', showerAmberAct);
    await prefs.setInt('custom_showerRedAct', showerRedAct);

    await prefs.setInt('custom_totalGreen', totalGreen);
    await prefs.setInt('custom_totalAmber', totalAmber);
    await prefs.setInt('custom_totalRed', totalRed);

    await prefs.setString('water_scenario', 'custom');
    await prefs.setBool('scenario_just_selected', true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom scenario saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
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
          'Custom Scenario',
          style: TextStyle(
            color: Color(0xFF2E7D7D),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivitySection(
              'Wash Hands',
              Icons.wash_outlined,
              _washHandsTotalController,
              _washHandsGreenController,
              _washHandsAmberController,
              _washHandsRedController,
              washHandsGreenAct,
              washHandsAmberAct,
              washHandsRedAct,
            ),
            const SizedBox(height: 24),
            _buildActivitySection(
              'Wash Vegetables',
              Icons.eco_outlined,
              _washVegTotalController,
              _washVegGreenController,
              _washVegAmberController,
              _washVegRedController,
              washVegGreenAct,
              washVegAmberAct,
              washVegRedAct,
            ),
            const SizedBox(height: 24),
            _buildActivitySection(
              'Showering',
              Icons.shower_outlined,
              _showerTotalController,
              _showerGreenController,
              _showerAmberController,
              _showerRedController,
              showerGreenAct,
              showerAmberAct,
              showerRedAct,
            ),
            const SizedBox(height: 24),
            _buildTotalActivationsDisplay(),
            const SizedBox(height: 32),
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
                onPressed: _saveCustomData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Custom Scenario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(
    String title,
    IconData icon,
    TextEditingController totalController,
    TextEditingController greenController,
    TextEditingController amberController,
    TextEditingController redController,
    int greenAct,
    int amberAct,
    int redAct,
  ) {
    return Container(
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
          // Title with Total Activations
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D7D), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D7D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Total Activations: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D7D),
                      ),
                    ),
                    Container(
                      width: 60,
                      child: TextField(
                        controller: totalController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D7D),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(4),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Percentages:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Green %',
                  greenController,
                  const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'Amber %',
                  amberController,
                  const Color(0xFFFFB84D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'Red %',
                  redController,
                  const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Activations (Auto-calculated):',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActivationDisplay(
                  'Green',
                  greenAct,
                  const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivationDisplay(
                  'Amber',
                  amberAct,
                  const Color(0xFFFFB84D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivationDisplay(
                  'Red',
                  redAct,
                  const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivationDisplay(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
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

  Widget _buildTotalActivationsDisplay() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF2E7D7D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Activations (All Activities)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D7D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTotalBadge(
                  '$greenPercent%',
                  'Green',
                  totalGreen,
                  const Color(0xFF2ECC71),
                ),
                _buildTotalBadge(
                  '$amberPercent%',
                  'Amber',
                  totalAmber,
                  const Color(0xFFFFB84D),
                ),
                _buildTotalBadge(
                  '$redPercent%',
                  'Red',
                  totalRed,
                  const Color(0xFFE74C3C),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBadge(
    String percentage,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          percentage,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '($count)',
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _washHandsTotalController.dispose();
    _washHandsGreenController.dispose();
    _washHandsAmberController.dispose();
    _washHandsRedController.dispose();

    _washVegTotalController.dispose();
    _washVegGreenController.dispose();
    _washVegAmberController.dispose();
    _washVegRedController.dispose();

    _showerTotalController.dispose();
    _showerGreenController.dispose();
    _showerAmberController.dispose();
    _showerRedController.dispose();
    super.dispose();
  }
}
