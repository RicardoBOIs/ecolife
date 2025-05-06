import 'package:flutter/material.dart';
import 'package:ecolife/tip_repository.dart';
import 'tips_education.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  /* ────── 弹出对话框 ────── */
  Future<void> _showAddTipDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _title   = TextEditingController();
    final _desc    = TextEditingController();
    final _url     = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Tip'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v!.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _url,
                  decoration: const InputDecoration(labelText: 'Reference URL'),
                  validator: (v) => v!.isEmpty ? 'Enter URL' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final tip = Tip(
                  title: _title.text.trim(),
                  subtitle: _desc.text.trim(),
                  reference: _url.text.trim(),
                );
                TipRepository.instance.addTip(tip);
                Navigator.pop(context);          // 关闭对话框
                setState(() {});                 // 刷新列表
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tip added ✔')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tips = TipRepository.instance.tips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green.shade700,
      ),

      /* ────── 主体：仅列表 ────── */
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) => ListTile(
          title: Text(tips[i].title),
          subtitle: Text(
            tips[i].subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),

      /* ────── FAB：新增 Tip ────── */
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: _showAddTipDialog,
      ),
    );
  }
}
