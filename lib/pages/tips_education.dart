import 'package:flutter/material.dart';
import 'dart:math';



String _selectedRegion = 'MY';

class Tip {
  final String title;
  final String subtitle;

  Tip({required this.title, required this.subtitle});
}

final Map<String, Map<String, double>> _emissionFactors = {

  'MY': { // 马来西亚
    'vehicle': 0.192,
    'electricity': 0.566,
    'meat': 6.9,
    'vegetable': 2.0,
    'water': 0.0003,
    'waste': 0.45,
  },
  'GLOBAL': { // 备选：全球平均
    'vehicle': 0.21,
    'electricity': 0.42,
    'meat': 7.2,
    'vegetable': 2.5,
    'water': 0.00025,
    'waste': 0.5,
  },
};



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

  final _vehicleKmCtrl = TextEditingController();   // NEW
  final _publicKmCtrl = TextEditingController();    // NEW
  final _meatKgCtrl = TextEditingController();      // NEW
  final _vegKgCtrl  = TextEditingController();      // NEW
  final _waterLCtrl = TextEditingController();      // NEW
  final _wasteKgCtrl= TextEditingController();      // NEW
  final TextEditingController _milesController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();
  double? _carbonFootprint;

  void _calculateCarbonFootprint() {
    // 取输入
    final vehicleKm = double.tryParse(_vehicleKmCtrl.text) ?? 0;
    final publicKm  = double.tryParse(_publicKmCtrl.text) ?? 0;
    final electricity = double.tryParse(_energyController.text) ?? 0;
    final meatKg   = double.tryParse(_meatKgCtrl.text) ?? 0;
    final vegKg    = double.tryParse(_vegKgCtrl.text) ?? 0;
    final waterL   = double.tryParse(_waterLCtrl.text) ?? 0;
    final wasteKg  = double.tryParse(_wasteKgCtrl.text) ?? 0;

    // 拿系数
    final f = _emissionFactors[_selectedRegion]!;

    // 计算
    final transport = vehicleKm * f['vehicle']! + publicKm * 0.105; // 公交系数统一 0.105
    final power     = electricity * f['electricity']!;
    final diet      = meatKg * f['meat']! + vegKg * f['vegetable']!;
    final water     = waterL * f['water']!;
    final waste     = wasteKg * f['waste']!;

    final kgCo2 = transport + power + diet + water + waste;

    setState(() {
      _carbonFootprint = kgCo2 / 1000; //tons
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
        title: const Text('Tips & Education', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              // TODO: show about-dialog
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => _shuffleTips(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /* ───────────────── Tips Grid ───────────────── */
              displayedTips.isEmpty
                  ? const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
                  : GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final tip in displayedTips)
                    _TipCard(
                      title: tip.title,
                      subtitle: tip.subtitle,
                      onTap: () => _showTipDetail(tip),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              /* ───────────────── Calculator ───────────────── */
              Text(
                'Carbon Footprint Calculator',
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /* 地区选择 */
              Row(
                children: [
                  const Text('Region: '),
                  DropdownButton<String>(
                    value: _selectedRegion,
                    onChanged: (v) => setState(() => _selectedRegion = v!),
                    items: _emissionFactors.keys
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /* 交通: 私家车 & 公交 */
              TextField(
                controller: _vehicleKmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kilometres driven (car)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _publicKmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kilometres by public transport',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              /* 住宅用电 */
              TextField(
                controller: _energyController,
                decoration: const InputDecoration(
                  labelText: 'Electricity usage (kWh)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              /* 饮食 */
              TextField(
                controller: _meatKgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meat consumed (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _vegKgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Vegetables consumed (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              /* 水 & 垃圾 */
              TextField(
                controller: _waterLCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tap water used (litre)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _wasteKgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Waste generated (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              /* 计算按钮 */
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    textStyle: Theme.of(context).textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _calculateCarbonFootprint,
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(height: 16),

              if (_carbonFootprint != null)
                Text(
                  'Your carbon footprint: '
                      '${_carbonFootprint!.toStringAsFixed(2)} tons CO₂e',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),

      /* ─────────────── Bottom Nav ─────────────── */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
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
