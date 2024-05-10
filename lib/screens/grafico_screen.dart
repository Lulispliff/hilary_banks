import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cotacoesnew/providers/cotacao_provider.dart';
import 'package:cotacoesnew/screens/indicador_screen.dart';
import 'package:cotacoesnew/screens/cotacao_screen.dart';
import 'package:cotacoesnew/utils/cotacao.dart';
import 'package:cotacoesnew/utils/string_utils.dart';

class GraficoScreen extends StatefulWidget {
  const GraficoScreen({super.key, required this.cotacoes});

  final List<Cotacao> cotacoes;

  @override
  GraficoScreenState createState() => GraficoScreenState();
}

class GraficoScreenState extends State<GraficoScreen> {
  @override
  Widget build(BuildContext context) {
    final cotacaoProvider =
        Provider.of<CotacaoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: voltarPag,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
            ),
            const Text(
              "Gráfico de Cotações",
              style: TextStyle(fontSize: 26, color: Colors.white),
            ),
            IconButton(
              onPressed: avancarPag,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
            ),
          ],
        ),
      ),
      body: buildGraficoInicialScreen(cotacaoProvider),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: "Gerar Gráfico",
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.auto_graph, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildGraficoInicialScreen(CotacaoProvider cotacaoProvider) {
    return Column(
      children: [
        Expanded(
          child: cotacaoProvider.cotacoes.isEmpty
              ? const Center(
                  child: Text(
                    "Você não tem cotações registradas para gerar o gráfico",
                    style: TextStyle(fontSize: 19),
                  ),
                )
              : ListView.builder(
                  itemCount: cotacaoProvider.cotacoes.length,
                  itemBuilder: (context, index) {
                    final cotacao = cotacaoProvider.cotacoes[index];
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(cotacao.dataHora);
                    String formattedValue =
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                            .format(cotacao.valor);

                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Indicador: ${capitalizeFirstLetter(cotacao.indicador.nome)} - Valor: $formattedValue - Data de registro: $formattedDate",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Checkbox(
                            activeColor: Colors.blue,
                            value: cotacao.isSelected,
                            onChanged: (value) {
                              setState(() {
                                cotacao.isSelected = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void avancarPag() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const IndicadorScreen(),
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

  void voltarPag() {
    final cotacaoProvider =
        Provider.of<CotacaoProvider>(context, listen: false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CotacaoScreen(indicadores: cotacaoProvider.indicadores),
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
}
