import 'package:flutter/services.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/asymmetric/api.dart' show RSAPrivateKey;



class KeyLoader {
  static Future<dynamic> load(String path) async {
    final pem = await rootBundle.loadString(path);
    return CryptoUtils.rsaPrivateKeyFromPem(pem);
  }
}
