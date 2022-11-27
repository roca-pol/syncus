import 'package:dio/dio.dart';

class APIClient {
  final Dio _http;

  APIClient(String host) : _http = Dio(BaseOptions(baseUrl: host));

  void close() => _http.close();

  Future<Map<String, dynamic>> ping() async {
    var res = await _http.get('/ping');
    return res.data;
  }

  Future<Map<String, dynamic>> getJuncture(String id) async {
    var res = await _http.get('/juncture/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> createJuncture(
      String id, String trackURI, int timestamp) async {
    var res = await _http.post('/juncture', data: {
      'id': id,
      'trackURI': trackURI,
      'microsecondTimestamp': timestamp
    });
    return res.data;
  }
}
