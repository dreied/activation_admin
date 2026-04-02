import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asymmetric/api.dart' show RSAPrivateKey, RSASignature;
import 'package:pointycastle/api.dart' show PrivateKeyParameter;
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';

class SignerService {
  static String sign(String message, RSAPrivateKey key) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));

    final bytes = Uint8List.fromList(utf8.encode(message));
    final sig = signer.generateSignature(bytes) as RSASignature;

    return base64UrlEncode(sig.bytes);
  }
}
