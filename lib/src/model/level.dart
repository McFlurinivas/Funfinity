import 'package:cloud_firestore/cloud_firestore.dart';

class Level {
  final String id;
  final String answer;
  final List<String> options;
  final String question;
  final String type;

  Level({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
    required this.type,
  });

  factory Level.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Level(
      id: doc.id,
      question: data['type'] == 'text' ? data['question'] : data['image'],
      answer: data['answer'],
      options: List<String>.from(data['options']),
      type: data['type'],
    );
  }
}
