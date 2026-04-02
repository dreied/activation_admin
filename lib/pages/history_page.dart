import 'package:flutter/material.dart';
import '../services/history_db.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ActivationRecord> history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    history = await HistoryDb.instance.getAllRecords();
    setState(() {});
  }

  Future<void> _editRecord(ActivationRecord record) async {
    final nameCtrl = TextEditingController(text: record.customerName);
    final phoneCtrl = TextEditingController(text: record.customerPhone);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Customer Info"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Customer Phone",
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result == true && record.id != null) {
      await HistoryDb.instance.updateCustomerInfo(
        id: record.id!,
        customerName:
            nameCtrl.text.trim().isEmpty ? 'Unknown' : nameCtrl.text.trim(),
        customerPhone: phoneCtrl.text.trim(),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("History")),
        body: history.isEmpty
            ? const Center(child: Text("No activations yet"))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final rec = history[i];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        "${rec.customerName} (${rec.app.toUpperCase()})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Device: ${rec.deviceId}\n"
                        "Phone: ${rec.customerPhone}\n"
                        "Created: ${rec.createdAt.toLocal()}",
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editRecord(rec),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
