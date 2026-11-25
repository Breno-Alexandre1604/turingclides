import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Marca do Turingclides, a mesma do ícone do app: o triângulo de Euclides
/// sobre a fita de Turing, com uma célula para cada jogo (Conta Rápida,
/// Matemática e Lógica).
///
/// O desenho segue a grade de 108 unidades do ícone adaptativo do Android
/// (`android/app/src/main/res/drawable/ic_launcher_foreground.xml`). Aqui a
/// marca mostra só a área central, de 18 a 90.
class MarcaTuringclides extends StatelessWidget {
  const MarcaTuringclides({super.key, this.tamanho = 32});

  final double tamanho;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Turingclides',
    child: CustomPaint(
      size: Size.square(tamanho),
      painter: const _PintorDaMarca(),
    ),
  );
}

/// Cores fixas da marca: iguais no tema claro e no escuro, como o ícone.
abstract final class CoresDaMarca {
  static const fundo = corDaMarca;
  static const contaRapida = Color(0xFFFF7043);
  static const matematica = Color(0xFFAAB6FF);
  static const logica = Color(0xFF26C6B0);
}

class _PintorDaMarca extends CustomPainter {
  const _PintorDaMarca();

  static const _inicio = 18.0;
  static const _lado = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / _lado;
    canvas
      ..save()
      ..scale(escala);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, _lado, _lado),
        const Radius.circular(_lado * 0.28),
      ),
      Paint()..color = CoresDaMarca.fundo,
    );
    canvas.translate(-_inicio, -_inicio);

    final triangulo = Path()
      ..moveTo(54, 30.4)
      ..lineTo(70.5, 59)
      ..lineTo(37.5, 59)
      ..close();
    canvas.drawPath(
      triangulo,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round,
    );

    const celulas = [
      (32.0, CoresDaMarca.contaRapida),
      (47.5, CoresDaMarca.matematica),
      (63.0, CoresDaMarca.logica),
    ];
    for (final (x, cor) in celulas) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 64.5, 13, 13),
          const Radius.circular(3),
        ),
        Paint()..color = cor,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorDaMarca oldDelegate) => false;
}
