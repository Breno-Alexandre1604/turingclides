import 'package:material_ui/material_ui.dart';

import 'app/app_theme.dart';
import 'app/controle_de_tema.dart';
import 'app/rolagem.dart';
import 'data/dados_locais.dart';
import 'presentation/home/home_screen.dart';

void main() {
  runApp(const TuringclidesApp());
}

class TuringclidesApp extends StatefulWidget {
  const TuringclidesApp({super.key, this.dados});

  final DadosLocais? dados;

  @override
  State<TuringclidesApp> createState() => _TuringclidesAppState();
}

class _TuringclidesAppState extends State<TuringclidesApp> {
  late final _tema = ControleDeTema((widget.dados ?? dadosLocais).preferencias);

  @override
  void initState() {
    super.initState();
    _tema.carregar();
  }

  @override
  void dispose() {
    _tema.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _tema,
      builder: (context, modo, _) => MaterialApp(
        title: 'Turingclides',
        debugShowCheckedModeBanner: false,
        theme: temaClaro,
        darkTheme: temaEscuro,
        themeMode: modo,
        scrollBehavior: const RolagemDoApp(),
        // Datas, horas e textos dos componentes do Material em português.
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, tela) =>
            TemaEscolhido(controle: _tema, child: tela!),
        home: HomeScreen(dados: widget.dados),
      ),
    );
  }
}
