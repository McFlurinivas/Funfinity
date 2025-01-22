import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  String image;

  Category({
    required this.name,
    required this.image,
    required this.id,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
