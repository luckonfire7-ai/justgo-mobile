import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final api = ApiService();

  final groupNameCtrl = TextEditingController();
  final inviteCodeCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  Future<void> _createGroup() async {
    if (groupNameCtrl.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final group = await api.createGroup(groupNameCtrl.text.trim());
      if (!mounted) return;
      _showInviteCodeDialog(group['inviteCode']);
      Navigator.pop(context, group);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _joinGroup() async {
    if (inviteCodeCtrl.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final group = await api.joinGroup(inviteCodeCtrl.text.trim());
      if (!mounted) return;
      Navigator.pop(context, group);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => loading = false);
    }
  }

  void _showInviteCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Grup berhasil dibuat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bagikan kode ini ke teman touring kamu:'),
            const SizedBox(height: 12),
            Text(
              code,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Oke')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Group'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Buat grup'), Tab(text: 'Join via kode')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // Tab 1: jadi admin, buat grup baru
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: groupNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama grup',
                    hintText: 'Mis. Sunday Ride Bareng',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: loading ? null : _createGroup,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Buat grup & jadi admin'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu otomatis jadi admin dan bisa generate kode invite untuk anggota lain.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // Tab 2: join grup orang lain pakai kode
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: inviteCodeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Kode invite',
                    hintText: 'Mis. BXK92L',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: loading ? null : _joinGroup,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Gabung grup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
