import 'package:flutter/material.dart';
import '../services/key_loader.dart';
import '../services/signer_service.dart';
import '../widgets/activation_output_box.dart';
import 'qr_scan_page.dart';
import '../services/history_db.dart';

class DPharmaActivationPage extends StatefulWidget {
  const DPharmaActivationPage({super.key});

  @override
  State<DPharmaActivationPage> createState() => _DPharmaActivationPageState();
}

class _DPharmaActivationPageState extends State<DPharmaActivationPage> {
  final TextEditingController fpCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String code = "";
  var key;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    key = await KeyLoader.load("assets/keys/private_dpharma.pem");
    setState(() {});
  }

  Future<void> _saveHistory(String fp, String code) async {
    final record = ActivationRecord(
      app: 'dpharma',
      deviceId: fp,
      customerName: nameCtrl.text.trim().isEmpty ? 'Unknown' : nameCtrl.text.trim(),
      customerPhone: phoneCtrl.text.trim(),
      activationCode: code,
      createdAt: DateTime.now(),
      synced: false,
    );
    await HistoryDb.instance.insertRecord(record);
  }

  void generate() {
    final fp = fpCtrl.text.trim();
    if (fp.isEmpty || key == null) return;

    code = SignerService.sign(fp, key);
    _saveHistory(fp, code);
    setState(() {});
  }

  Future<void> scanQr() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (result != null && result.isNotEmpty) {
      fpCtrl.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DPharma Activation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Customer Name",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Customer Phone",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fpCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Fingerprint",
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan QR"),
                    onPressed: scanQr,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: generate,
              child: const Text("Generate DPharma Code"),
            ),
            const SizedBox(height: 20),
            ActivationOutputBox(code: code),
          ],
        ),
      ),
    );
  }
}
