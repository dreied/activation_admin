import 'package:flutter/material.dart';
import '../services/key_loader.dart';
import '../services/signer_service.dart';
import '../services/payload_builder.dart';
import '../widgets/activation_output_box.dart';
import '../services/history_db.dart';

class WebActivationPage extends StatefulWidget {
  const WebActivationPage({super.key});

  @override
  State<WebActivationPage> createState() => _WebActivationPageState();
}

class _WebActivationPageState extends State<WebActivationPage> {
  final TextEditingController deviceCtrl = TextEditingController();
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
    key = await KeyLoader.load("assets/keys/private_web.pem");
    setState(() {});
  }

  Future<void> _saveHistory(String deviceId, String code) async {
    final record = ActivationRecord(
      app: 'web',
      deviceId: deviceId,
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
    final deviceId = deviceCtrl.text.trim();
    if (deviceId.isEmpty || key == null) return;

    final payload = PayloadBuilder.webPayload(
      deviceId: deviceId,
      expiry: DateTime.now().add(const Duration(days: 365)),
      plan: "pro",
    );

    final signature = SignerService.sign(payload, key);
    code = "WEB-ACT:$payload.$signature";

    _saveHistory(deviceId, code);
    setState(() {});
  }

  @override
  void dispose() {
    deviceCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Web Activation")),
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
                "Device ID",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deviceCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Device ID",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generate,
                  child: const Text("Generate Web Code"),
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
