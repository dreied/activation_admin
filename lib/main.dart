import 'package:flutter/material.dart';
import 'pages/pin_gate_page.dart';
import 'services/history_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REMOVE THIS → await HistoryDb.instance.init();
  // The DB initializes automatically on first use.

  runApp(const AdminActivationApp());
}

class AdminActivationApp extends StatelessWidget {
  const AdminActivationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Activation Generator",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const PinGatePage(),
    );
  }
}
