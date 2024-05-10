import 'package:cotacoesnew/utils/cotacao.dart';
import 'package:cotacoesnew/utils/indicador.dart';
import 'package:flutter/material.dart';

class CotacaoProvider extends ChangeNotifier {
  final List<Cotacao> _cotacoes = [];
  final List<Indicador> indicadores = [];

  List<Cotacao> get cotacoes => _cotacoes;

  void addCotacao(Cotacao cotacao) {
    _cotacoes.add(cotacao);
    notifyListeners();
  }

  void removeCotacao(Cotacao cotacao) {
    _cotacoes.remove(cotacao);
    notifyListeners();
  }
}
