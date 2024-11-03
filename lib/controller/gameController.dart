// lib/controllers/game_controller.dart
import 'dart:math';

import 'package:sintonia_project/model/questionModel.dart';
enum Player { player1, player2 }

class GameController {
  final List<QuestionModel> allQuestions;
  late List<QuestionModel> questions;
  int player1Score = 0;
  int player2Score = 0;
  Player currentClueGiver = Player.player1;
  Player currentGuesser = Player.player2;
  late QuestionModel currentQuestion;
  bool isGameOverFlag = false;

  GameController()
      : allQuestions = [
          QuestionModel(
            context: 'Color',
            leftAttribute: 'Darker',
            rightAttribute: 'Lighter',
            target: Random().nextDouble(),
          ),
          QuestionModel(
            context: 'Temperature',
            leftAttribute: 'Cold',
            rightAttribute: 'Hot',
            target: Random().nextDouble(),
          ),
          QuestionModel(
            context: 'Mood',
            leftAttribute: 'Happy',
            rightAttribute: 'Sad',
            target: Random().nextDouble(),
          ),
          QuestionModel(
            context: 'Speed',
            leftAttribute: 'Slow',
            rightAttribute: 'Fast',
            target: Random().nextDouble(),
          ),
          QuestionModel(
            context: 'Taste',
            leftAttribute: 'Sweet',
            rightAttribute: 'Sour',
            target: Random().nextDouble(),
          ),
          // Add more questions as needed
        ] {
    resetGame();
  }

  void _getNewQuestion() {
    if (questions.isNotEmpty) {
      currentQuestion = questions.removeAt(0);
    } else {
      isGameOverFlag = true;
    }
  }

  void submitGuess(double guessValue) {
    // Calculate the difference between the guess and the target
    double difference = (guessValue - currentQuestion.target * 100).abs();

    // Adjust scoring thresholds based on the 0 to 100 range
    int points;
    if (difference < 2) {
      points = 10; // Close guess: within 5 points
    } else if (difference < 5) {
      points = 5; // Medium guess: within 10 points
    } else {
      points = 0; // Far or very far guess: more than 10 points
    }

    // Award points to the current guesser
    if (currentGuesser == Player.player1) {
      player1Score += points;
    } else {
      player2Score += points;
    }

    _swapRoles();
    _getNewQuestion();
  }


  void _swapRoles() {
    if (currentClueGiver == Player.player1) {
      currentClueGiver = Player.player2;
      currentGuesser = Player.player1;
    } else {
      currentClueGiver = Player.player1;
      currentGuesser = Player.player2;
    }
  }

  bool isGameOver() => isGameOverFlag;

  void resetGame() {
    player1Score = 0;
    player2Score = 0;
    questions = List.from(allQuestions);
    questions.shuffle();
    isGameOverFlag = false;
    currentClueGiver = Player.player1;
    currentGuesser = Player.player2;
    _getNewQuestion();
  }
}
