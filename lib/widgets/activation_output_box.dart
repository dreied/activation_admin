import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class ActivationOutputBox extends StatelessWidget {
  final String code;
  const ActivationOutputBox({super.key, required this.code});

 Future<void> _sendWhatsApp(BuildContext context) async {
  if (code.isEmpty) return;

  // Copy to clipboard
  await Clipboard.setData(ClipboardData(text: code));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Copied")),
  );

  // Open WhatsApp home screen
  final uri = Uri.parse("whatsapp://app");

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("WhatsApp not installed")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Activation Code:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(code),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("Copy"),
              onPressed: () {
                
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Copied")),
                );
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              label: const Text("WhatsApp"),
              onPressed: () => _sendWhatsApp(context),
            ),
          ],
        ),
      ],
    );
  }
}


 /*fingerprint = await ActivationService.getFingerprint();

ElevatedButton.icon(
  icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
  label: const Text(
    "WhatsApp",
    style: TextStyle(color: Colors.white),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  ),
  onPressed: () {
    final phone = "963937749701"; // same number
    final message = Uri.encodeComponent(fingerprint); // send fingerprint
    final url = "https://wa.me/$phone?text=$message";

    launchUrl(Uri.parse(url));
  },
),*/