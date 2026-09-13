import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_map_screen.dart';

class MotorSelectScreen extends StatefulWidget {
  final String name;
  final String email;
  final String plateNumber;
  final String password;
  final String registrationKey;

  const MotorSelectScreen({
    super.key,
    required this.name,
    required this.email,
    required this.plateNumber,
    required this.password,
    required this.registrationKey,
  });

  @override
  State<MotorSelectScreen> createState() => _MotorSelectScreenState();
}

class _MotorSelectScreenState extends State<MotorSelectScreen>
    with SingleTickerProviderStateMixin {
  final categories = const [
    {'key': 'MATIC', 'label': 'Matic'},
    {'key': 'MANUAL', 'label': 'Manual'},
    {'key': 'SPORT', 'label': 'Sport'},
    {'key': 'ADVENTURE', 'label': 'Adventure'},
  ];

  late TabController _tabController;
  final api = ApiService();
  final searchCtrl = TextEditingController();
  List<dynamic> motors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_loadMotors);
    _loadMotors();
  }

  Future<void> _loadMotors() async {
    setState(() => loading = true);
    final category = categories[_tabController.index]['key'];
    final result = await api.searchMotors(
      category: category,
      search: searchCtrl.text,
    );
    setState(() {
      motors = result;
      loading = false;
    });
  }

  Future<void> _pilihMotor(dynamic motor) async {
    try {
      final result = await api.register(
        name: widget.name,
        email: widget.email,
        plateNumber: widget.plateNumber,
        password: widget.password,
        motorId: motor['id'],
        registrationKey: widget.registrationKey,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeMapScreen(
            userId: result['user']['id'],
            userName: result['user']['name'],
            motorLabel: '${motor['brand']} ${motor['model']}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _tambahMotorManual() async {
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final category = categories[_tabController.index]['key']!;

    final hasil = await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah motor kamu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kategori: ${categories[_tabController.index]['label']}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brandCtrl,
              decoration: const InputDecoration(labelText: 'Merek', hintText: 'Mis. Benelli'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(labelText: 'Model', hintText: 'Mis. TRK 502'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (brandCtrl.text.trim().isEmpty || modelCtrl.text.trim().isEmpty) return;
              try {
                final motor = await api.addCustomMotor(
                  category: category,
                  brand: brandCtrl.text.trim(),
                  model: modelCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(context, motor);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (hasil != null) {
      await _pilihMotor(hasil);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih motor kamu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => _loadMotors(),
              decoration: InputDecoration(
                hintText: 'Cari merek atau model, mis. Vario',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: categories.map((c) => Tab(text: c['label'])).toList(),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...motors.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
                                title: Text('${m['brand']} ${m['model']}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _pilihMotor(m),
                              ),
                            ),
                          )),
                      if (motors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Motor tidak ditemukan di daftar',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _tambahMotorManual,
                        icon: const Icon(Icons.add),
                        label: const Text('Gak ketemu? Tambah motor kamu'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
