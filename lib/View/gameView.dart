import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sintonia_project/controller/gameController.dart';

class GameView extends StatefulWidget {
  final GameController controller;

  GameView({required this.controller});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool showTarget = false;
  double playerGuess = 50; // Inicia no meio do slider (0-100)

  // Converte o valor do slider para ângulo
  double get rotationAngle => (playerGuess - 50) * (math.pi / 100);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleShowTarget() {
    setState(() {
      showTarget = !showTarget;
      if (showTarget) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _submitGuess() {
    widget.controller.submitGuess(playerGuess);
    setState(() {
      showTarget = false;
      _animationController.reverse();
      playerGuess = 50; // Reinicia o slider no meio
    });

    if (widget.controller.isGameOver()) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(
              'Player 1 Score: ${widget.controller.player1Score}\nPlayer 2 Score: ${widget.controller.player2Score}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.controller.resetGame();
                });
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Player clueGiver = widget.controller.currentClueGiver;
    Player guesser = widget.controller.currentGuesser;

    // Converte o target para um ângulo para ser mostrado no semicírculo (-pi/2 a pi/2)
    double targetAngle =
        (widget.controller.currentQuestion.target * math.pi) - (math.pi / 2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wavelength Game'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Adiciona o SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.controller.isGameOver()
                ? Center(
                    child: Text(
                      'Game Over!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display Current Roles
                      Text(
                        '${clueGiver == Player.player1 ? 'Player 1' : 'Player 2'} is the Clue-Giver',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${guesser == Player.player1 ? 'Player 1' : 'Player 2'} is the Guesser',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 30),
                      // Question Context
                      Text(
                        widget.controller.currentQuestion.context,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      // Attributes
                      Text(
                        '${widget.controller.currentQuestion.leftAttribute} <-> ${widget.controller.currentQuestion.rightAttribute}',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      // Target Indicator (for Clue-Giver)
                      if (clueGiver == Player.player1 ||
                          clueGiver == Player.player2)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _toggleShowTarget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: Text(
                                showTarget ? 'Hide Target' : 'Show Target',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      SizedBox(height: 20),
                      // Semicírculo com ponteiro rotacionável e marcador de target
                      Container(
                        width: double.infinity,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: 0,
                              child: CustomPaint(
                                size: Size(220, 110),
                                painter: SemiCirclePainter(),
                              ),
                            ),
                            Transform(
                              alignment: Alignment.bottomCenter,
                              transform: Matrix4.identity()
                                ..rotateZ(rotationAngle),
                              child: SvgPicture.asset(
                                'assets/image/game/arrow.svg',
                                width: 60,
                                height: 100,
                              ),
                            ),
                            // Exibe o marcador de target no semicírculo quando showTarget é verdadeiro
                            if (showTarget)
                              Transform(
                                alignment: Alignment.bottomCenter,
                                transform: Matrix4.identity()
                                  ..rotateZ(targetAngle),
                                child: Container(
                                  width: 3,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Guess Slider (for Guesser)
                      if (guesser == Player.player1 ||
                          guesser == Player.player2)
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 10,
                            thumbColor: Colors.blue,
                            activeTrackColor: Colors.blueAccent,
                            inactiveTrackColor: Colors.grey,
                          ),
                          child: Slider(
                            value: playerGuess,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: playerGuess.toStringAsFixed(0),
                            onChanged: (value) {
                              setState(() {
                                playerGuess = value;
                              });
                            },
                          ),
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitGuess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Submit Guess',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 30),
                      Divider(),
                      SizedBox(height: 10),
                      // Display Scores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Player 1',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${widget.controller.player1Score}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Player 2',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${widget.controller.player2Score}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
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

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height), radius: size.width / 2),
      math.pi,
      math.pi,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
