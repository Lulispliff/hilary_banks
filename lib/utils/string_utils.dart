import 'package:intl/intl.dart';

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

String extrairctCurrencyName(String fullName) {
  final index = fullName.indexOf('/');
  return index != -1 ? fullName.substring(0, index).trim() : fullName;
}

String extrairCurrencyPrice(String fullPrice) {
  final index = fullPrice.indexOf('/');
  return index != -1 ? fullPrice.substring(0, index).trim() : fullPrice;
}

String formatarCurrencyPrice(String currencyPrice) {
  double price = double.parse(currencyPrice);
  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatter.format(price);
}
