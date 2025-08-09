import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class FetchCurrenciesAndRates extends CurrencyEvent {}

class ConvertCurrency extends CurrencyEvent {
  final String sourceCurrency;
  final String targetCurrency;
  final String amount;

  const ConvertCurrency({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [sourceCurrency, targetCurrency, amount];
}
