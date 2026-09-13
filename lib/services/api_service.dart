import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // VPS NevaCloud kamu - ganti kalau nanti sudah pakai domain + HTTPS
  static const String baseUrl = 'http://163.61.58.25:4000';

  String? _token;
  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String plateNumber,
    required String password,
    required String motorId,
    required String registrationKey,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'plateNumber': plateNumber,
        'password': password,
        'motorId': motorId,
        'registrationKey': registrationKey,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(body['error'] ?? 'Registrasi gagal');
    }
    _token = body['token'];
    return body;
  }

  Future<List<dynamic>> searchMotors({String? category, String? search}) async {
    final query = {
      if (category != null) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('$baseUrl/motors').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(res.body);
  }

  // Dipakai saat user gak nemu motornya di daftar dan mau input sendiri
  Future<Map<String, dynamic>> addCustomMotor({
    required String category,
    required String brand,
    required String model,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/motors'),
      headers: _headers,
      body: jsonEncode({'category': category, 'brand': brand, 'model': model}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(body['error'] ?? 'Gagal menambahkan motor');
    }
    return body;
  }

  Future<Map<String, dynamic>> createGroup(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> joinGroup(String inviteCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/groups/join'),
      headers: _headers,
      body: jsonEncode({'inviteCode': inviteCode}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['error'] ?? 'Gagal join grup');
    }
    return body;
  }

  Future<Map<String, dynamic>> getVoiceToken(String groupId) async {
    final uri = Uri.parse('$baseUrl/voice/token').replace(
      queryParameters: {'groupId': groupId},
    );
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(res.body);
  }
}
