import 'package:dio/dio.dart';
import 'package:syncus/models/models.dart';

class APIClient {
  final Dio _http;

  APIClient(String host) : _http = Dio(BaseOptions(baseUrl: host));

  void close() => _http.close();

  Future<Map<String, dynamic>> ping() async {
    final res = await _http.get('/ping');
    return res.data;
  }

  Future<Juncture> getJuncture(String id) async {
    final res = await _http.get('/api/juncture/$id');
    return Juncture.fromJson(res.data);
  }

  Future<Juncture> createJuncture(Juncture juncture) async {
    final res = await _http.post('/api/juncture', data: juncture.toJson());
    return Juncture.fromJson(res.data);
  }
}
