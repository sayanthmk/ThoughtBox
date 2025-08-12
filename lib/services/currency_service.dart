import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class CurrencyRepository {
  static const String _apiKey = 'a69dedc38f5137de957fa2651a67fb88';
  static const String _apiUrl = 'http://api.currencylayer.com/live';
  static const String _boxName = 'exchange_rates_box';
  static const String _cacheKey = 'exchange_rates_cache';

  // Cache is valid for 5 minutes, but we'll use a 30-minute grace period on failure
  static const Duration _cacheGracePeriod = Duration(minutes: 30);

  late Box _box;

  // Initialize Hive box
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  // Ensure box is initialized before use
  Future<void> _ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  Future<Map<String, dynamic>> fetchExchangeRates() async {
    await _ensureInitialized();

    final cachedData = _box.get(_cacheKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check for cached data first, so we can fall back to it
    Map<String, dynamic>? dataFromCache;
    if (cachedData != null) {
      dataFromCache = Map<String, dynamic>.from(cachedData);
      final timestamp = dataFromCache['timestamp'] as int;
      final cacheExpiry = timestamp * 1000 + _cacheGracePeriod.inMilliseconds;
      if (now > cacheExpiry) {
        dataFromCache = null; // Cache is too old, invalidate it
      }
    }

    try {
      final response =
          await http.get(Uri.parse('$_apiUrl?access_key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final quotes = data['quotes'] as Map<String, dynamic>;
          final timestamp = data['timestamp'] as int;

          final dataToCache = {
            'quotes': quotes,
            'timestamp': timestamp,
            'lastUpdated': _convertTimestampToDateTime(timestamp),
          };

          await _box.put(_cacheKey, dataToCache);
          return dataToCache;
        } else {
          throw Exception(data['error']['info']);
        }
      } else {
        throw Exception(
            'Failed to fetch exchange rates. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (dataFromCache != null) {
        // API failed, but we have valid cached data within the grace period
        return dataFromCache;
      }
      throw Exception('API failed and no valid cached data is available.');
    }
  }

  // Clear cache method
  Future<void> clearCache() async {
    await _ensureInitialized();
    await _box.delete(_cacheKey);
  }

  // Get cache info
  Future<Map<String, dynamic>?> getCacheInfo() async {
    await _ensureInitialized();
    final cachedData = _box.get(_cacheKey);
    if (cachedData != null) {
      return Map<String, dynamic>.from(cachedData);
    }
    return null;
  }

  // Check if cache is valid
  Future<bool> isCacheValid() async {
    await _ensureInitialized();
    final cachedData = _box.get(_cacheKey);
    if (cachedData == null) return false;

    final data = Map<String, dynamic>.from(cachedData);
    final timestamp = data['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheExpiry = timestamp * 1000 + _cacheGracePeriod.inMilliseconds;

    return now <= cacheExpiry;
  }

  // Close box when done (optional, for cleanup)
  Future<void> close() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  String _convertTimestampToDateTime(int timestamp) {
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    final dateTimeIst = dateTimeUtc.add(const Duration(hours: 5, minutes: 30));
    final formattedDateTime = '${_getMonthName(dateTimeIst.month)} '
        '${dateTimeIst.day}, '
        '${dateTimeIst.year} '
        '${dateTimeIst.hour.toString().padLeft(2, '0')}:'
        '${dateTimeIst.minute.toString().padLeft(2, '0')}:'
        '${dateTimeIst.second.toString().padLeft(2, '0')} IST';
    return formattedDateTime;
  }

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
