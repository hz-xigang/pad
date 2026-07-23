
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtUtil {

  JwtUtil._();

  static void parseJwt(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    print(decodedToken);
  }

}
