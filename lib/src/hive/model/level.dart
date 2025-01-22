import 'package:hive/hive.dart';
import 'package:kidsplay/src/model/level.dart';

part '../adapter/level.g.dart';

@HiveType(typeId: 1)
class HiveLevel extends HiveObject {
  HiveLevel({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
    required this.type,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String question;

  @HiveField(2)
  late String answer;

  @HiveField(3)
  late List<String> options;

  @HiveField(4)
  late String type;

  factory HiveLevel.fromFirestoreLevel(Level firestoreLevel) {
    return HiveLevel(
      id: firestoreLevel.id,
      question: firestoreLevel.question,
      answer: firestoreLevel.answer,
      options: firestoreLevel.options,
      type: firestoreLevel.type,
    );
  }
}
