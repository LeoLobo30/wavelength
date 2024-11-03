import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  double _rotationAngle = 0.0; // Ângulo de rotação do ponteiro

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter, // Alinha os elementos pela base
        children: [
          // Semicírculo de fundo
          Positioned(
            bottom: 0, // Define a base do semicírculo no fundo do layout
            child: CustomPaint(
              size: const Size(400, 200), // Aumenta o tamanho do semicírculo
              painter: SemiCirclePainter(),
            ),
          ),
          // Ponteiro rotacionável
          Positioned(
            bottom: 0, // Alinha a base do ponteiro com a base do semicírculo
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()..rotateZ(_rotationAngle),
              child: SvgPicture.asset(
                'assets/image/game/arrow.svg',
                width: 60,
                height: 180, // Ajusta a altura do ponteiro conforme necessário
              ),
            ),
          ),
          // Controle de rotação
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _rotationAngle += details.delta.dx * 0.01;
                _rotationAngle = _rotationAngle.clamp(-math.pi / 2, math.pi / 2);
              });
            },
          ),
        ],
      ),
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    // Desenha o semicírculo maior
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height), // Centro no meio do semicírculo
        radius: size.width / 2,
      ),
      math.pi, // Início no ponto de 180 graus (esquerda do semicírculo)
      math.pi, // Varre 180 graus para formar o semicírculo
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
