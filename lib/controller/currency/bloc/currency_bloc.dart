import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/services/currency_service.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository repository;

  CurrencyBloc({required this.repository}) : super(const CurrencyState()) {
    on<FetchCurrenciesAndRates>(_onFetchCurrenciesAndRates);
    on<ConvertCurrency>(_onConvertCurrency);
  }

  Future<void> _onFetchCurrenciesAndRates(
      FetchCurrenciesAndRates event, Emitter<CurrencyState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await repository.fetchExchangeRates();
      final quotes = data['quotes'] as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final lastUpdated = data['lastUpdated'] as String;

      final currencies = quotes.keys.map((key) => key.substring(3)).toList()
        ..sort();

      String? warningMessage;
      final nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (nowInSeconds - timestamp > 300) {
        // 300 seconds = 5 minutes
        warningMessage = '⚠️ Rates are older than 5 minutes.';
      }

      emit(state.copyWith(
        currencies: currencies,
        exchangeRates: quotes,
        lastUpdated: lastUpdated,
        timestamp: timestamp,
        isLoading: false,
        warning: warningMessage,
        error: null, // Clear any previous error
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onConvertCurrency(ConvertCurrency event, Emitter<CurrencyState> emit) {
    try {
      final amount = double.parse(event.amount);
      double convertedValue = 0.0;

      if (event.sourceCurrency == event.targetCurrency) {
        convertedValue = amount;
      } else {
        final sourceToUsdRate =
            1.0 / (state.exchangeRates['USD${event.sourceCurrency}'] ?? 1.0);
        final usdToTargetRate =
            state.exchangeRates['USD${event.targetCurrency}'] ?? 1.0;
        convertedValue = amount * sourceToUsdRate * usdToTargetRate;
      }

      emit(state.copyWith(convertedAmount: convertedValue.toStringAsFixed(2)));
    } catch (e) {
      emit(state.copyWith(error: 'Conversion error: $e'));
    }
  }
}
