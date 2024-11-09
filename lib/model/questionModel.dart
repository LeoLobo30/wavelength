// lib/models/question_model.dart
class QuestionModel {
  final String context;
  final String leftAttribute;
  final String rightAttribute;
  final double target;

  QuestionModel({
    required this.context,
    required this.leftAttribute,
    required this.rightAttribute,
    required this.target,
  });
}
