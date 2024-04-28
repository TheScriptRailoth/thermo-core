import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://yourapi.com/api';

  Future<Map<String, dynamic>> calculateProperties(double pressure, double temperature) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calculate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'pressure': pressure,
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
