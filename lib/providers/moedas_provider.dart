import 'package:cotacoesnew/models/moeda_model.dart';
import 'package:flutter/material.dart';

class MoedaProvider extends ChangeNotifier {
  List<MoedaModel> _moedas = [];
  List<MoedaModel> get moedas => _moedas;

  void setMoedas(List<MoedaModel> moedas) {
    _moedas = moedas;
    notifyListeners();
  }
}
