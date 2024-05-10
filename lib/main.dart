import 'package:cotacoesnew/providers/cotacao_provider.dart';
import 'package:cotacoesnew/providers/indicador_provider.dart';
import 'package:cotacoesnew/screens/indicador_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CotacoesApp());
}

class CotacoesApp extends StatelessWidget {
  const CotacoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IndicadoresProvider()),
        ChangeNotifierProvider(create: (_) => CotacaoProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Cadastro de Cotações",
        home: IndicadorScreen(),
      ),
    );
  }
}
