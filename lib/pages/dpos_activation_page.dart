import 'package:flutter/material.dart';
import '../services/key_loader.dart';
import '../services/signer_service.dart';
import '../widgets/activation_output_box.dart';
import '../services/history_db.dart';

class DPOSActivationPage extends StatefulWidget {
  const DPOSActivationPage({super.key});

  @override
  State<DPOSActivationPage> createState() => _DPOSActivationPageState();
}

class _DPOSActivationPageState extends State<DPOSActivationPage> {
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
    key = await KeyLoader.load("assets/keys/private_dpos.pem");
    setState(() {});
  }

  Future<void> _saveHistory(String fp, String code) async {
    final record = ActivationRecord(
      app: 'dpos',
      deviceId: fp,
      customerName:
          nameCtrl.text.trim().isEmpty ? 'Unknown' : nameCtrl.text.trim(),
      customerPhone: phoneCtrl.text.trim(),
      activationCode: code,
      createdAt: DateTime.now(),
      synced: false,
    );
    await HistoryDb.instance.upsertByAppAndDevice(record);
  }

  void generate() {
    final fp = fpCtrl.text.trim();
    if (fp.isEmpty || key == null) return;

    code = SignerService.sign(fp, key);
    _saveHistory(fp, code);
    setState(() {});
  }

  @override
  void dispose() {
    fpCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("DPOS Activation")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customer Info",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              const Text(
                "Device Fingerprint",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generate,
                  child: const Text("Generate DPOS Code"),
                ),
              ),
              const SizedBox(height: 20),
              ActivationOutputBox(code: code),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
