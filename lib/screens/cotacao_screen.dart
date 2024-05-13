import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cotacoesnew/providers/cotacao_provider.dart';
import 'package:cotacoesnew/screens/indicador_screen.dart';
import 'package:cotacoesnew/screens/grafico_screen.dart';
import 'package:cotacoesnew/utils/indicador.dart';
import 'package:cotacoesnew/utils/cotacao.dart';
import 'package:cotacoesnew/utils/string_utils.dart';

class CotacaoScreen extends StatefulWidget {
  const CotacaoScreen({super.key, required this.indicadores});

  final List<Indicador> indicadores;

  @override
  // ignore: library_private_types_in_public_api
  _CotacaoScreenState createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  TextEditingController valorController = TextEditingController();
  List<Cotacao> cotacoes = [];
  Indicador? selectedIndicador;
  String? selectedMoeda;
  int nextCotacaoId = 1;

  late Map<String, dynamic> _currencyData;
  List<String> _currencyNames = [];
  List<String> _currencyPrices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text("Cadastro de Cotações",
            style: TextStyle(fontSize: 26, color: Colors.white)),
      ),
      body: buildCotacoesScreen(),
      floatingActionButton: buildButtons(),
    );
  }

  Widget buildCotacoesScreen() {
    return Consumer<CotacaoProvider>(
      builder: (context, cotacaoProvider, _) {
        final cotacoes = cotacaoProvider.cotacoes;

        return Column(
          children: [
            Expanded(
              child: cotacoes.isEmpty
                  ? const Center(
                      child: Text(
                        "Sua lista de cotações está vazia",
                        style: TextStyle(fontSize: 19),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cotacoes.length,
                      itemBuilder: (context, index) {
                        final cotacao = cotacoes[index];
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(cotacao.dataHora);
                        final formattedValue = NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(cotacao.valor);

                        return ListTile(
                          title: Text(
                            "Indicador: ${capitalizeFirstLetter(cotacao.indicador.nome)} - Valor: $formattedValue - Data de registro: $formattedDate",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              cotacaoProvider.removeCotacao(cotacao);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            heroTag: "botao_API",
            tooltip: "Adicionar cotação API",
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: const Icon(Icons.route_rounded, color: Colors.white),
            onPressed: () {
              addCotacaoApiDialog();
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            heroTag: "botao_manual",
            tooltip: "Adicionar cotação manual",
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              addCotacaoDialog();
            },
          ),
        )
      ],
    );
  }

  void addCotacaoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Adicionar uma nova cotação",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Indicador>(
                  value: selectedIndicador,
                  onChanged: (Indicador? newValue) {
                    setState(() {
                      selectedIndicador = newValue;
                    });
                  },
                  items: widget.indicadores.map((Indicador indicador) {
                    return DropdownMenuItem<Indicador>(
                      value: indicador,
                      child: Text(capitalizeFirstLetter(indicador.nome)),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: "Selecione o indicador",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valorController,
                  cursorColor: Colors.grey,
                  decoration: const InputDecoration(
                    labelText: "Valor da cotação",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixText: "R\$ ",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                addCotacao();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Salvar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void addCotacaoApiDialog() {
    _fetchCurrencyData().then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Adicionar cotação - API",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMoeda,
                    decoration: const InputDecoration(
                      labelText: "Escolha a moeda/cotação",
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMoeda =
                            newValue; // Atualiza o estado com o novo valor selecionado
                      });
                    },
                    items: _currencyNames
                        .asMap()
                        .entries
                        .map((MapEntry<int, String> entry) {
                      //Transforma cada entrada em um item do menu
                      final currencyName =
                          entry.value; // Obtém o nome da moeda.
                      final currencyPrice =
                          _currencyPrices[entry.key]; // Obtém o preço da moeda

                      return DropdownMenuItem<String>(
                        value:
                            currencyName, // Define o valor do item como o nome da moeda
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currencyName),
                            Text(formatarCurrencyPrice(currencyPrice)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar",
                    style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () {
                  createIndicadorAndAddCotacao(context, selectedMoeda,
                      _currencyNames, _currencyPrices, nextCotacaoId);
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Salvar", style: TextStyle(color: Colors.blue)),
              )
            ],
          );
        },
      );
    });
  }

  void createIndicadorAndAddCotacao(
      BuildContext context,
      String? selectedMoeda,
      List<String> currencyNames,
      List<String> currencyPrices,
      int nextCotacaoId) {
    if (selectedMoeda != null) {
      // Obtém o índice da moeda selecionada na lista de nomes de moedas
      final currencyIndex = currencyNames.indexOf(selectedMoeda);

      // Verifica se a moeda selecionada foi encontrada na lista
      if (currencyIndex != -1) {
        // Obtém o nome e o preço da moeda com base no índice
        final currencyName = currencyNames[currencyIndex];
        final currencyPrice = currencyPrices[currencyIndex];

        // Cria um novo indicador com o ID e nome da moeda selecionada
        final indicador = Indicador(id: nextCotacaoId, nome: currencyName);

        // Cria uma nova cotação com o ID, data e valor da moeda selecionada, e o indicador associado
        final newCotacao = Cotacao(
          id: nextCotacaoId,
          dataHora: DateTime.now(),
          valor: double.parse(currencyPrice),
          indicador: indicador,
        );

        // Obtém o provedor de cotações do contexto atual e adiciona a nova cotação
        final cotacaoProvider =
            Provider.of<CotacaoProvider>(context, listen: false);
        cotacaoProvider.addCotacao(newCotacao);

        // Atualiza o estado para o próximo ID de cotação disponível
        setState(() {
          nextCotacaoId++;
        });
      }
    }
  }

  Future<void> _fetchCurrencyData() async {
    final url = Uri.parse(
        'https://economia.awesomeapi.com.br/json/all'); // Define a URL da API de onde buscar os dados das moedas

    final response = await http
        .get(url); // Faz uma requisição HTTP GET para a URL especificada

    if (response.statusCode == 200) {
      // Verifica se a resposta da requisição foi bem-sucedida (código 200)

      final Map<String, dynamic> data = jsonDecode(
          response.body); // Decodifica o corpo da resposta JSON em um mapa

      setState(() {
        _currencyData =
            data; // Atualiza os dados das moedas com os dados obtidos da resposta da API

        // Extrai os nomes das moedas a partir dos dados e os armazena na lista _currencyNames.
        _currencyNames = _currencyData.values
            .map((currencyInfo) => extrairctCurrencyName(currencyInfo['name']))
            .toList();

        // Extrai os preços das moedas a partir dos dados e os armazena na lista _currencyPrices.
        _currencyPrices = _currencyData.values
            .map((currencyInfo) => extrairCurrencyPrice(currencyInfo['high']))
            .toList();
      });
    }
  }

  void addCotacao() {
    final formattedValue = valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(formattedValue) ?? 0.0;

    if (selectedIndicador == null || valor <= 0.0) {
      return;
    }

    final cotacaoProvider =
        Provider.of<CotacaoProvider>(context, listen: false);

    final cotacao = Cotacao(
      id: nextCotacaoId,
      dataHora: DateTime.now(),
      valor: valor,
      indicador: selectedIndicador!,
    );

    cotacaoProvider.addCotacao(cotacao);

    setState(() {
      nextCotacaoId++;
      valorController.clear();
    });
  }

  void voltarPag() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const IndicadorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(-1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void avancarPag() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GraficoScreen(cotacoes: cotacoes),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
