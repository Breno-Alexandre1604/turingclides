import 'package:material_ui/material_ui.dart';

// Tema da interface de Leonardo, adaptado do protótipo da equipe e
// organizado em tokens para o modo claro e o escuro. As telas pedem papéis
// (superfície, contorno, cor do modo), nunca cores soltas.

/// Índigo da marca: semente do esquema e fundo do ícone do app.
const corDaMarca = Color(0xFF4255D4);

/// Escala de espaços, base 4. Itens do mesmo grupo usam passos curtos e
/// grupos diferentes usam passos longos; nenhuma tela usa número solto.
abstract final class Espaco {
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;

  /// Margem lateral das telas no celular.
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

/// Larguras máximas: em tablet, paisagem ou navegador o conteúdo não estica.
abstract final class Largura {
  static const double conteudo = 640;
  static const double jogo = 560;
}

/// Cantos arredondados: controles, cartões e ícones dos modos.
abstract final class Raio {
  static const double controle = 14;
  static const double cartao = 20;
  static const double icone = 16;
}

/// Números que mudam na tela (pontos, cronômetro, porcentagens) não
/// "dançam": todos os dígitos têm a mesma largura.
const numerosTabulares = [FontFeature.tabularFigures()];

/// Cor de um modo de jogo, com variantes que mantêm contraste no claro e no
/// escuro.
@immutable
class CorDeModo {
  const CorDeModo({
    required this.cor,
    required this.fundo,
    required this.sobreFundo,
  });

  /// Gera as variantes a partir de uma semente, como o Material 3 faz com a
  /// cor principal. `fidelity` mantém a cor viva, perto da semente.
  factory CorDeModo.deSemente(Color semente, Brightness brilho) {
    final esquema = ColorScheme.fromSeed(
      seedColor: semente,
      brightness: brilho,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return CorDeModo(
      cor: esquema.primary,
      fundo: esquema.primaryContainer,
      sobreFundo: esquema.onPrimaryContainer,
    );
  }

  /// Ícones, barras e bordas de destaque.
  final Color cor;

  /// Fundo de ícones e etiquetas do modo.
  final Color fundo;

  /// Texto e ícone sobre [fundo].
  final Color sobreFundo;

  static CorDeModo lerp(CorDeModo a, CorDeModo b, double t) => CorDeModo(
    cor: Color.lerp(a.cor, b.cor, t)!,
    fundo: Color.lerp(a.fundo, b.fundo, t)!,
    sobreFundo: Color.lerp(a.sobreFundo, b.sobreFundo, t)!,
  );
}

/// Cores do Turingclides que o Material 3 não tem: uma por modo de jogo, a
/// de acerto e a de recorde.
@immutable
class CoresDoApp extends ThemeExtension<CoresDoApp> {
  const CoresDoApp({
    required this.contaRapida,
    required this.matematica,
    required this.logica,
    required this.acerto,
    required this.recorde,
  });

  factory CoresDoApp.para(Brightness brilho) => CoresDoApp(
    contaRapida: CorDeModo.deSemente(const Color(0xFFF4511E), brilho),
    matematica: CorDeModo.deSemente(corDaMarca, brilho),
    logica: CorDeModo.deSemente(const Color(0xFF00897B), brilho),
    acerto: CorDeModo.deSemente(const Color(0xFF2E7D32), brilho),
    recorde: CorDeModo.deSemente(const Color(0xFFFFB300), brilho),
  );

  final CorDeModo contaRapida;
  final CorDeModo matematica;
  final CorDeModo logica;
  final CorDeModo acerto;
  final CorDeModo recorde;

  /// Em telas montadas fora do app (alguns testes), cai no tema claro.
  static CoresDoApp of(BuildContext context) =>
      Theme.of(context).extension<CoresDoApp>() ??
      CoresDoApp.para(Theme.of(context).brightness);

  /// Cor pelo nome gravado na partida ("Conta Rápida", "Quiz de Lógica"...).
  CorDeModo doModo(String modo) {
    if (modo.contains('Rápida')) return contaRapida;
    if (modo.contains('Lógica')) return logica;
    return matematica;
  }

  @override
  CoresDoApp copyWith({
    CorDeModo? contaRapida,
    CorDeModo? matematica,
    CorDeModo? logica,
    CorDeModo? acerto,
    CorDeModo? recorde,
  }) => CoresDoApp(
    contaRapida: contaRapida ?? this.contaRapida,
    matematica: matematica ?? this.matematica,
    logica: logica ?? this.logica,
    acerto: acerto ?? this.acerto,
    recorde: recorde ?? this.recorde,
  );

  @override
  CoresDoApp lerp(CoresDoApp? other, double t) {
    if (other == null) return this;
    return CoresDoApp(
      contaRapida: CorDeModo.lerp(contaRapida, other.contaRapida, t),
      matematica: CorDeModo.lerp(matematica, other.matematica, t),
      logica: CorDeModo.lerp(logica, other.logica, t),
      acerto: CorDeModo.lerp(acerto, other.acerto, t),
      recorde: CorDeModo.lerp(recorde, other.recorde, t),
    );
  }
}

/// Ícone de cada modo, igual na Home, no histórico e no progresso.
IconData iconeDoModo(String modo) {
  if (modo.contains('Rápida')) return Icons.bolt_rounded;
  if (modo.contains('Lógica')) return Icons.code_rounded;
  return Icons.functions_rounded;
}

final ThemeData temaClaro = _tema(Brightness.light);
final ThemeData temaEscuro = _tema(Brightness.dark);

ThemeData _tema(Brightness brilho) {
  final esquema = ColorScheme.fromSeed(
    seedColor: corDaMarca,
    brightness: brilho,
  );
  final escuro = brilho == Brightness.dark;

  // Claro: fundo cinza-azulado e cartões brancos, como no protótipo.
  // Escuro: fundo na superfície base e cartões um tom acima (elevação tonal).
  final fundoDaTela = escuro ? esquema.surface : esquema.surfaceContainerLow;
  final fundoDoCartao = escuro
      ? esquema.surfaceContainer
      : esquema.surfaceContainerLowest;
  final contorno = esquema.outlineVariant.withValues(alpha: escuro ? 0.5 : 0.7);

  // Escala de texto do Material 3, com peso maior nos títulos.
  final padrao = ThemeData(useMaterial3: true, colorScheme: esquema).textTheme;
  final texto = padrao.copyWith(
    headlineMedium: padrao.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    headlineSmall: padrao.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: padrao.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: padrao.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );

  final formaDeControle = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Raio.controle),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    textTheme: texto,
    scaffoldBackgroundColor: fundoDaTela,
    extensions: [CoresDoApp.para(brilho)],
    appBarTheme: AppBarThemeData(
      // Ao rolar o conteúdo por baixo, a barra ganha um tom para separar.
      backgroundColor: WidgetStateColor.resolveWith(
        (estados) => estados.contains(WidgetState.scrolledUnder)
            ? esquema.surfaceContainer
            : fundoDaTela,
      ),
      foregroundColor: esquema.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: texto.titleLarge?.copyWith(color: esquema.onSurface),
    ),
    cardTheme: CardThemeData(
      color: fundoDoCartao,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Raio.cartao),
        side: BorderSide(color: contorno),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: formaDeControle,
        textStyle: texto.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: formaDeControle,
        side: BorderSide(color: esquema.outlineVariant),
        textStyle: texto.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: formaDeControle,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: fundoDoCartao,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Raio.controle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Raio.controle),
        borderSide: BorderSide(color: esquema.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: esquema.outlineVariant),
      labelStyle: texto.labelLarge,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: esquema.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: Espaco.m),
    ),
    dividerTheme: DividerThemeData(color: contorno, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Raio.controle),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: contorno,
      labelStyle: texto.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: texto.titleSmall,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: esquema.surfaceContainerHighest,
      linearMinHeight: 8,
    ),
    // Gesto de voltar do Android com a prévia da tela anterior.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
}
