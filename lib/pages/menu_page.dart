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

    // TODO: replace with your actual Render server URL
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
      } catch (_) {
        // ignore individual failures, show summary after
      }
    }

    scaffold.showSnackBar(
      const SnackBar(content: Text("Sync completed (check server logs)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activation Generator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("Generate for DPOS"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DPOSActivationPage()),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("Generate for DPharma"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DPharmaActivationPage()),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("Generate for Web"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WebActivationPage()),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("History"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text("Sync Web Activations with Server"),
              onPressed: () => _syncWebActivations(context),
            ),
          ],
        ),
      ),
    );
  }
}
