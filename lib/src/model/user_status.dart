class UserStatus {
  final String categoryID;
  final String levelID;

  UserStatus({
    required this.categoryID,
    required this.levelID,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': {categoryID: levelID},
    };
  }
}
