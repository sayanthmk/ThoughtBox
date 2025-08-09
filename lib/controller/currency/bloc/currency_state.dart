import 'package:equatable/equatable.dart';

class CurrencyState extends Equatable {
  final List<String> currencies;
  final String convertedAmount;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> exchangeRates;

  const CurrencyState({
    this.currencies = const [],
    this.convertedAmount = '0.00',
    this.isLoading = false,
    this.error,
    this.exchangeRates = const {},
  });

  CurrencyState copyWith({
    List<String>? currencies,
    String? convertedAmount,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? exchangeRates,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }

  @override
  List<Object?> get props =>
      [currencies, convertedAmount, isLoading, error, exchangeRates];
}
