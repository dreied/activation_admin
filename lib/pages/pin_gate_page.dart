import 'package:flutter/material.dart';
import 'menu_page.dart';

const String kAdminPin = "1234";

class PinGatePage extends StatefulWidget {
  const PinGatePage({super.key});

  @override
  State<PinGatePage> createState() => _PinGatePageState();
}

class _PinGatePageState extends State<PinGatePage> {
  final TextEditingController _pinCtrl = TextEditingController();
  String _error = "";

  void _checkPin() {
    if (_pinCtrl.text.trim() == kAdminPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuPage()),
      );
    } else {
      setState(() => _error = "Wrong PIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pinCtrl,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "PIN",
                errorText: _error.isEmpty ? null : _error,
              ),
              onSubmitted: (_) => _checkPin(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPin,
              child: const Text("Enter"),
            ),
          ],
        ),
      ),
    );
  }
}
