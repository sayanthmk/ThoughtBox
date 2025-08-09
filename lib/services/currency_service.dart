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

  String _convertTimestampToDateTime(int timestamp) {
    // Convert timestamp (seconds) to DateTime
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

    // Convert to IST (UTC+5:30)
    final dateTimeIst = dateTimeUtc.add(const Duration(hours: 5, minutes: 30));

    // Format the date and time (e.g., "August 9, 2025 23:06:06 IST")
    final formattedDateTime = '${_getMonthName(dateTimeIst.month)} '
        '${dateTimeIst.day}, '
        '${dateTimeIst.year} '
        '${dateTimeIst.hour.toString().padLeft(2, '0')}:'
        '${dateTimeIst.minute.toString().padLeft(2, '0')}:'
        '${dateTimeIst.second.toString().padLeft(2, '0')} IST';

    return formattedDateTime;
  }

  /// Helper method to convert month number to month name
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}
