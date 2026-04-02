import 'package:flutter/material.dart';
import 'dpos_activation_page.dart';
import 'dpharma_activation_page.dart';
import 'web_activation_page.dart';
import 'history_page.dart';
import '../services/history_db.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<void> _syncWebActivations(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text("Syncing web activations...")),
    );

    final records = await HistoryDb.instance.getUnsyncedWebActivations();

    if (records.isEmpty) {
      scaffold.showSnackBar(
        const SnackBar(content: Text("No unsynced web activations")),
      );
      return;
    }

    const baseUrl = 'https://your-render-service.onrender.com';

    for (final rec in records) {
      try {
        final resp = await http.post(
          Uri.parse('$baseUrl/sync-offline-activation'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'deviceId': rec.deviceId,
            'activationCode': rec.activationCode,
            'customerName': rec.customerName,
            'customerPhone': rec.customerPhone,
            'createdAt': rec.createdAt.toIso8601String(),
          }),
        );

        if (resp.statusCode == 200 && rec.id != null) {
          await HistoryDb.instance.markSynced(rec.id!);
        }
      } catch (_) {}
    }

    scaffold.showSnackBar(
      const SnackBar(content: Text("Sync completed (check server logs)")),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Activation Generator")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _menuButton(
                context,
                icon: Icons.point_of_sale,
                label: "Generate for DPOS",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DPOSActivationPage()),
                ),
              ),
              const SizedBox(height: 10),
              _menuButton(
                context,
                icon: Icons.local_pharmacy,
                label: "Generate for DPharma",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DPharmaActivationPage()),
                ),
              ),
              const SizedBox(height: 10),
              _menuButton(
                context,
                icon: Icons.web,
                label: "Generate for Web",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WebActivationPage()),
                ),
              ),
              const SizedBox(height: 20),
              _menuButton(
                context,
                icon: Icons.history,
                label: "History",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
              const SizedBox(height: 20),
              _menuButton(
                context,
                icon: Icons.sync,
                label: "Sync Web Activations with Server",
                color: Colors.teal,
                onTap: () => _syncWebActivations(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
