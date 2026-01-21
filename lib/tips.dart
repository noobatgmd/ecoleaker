import 'package:ecoleaker/history.dart';
import 'package:ecoleaker/home.dart';
import 'package:ecoleaker/profilepage.dart';
import 'package:ecoleaker/setting_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final Random _random = Random();
  String currentFact = "Tap a button to get started!";
  String currentCategory = "";

  final List<String> funFacts = [
    "Only 3% of Earth's water is fresh water 😮",
    "Out of that 3%, most is locked in ice ❄️",
    "Humans are about 60% water — basically walking water bottles.",
    "A dripping tap can waste thousands of litres a year 💸",
    "1 cubic metre of water = 1,000 litres (big bathtub vibes).",
    "A 10-minute shower can use more water than 10 toilet flushes.",
    "Singapore turns used water into NEWater — recycled but super clean.",
    "NEWater is so clean it's used in chip factories 🖥️",
    "Washing hands with tap running wastes water — tap off still clean!",
    "A toilet leak can waste more water than showering daily 😱",
    "Most people use the most water in the bathroom, not kitchen.",
    "Brushing teeth with tap on wastes up to 6 litres per minute.",
    "A full washing machine uses less water per shirt than half load.",
    "Water has no taste, but our brain still 'tastes' it.",
    "Hot water wastes more energy than cold water.",
    "Shorter showers = water saved + electricity saved ⚡",
    "Plants prefer morning watering, not midday sun.",
    "A bucket wash uses less water than a hose every time.",
    "Singapore has no natural lakes, only reservoirs.",
    "Rainwater helps fill Singapore's reservoirs 🌧️",
    "Earth is called the 'blue planet' because of water, not blue paint 🌍",
    "Drinking enough water helps brain work better 🧠",
    "Ice floats because frozen water is lighter than liquid water.",
    "Water can exist as solid, liquid, and gas — triple threat 💪",
    "A slow leak can waste more water than a fast spill over time.",
    "Turning off tap while soaping can cut water use by 50%.",
    "Dishwashing with basin saves more water than running tap.",
    "Water pressure doesn't mean better cleaning.",
    "Singapore imports water but also makes its own now.",
    "NEWater supplies up to 40% of Singapore's water needs.",
    "Every drop of water on Earth is millions of years old 🤯",
    "You can live weeks without food, but only days without water.",
    "Water helps control body temperature.",
    "A small habit change can save hundreds of dollars a year.",
    "Using water wisely helps the environment and wallet.",
    "Toilets use more water than taps in most homes.",
    "A running tap sounds harmless but costs money.",
    "Fixing leaks is one of the fastest ways to save water.",
    "Water-saving habits are easier than people think.",
    "Saving water does not mean poor hygiene 👍",
    "Every litre saved helps future generations.",
    "Water bills are based on volume, not speed of tap.",
    "Faster flow = water gone faster 💨",
    "Singapore plans water long-term, up to 2060 and beyond.",
    "Clean water is not guaranteed forever.",
    "Water conservation = national responsibility in SG 🇸🇬",
    "Small actions by many people matter a lot.",
    "Saving water also saves energy used to treat it.",
    "Smart water use is a life skill.",
    "The cheapest water is the water you don't waste 😄",
  ];

  final List<String> waterTips = [
    "Scrub dishes first, tap off, don't let it 'cry' nonstop.",
    "Veggie wash = use bowl, not waterfall.",
    "Veggie water can water plants — 2-in-1, very shiok.",
    "Waiting for hot water? Don't stare… catch the water.",
    "Wash rice like a pro, not like car wash.",
    "Dishwasher only run when full, not lonely.",
    "Scrap food off plates first — less water, less pain.",
    "Dripping tap = money dripping away 💸.",
    "Rinse mouth using cup, not Niagara Falls.",
    "Frozen food thaw naturally — patience also save water.",
    "Brush teeth? Tap off. Teeth still clean, don't worry.",
    "Short shower = water saved + faster life.",
    "Soap first, rinse later. Shower not concert.",
    "Bucket + dipper = classic but powerful.",
    "Leaking toilet? That one water vampire 🧛‍♂️.",
    "Toilet is not rubbish bin, later cry.",
    "Flush wisely, not every small thing also flush.",
    "Cold shower water? Collect, don't waste.",
    "Water-saving shower head = instant upgrade.",
    "Washing face, tap on–off, not on forever.",
    "Washing machine half full? No no no.",
    "Small load? Use low water setting, don't be extra.",
    "Last rinse water = perfect for mopping.",
    "Dirty clothes? Soak first, machine less angry.",
    "Don't rinse clothes under running tap — too drama.",
    "Check hoses — burst one time, whole house cry.",
    "Short cycle also can clean, trust technology.",
    "Hand-wash small items together, not one by one like slow motion.",
    "Clothes not dirty? Don't wash again lah.",
    "Bucket hand-wash = water control master.",
    "Sweep first, mop later. Don't flood house.",
    "Mop using bucket, not tap marathon.",
    "Leftover cleaning water? Toilet say thank you.",
    "Wash cleaning cloths together, team effort.",
    "Corridor not football field — no need hose.",
    "Spill clean fast, later no need big wash.",
    "Spray bottle > running tap.",
    "Bucket not swimming pool, don't overfill.",
    "Damp cloth enough, don't soak like nasi lemak.",
    "After using tap, twist until satisfied 😌.",
    "Water plants morning or evening — sun not stealing water.",
    "Plants need water, not drowning.",
    "Leftover drinking water? Plants happy.",
    "Wash car with bucket — hose too powerful.",
    "Tap fully closed, not 'almost'.",
    "See leak? Tell boss fast, be hero.",
    "Teach kids save water — future bills thank you.",
    "Every drop counts, even small small one.",
    "Use water with purpose, not freestyle.",
    "Save water = save money = everyone happy 🥳",
  ];

  void _getRandomFunFact() {
    setState(() {
      currentFact = funFacts[_random.nextInt(funFacts.length)];
      currentCategory = "Water Conservation Tip";
    });
  }

  void _getRandomWaterTip() {
    setState(() {
      currentFact = waterTips[_random.nextInt(waterTips.length)];
      currentCategory = "Water Saving Tip";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A7CA5), Color(0xFF2E6B8E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Water Drop Icon
              TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Wise Water Facts',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Save water, save the planet!',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 40),

              // Fact Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            currentCategory == "Water Saving Tip"
                                ? Icons.lightbulb
                                : currentCategory == "Water Conservation Tip"
                                ? Icons.eco
                                : Icons.water_drop_outlined,
                            color: const Color(0xFF3A7CA5),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentFact,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                height: 1.4,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentCategory.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A7CA5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '— $currentCategory',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3A7CA5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Fun Fact Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _getRandomFunFact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, size: 26),
                        SizedBox(width: 12),
                        Text(
                          'Give me a fun fact!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Water Saving Tip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _getRandomWaterTip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.water_drop, size: 26),
                        SizedBox(width: 12),
                        Text(
                          'Give me a Water Tip!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
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
          currentIndex: 2, // Tips is index 2
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              // Insights
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            } else if (index == 2) {
              // Already on Tips page, do nothing
            } else if (index == 3) {
              // Settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            } else if (index == 4) {
              // Profile
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
}
