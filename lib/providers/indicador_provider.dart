import 'package:cotacoesnew/utils/indicador.dart';
import 'package:flutter/material.dart';

class IndicadoresProvider extends ChangeNotifier {
  final List<Indicador> _indicadores = [];
  List<Indicador> get indicadores => _indicadores;
  TextEditingController descricaoController = TextEditingController();

  void addIndicador(Indicador indicador) {
    _indicadores.add(indicador);
    notifyListeners();
  }

  void removerIndicador(Indicador indicador) {
    _indicadores.remove(indicador);
    notifyListeners();
  }

  void modificarIndicador(int index, String novoNome) {
    if (index >= 0 && index < _indicadores.length) {
      _indicadores[index].nome = novoNome;
      notifyListeners();
    }
  }

  void modIndUpdate(int index) {
    indicadores[index].nome = descricaoController.text;
  }
}
