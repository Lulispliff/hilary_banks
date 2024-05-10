import 'package:cotacoesnew/utils/indicador.dart';

class Cotacao {
  final int id;
  final DateTime dataHora;
  final double valor;
  final Indicador indicador;
  bool isSelected;

  Cotacao({
    required this.id,
    required this.dataHora,
    required this.valor,
    required this.indicador,
    this.isSelected = false,
  });
}
