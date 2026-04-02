import 'dart:convert';

class PayloadBuilder {
  static String webPayload({
    required String deviceId,
    required DateTime expiry,
    required String plan,
  }) {
    final payload = {
      "deviceId": deviceId,
      "expiry": expiry.toIso8601String(),
      "plan": plan,
      "platform": "web",
      "issuedAt": DateTime.now().toIso8601String(),
    };

    return base64UrlEncode(utf8.encode(jsonEncode(payload)));
  }
}
