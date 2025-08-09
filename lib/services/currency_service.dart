import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyRepository {
  static const String _apiKey = 'a69dedc38f5137de957fa2651a67fb88';
  static const String _apiUrl = 'http://api.currencylayer.com/live';

  Future<Map<String, dynamic>> fetchExchangeRates() async {
    final response = await http.get(Uri.parse('$_apiUrl?access_key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['quotes'];
      } else {
        throw Exception(data['error']['info']);
      }
    } else {
      throw Exception('Failed to fetch exchange rates.');
    }
  }
}
