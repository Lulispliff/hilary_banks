import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cotacoesnew/providers/indicador_provider.dart';
import 'package:cotacoesnew/screens/cotacao_screen.dart';
import 'package:cotacoesnew/screens/grafico_screen.dart';
import 'package:cotacoesnew/utils/indicador.dart';
import 'package:cotacoesnew/utils/cotacao.dart';
import 'package:cotacoesnew/utils/string_utils.dart';

class IndicadorScreen extends StatefulWidget {
  const IndicadorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IndicadorScreenState createState() => _IndicadorScreenState();
}

class _IndicadorScreenState extends State<IndicadorScreen> {
  TextEditingController descricaoController = TextEditingController();
  Indicador? selectedIndicador;
  List<Cotacao> cotacoes = [];
  int nextIndicadorID = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text("Cadastro de Indicadores",
              style: TextStyle(fontSize: 26, color: Colors.white)),
        ),
        body: Consumer<IndicadoresProvider>(
          builder: (context, indicadoresProvider, child) {
            final indicadores = indicadoresProvider.indicadores;

            return indicadores.isEmpty
                ? const Center(
                    child: Text(
                      "Sua lista de indicadores está vazia",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: indicadores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          "Indicador: ${capitalizeFirstLetter(indicadores[index].nome)} - ID: ${indicadores[index].id}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => modificarIndicador(index),
                              icon: const Icon(Icons.create_sharp),
                            ),
                            IconButton(
                              onPressed: () {
                                indicadoresProvider
                                    .removerIndicador(indicadores[index]);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  );
          },
        ),
        floatingActionButton: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            onPressed: addIndicadorDialog,
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ));
  }

  void addIndicadorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Adicionar um novo indicador",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: descricaoController,
            cursorColor: Colors.grey,
            decoration: const InputDecoration(
              labelText: "Nome do indicador",
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                addIndicador();
                Navigator.of(context).pop();
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void modificarIndicadorDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Modificar indicador",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: descricaoController,
            decoration: const InputDecoration(
              labelText: "Novo nome",
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                modIndUpdate(index);
                Navigator.of(context).pop();
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void addIndicador() {
    final descricao = descricaoController.text;
    final indicador = Indicador(id: nextIndicadorID, nome: descricao);

    Provider.of<IndicadoresProvider>(context, listen: false)
        .addIndicador(indicador);

    setState(() {
      nextIndicadorID++;
      descricaoController.clear();
    });
  }

  void modificarIndicador(int index) {
    setState(() {
      selectedIndicador =
          Provider.of<IndicadoresProvider>(context, listen: false).indicadores[
              index]; // Seleciona o indicador com o índice especificado

      descricaoController.text = selectedIndicador!.nome;
    });

    modificarIndicadorDialog(index);
  }

  void modIndUpdate(int index) {
    setState(() {
      Provider.of<IndicadoresProvider>(context, listen: false)
          .indicadores[index]
          .nome = descricaoController.text;
      // Atribui o texto atual do controlador de descrição como o novo nome do indicador no índice especificado
    });
  }

  void avancarPag() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CotacaoScreen(
            indicadores:
                Provider.of<IndicadoresProvider>(context, listen: false)
                    .indicadores),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GraficoScreen(cotacoes: cotacoes),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
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
