import 'package:hive/hive.dart';

part '../adapter/category.g.dart';

@HiveType(typeId: 0)
class HiveCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  HiveCategory({
    required this.id,
    required this.name,
    required this.image,
  });
}
