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

    final text = Uri.encodeComponent(code);
    final uri = Uri.parse('https://wa.me/?text=$text');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open WhatsApp")),
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
