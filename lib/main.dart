import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco App',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TipsEducationScreen(),
    );
  }
}

class Tip {
  final String title;
  final String subtitle;

  Tip({required this.title, required this.subtitle});
}

class TipsEducationScreen extends StatefulWidget {
  @override
  _TipsEducationScreenState createState() => _TipsEducationScreenState();
}

class _TipsEducationScreenState extends State<TipsEducationScreen> {
  final List<Tip> allTips = [
    Tip(title: 'Use LED Bulbs', subtitle: 'Switching to LEDs can save energy.'),
    Tip(title: 'Conserve Water', subtitle: 'Fix leaks to save water.'),
    Tip(title: 'Recycle Regularly', subtitle: 'Separate waste to reduce landfill.'),
    Tip(title: 'Plant Trees', subtitle: 'Trees absorb CO2 and clean air.'),
    Tip(title: 'Take Shorter Showers', subtitle: 'Reduce water usage by limiting shower time.'),
    Tip(title: 'Unplug Devices', subtitle: 'Unplug electronics when not in use to save energy.'),
    Tip(title: 'Use Reusable Bags', subtitle: 'Replace plastic bags with reusable shopping bags.'),
    Tip(title: 'Compost Food Waste', subtitle: 'Composting reduces landfill waste and improves soil.'),
    Tip(title: 'Buy Local Produce', subtitle: 'Buying local reduces transportation emissions.'),
    Tip(title: 'Support Renewable Energy', subtitle: 'Choose renewable energy sources when possible.'),
  ];


  List<Tip> displayedTips = [];

  @override
  void initState() {
    super.initState();
    _shuffleTips();
  }

  void _shuffleTips() {
    setState(() {
      allTips.shuffle(Random());
      displayedTips = allTips.take(4).toList();
    });
  }

  final TextEditingController _milesController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();
  double? _carbonFootprint;

  void _calculateCarbonFootprint() {
    final miles = double.tryParse(_milesController.text) ?? 0;
    final energy = double.tryParse(_energyController.text) ?? 0;

    final kgCo2 = miles * 0.411 + energy * 0.475;
    final tonsCo2 = kgCo2 / 1000;

    setState(() {
      _carbonFootprint = tonsCo2;
    });
  }

  int _selectedIndex = 3;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showTipDetail(Tip tip) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                tip.subtitle,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips & Education', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              // Info action here
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _shuffleTips();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Tips Grid ---
                displayedTips.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                  physics: NeverScrollableScrollPhysics(),
                  children: displayedTips
                      .map((tip) => _TipCard(
                    title: tip.title,
                    subtitle: tip.subtitle,
                    onTap: () => _showTipDetail(tip),
                  ))
                      .toList(),
                ),
                SizedBox(height: 24),

                // --- Calculator Section ---
                Text(
                  'Carbon Footprint Calculator',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                TextField(
                  controller: _milesController,
                  decoration: InputDecoration(
                    labelText: 'Miles driven (in gas vehicle)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),

                TextField(
                  controller: _energyController,
                  decoration: InputDecoration(
                    labelText: 'Household energy usage (in kWh)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _calculateCarbonFootprint,
                    child: Text('Calculate'),
                  ),
                ),
                SizedBox(height: 12),

                if (_carbonFootprint != null)
                  Text(
                    'Your carbon footprint: ${_carbonFootprint!.toStringAsFixed(2)} tons CO₂e',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track Habit'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Tips & Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onTap;

  const _TipCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
