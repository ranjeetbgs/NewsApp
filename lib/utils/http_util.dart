import 'package:http/http.dart' as http;

class InciteHttp {

  static final InciteHttp _instance = InciteHttp._internal();

  factory InciteHttp() => _instance;

  InciteHttp._internal();

  final http.Client _client = http.Client();

  http.Client get client => _client;

  void close() {
    _client.close();
  }

}