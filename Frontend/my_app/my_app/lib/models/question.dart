/// question.dart
/// -------------
/// Data model for questions related to tasks or offers. Used for Q&A features in the app.
/// Fields: (list all fields here for clarity).
///
/// Suggestions:
/// - Keep this model simple and focused on question data.
/// - Document any mapping to/from backend or related models.
class Question {
  final String id;
  final String userId;
  final String questionText;
  final DateTime timestamp;

  Question({
    required this.id,
    required this.userId,
    required this.questionText,
    required this.timestamp,
  });
} 