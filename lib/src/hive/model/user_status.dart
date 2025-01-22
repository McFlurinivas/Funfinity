import 'package:hive/hive.dart';

part '../adapter/user_status.g.dart';

@HiveType(typeId: 2)
class HiveUserStatus extends HiveObject {
  @HiveField(0)
  final String categoryID;

  @HiveField(1)
  final String levelID;

  HiveUserStatus({
    required this.categoryID,
    required this.levelID,
  });

  HiveUserStatus copyWith({
    String? categoryID,
    String? levelID,
  }) {
    return HiveUserStatus(
      categoryID: categoryID ?? this.categoryID,
      levelID: levelID ?? this.levelID,
    );
  }
}
