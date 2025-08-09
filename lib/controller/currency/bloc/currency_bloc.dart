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
      final quotes = await repository.fetchExchangeRates();
      final currencies = quotes.keys.map((key) => key.substring(3)).toList()
        ..sort();

      emit(state.copyWith(
        currencies: currencies,
        exchangeRates: quotes,
        isLoading: false,
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
