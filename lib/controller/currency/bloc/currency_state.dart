import 'package:equatable/equatable.dart';

class CurrencyState extends Equatable {
  final List<String> currencies;
  final String convertedAmount;
  final bool isLoading;
  final String? error;
  final String? warning; // New field for warning message
  final Map<String, dynamic> exchangeRates;
  final String? lastUpdated;
  final int? timestamp;

  const CurrencyState({
    this.currencies = const [],
    this.convertedAmount = '0.00',
    this.isLoading = false,
    this.error,
    this.warning,
    this.exchangeRates = const {},
    this.lastUpdated,
    this.timestamp,
  });

  CurrencyState copyWith({
    List<String>? currencies,
    String? convertedAmount,
    bool? isLoading,
    String? error,
    String? warning,
    Map<String, dynamic>? exchangeRates,
    String? lastUpdated,
    int? timestamp,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      warning: warning,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        currencies,
        convertedAmount,
        isLoading,
        error,
        warning,
        exchangeRates,
        lastUpdated,
        timestamp
      ];
}
