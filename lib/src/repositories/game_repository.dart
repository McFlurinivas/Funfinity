import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsplay/src/model/category.dart';
import 'package:kidsplay/src/model/level.dart';
import 'package:kidsplay/src/model/user_status.dart';
import 'package:kidsplay/src/service/analytics_service.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';
import 'package:kidsplay/src/service/firestore_service.dart';

class GameRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<Category>> fetchCategories() async {
    try {
      final categorySnapshot =
          await _firestoreService.getCollection('categories');
      await AnalyticsService.logEvent(name: 'fetch_categories');
      return categorySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error fetching categories');
      return [];
    }
  }

  Future<List<Level>> fetchLevelsFromCategory(String categoryId) async {
    try {
      final levelSnapshot = await _firestoreService.getSubcollectionOrdered(
          'categories', categoryId, 'levels');
      await AnalyticsService.logEvent(
          name: 'fetch_levels_from_category',
          parameters: {'categoryId': categoryId});
      List<Level> levels =
          levelSnapshot.docs.map((doc) => Level.fromFirestore(doc)).toList();

      return levels;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace,
          reason: 'Error fetching levels from category');
      return [];
    }
  }

  Future<int> fetchCurrentLevelIndex(String categoryId, String levelId) async {
    try {
      final levelSnapshot = await _firestoreService.getSubcollectionOrdered(
          'categories', categoryId, 'levels');
      await AnalyticsService.logEvent(
          name: 'fetch_current_level_index',
          parameters: {'categoryId': categoryId, 'levelId': levelId});
      return levelSnapshot.docs.indexWhere((doc) => doc.id == levelId);
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error fetching current level index');
      return 0;
    }
  }

  Future<String?> fetchFirstLevelId(String categoryId) async {
    try {
      final levelSnapshot = await _firestoreService.getSubcollectionOrdered(
          'categories', categoryId, 'levels');
      if (levelSnapshot.docs.isNotEmpty) {
        await AnalyticsService.logEvent(
            name: 'fetch_first_level_id',
            parameters: {'categoryId': categoryId});
        return levelSnapshot.docs.first.id;
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error fetching first level ID');
    }
    return null;
  }

  Future<UserStatus> ensureUserCategoryExists(
      String userId, String categoryId) async {
    try {
      UserStatus? userProgress = await fetchUserProgress(userId, categoryId);

      if (userProgress?.categoryID == categoryId) {
        await AnalyticsService.logEvent(
            name: 'user_category_exists',
            parameters: {'userId': userId, 'categoryId': categoryId});
        return userProgress!;
      } else if (userProgress == null) {
        final String? firstLevelId = await fetchFirstLevelId(categoryId);

        if (firstLevelId != null) {
          await setOrUpdateUserProgress(userId, categoryId, firstLevelId);
          await AnalyticsService.logEvent(
              name: 'user_category_created',
              parameters: {
                'userId': userId,
                'categoryId': categoryId,
                'levelId': firstLevelId
              });
          return UserStatus(categoryID: categoryId, levelID: firstLevelId);
        }
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e.toString(),
          stackTrace: stackTrace,
          reason: 'Error ensuring user category exists');
      rethrow;
    }
    throw Exception('Could not create user category for $categoryId');
  }

  Future<void> setOrUpdateUserProgress(
      String userId, String categoryId, String? newLevelId) async {
    try {
      final levelId = newLevelId ?? await fetchFirstLevelId(categoryId);

      if (levelId != null) {
        await updateUserProgress(userId, categoryId, levelId);
        await AnalyticsService.logEvent(
            name: 'set_or_update_user_progress',
            parameters: {
              'userId': userId,
              'categoryId': categoryId,
              'levelId': levelId
            });
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace,
          reason: 'Error setting or updating user progress');
    }
  }

  Future<void> updateUserProgress(
      String userId, String categoryId, String levelId) async {
    await _firestoreService.setDocument(
        'users',
        userId.toString(),
        {
          'status': {categoryId: levelId}
        },
        merge: true);
    await AnalyticsService.logEvent(
        name: 'set_or_update_user_progress',
        parameters: {
          'userId': userId,
          'categoryId': categoryId,
          'levelId': levelId
        });
  }

  Future<UserStatus?> fetchUserProgress(
      String userId, String categoryID) async {
    try {
      final userSnapshot = await _firestoreService.getDocument('users', userId);

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('status')) {
          var statusMap = userData['status'] as Map<String, dynamic>;
          if (statusMap.containsKey(categoryID)) {
            await AnalyticsService.logEvent(
                name: 'fetch_user_progress',
                parameters: {'userId': userId, 'categoryId': categoryID});
            return UserStatus(
                categoryID: categoryID, levelID: statusMap[categoryID]);
          }
        }
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error fetching user progress');
      rethrow;
    }
    return null;
  }

  Future<List<UserStatus>> fetchUserProgressForAllCategories(
      String userId) async {
    try {
      final userSnapshot = await _firestoreService.getDocument('users', userId);

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('status')) {
          var statusMap = userData['status'] as Map<String, dynamic>;
          await AnalyticsService.logEvent(
              name: 'fetch_user_progress_all_categories',
              parameters: {'userId': userId});
          return statusMap.entries
              .map((entry) =>
                  UserStatus(categoryID: entry.key, levelID: entry.value))
              .toList();
        }
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error fetching user progress');
      rethrow;
    }
    return [];
  }

  Stream<List<Level>> getLevelsStream(String categoryId) {
    return _firestoreService
        .getOrderedSubcollection('categories', categoryId, 'levels')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Level.fromFirestore(doc)).toList());
  }

  Stream<Category> getCategoryDeletionsStream() {
    return _firestoreService
        .getCollectionReference('categories')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.removed)
          .map((change) => Category.fromFirestore(change.doc))
          .first;
    });
  }
}
