class MoedaModel {
  final String? code; // codigo de comparação da moeda
  final String? codein; // código de entrada da moeda
  final String? name; // nome da moeda
  final String? high; // maior valor atingido pela moeda
  final String? low; // menor valor atingido pela moeda
  final String? varBid; // variação do lance da moeda
  final String? pctChange; // porcentagem de variação do valor da moeda
  final String? bid; // valor atual de compra da moeda
  final String? ask; // valor atual de venda da moeda
  final String?
      timesTamp; // data e hora da ultima atualização dos dados da moeda
  final String? createDate; // a data de criação dos dados da moeda

  MoedaModel({
    this.code,
    this.codein,
    this.name,
    this.high,
    this.low,
    this.varBid,
    this.pctChange,
    this.bid,
    this.ask,
    this.timesTamp,
    this.createDate,
  });

  factory MoedaModel.fromMap(Map<String, dynamic> map) {
    return MoedaModel(
      code: map['code'],
      codein: map['codein'],
      name: map['name'],
      high: map['high'],
      low: map['low'],
      varBid: map['varBid'],
      pctChange: map['pctChange'],
      bid: map['bid'],
      ask: map['ask'],
      timesTamp: map['timesTamp'],
      createDate: map['createDate'],
    );
  }
}
