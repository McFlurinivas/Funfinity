import 'dart:io';

import 'package:kidsplay/src/hive/box/category_box.dart';
import 'package:kidsplay/src/hive/box/level_box.dart';
import 'package:kidsplay/src/hive/box/settings_box.dart';
import 'package:kidsplay/src/hive/box/user_status_box.dart';
import 'package:kidsplay/src/hive/model/category.dart';
import 'package:kidsplay/src/hive/model/level.dart';
import 'package:kidsplay/src/hive/model/settings.dart';
import 'package:kidsplay/src/hive/model/user_status.dart';
import 'package:kidsplay/src/service/hive_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';
import 'package:kidsplay/src/service/analytics_service.dart';

class HiveRepository {
  HiveService hiveService = HiveService();

  Future<void> putCategory(List<HiveCategory> category) async {
    try {
      for (var cat in category) {
        await hiveService.put(categoryBox, cat.id, cat);
      }
      await AnalyticsService.logEvent(
          name: 'put_category', parameters: {'count': category.length});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to put category');
    }
  }

  Future<List<HiveCategory>> getCategories() async {
    try {
      List<HiveCategory> categories = categoryBox.values
          .map((category) => category as HiveCategory)
          .toList();
      await AnalyticsService.logEvent(
          name: 'get_categories', parameters: {'count': categories.length});
      return categories;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to get categories');
      return [];
    }
  }

  Future<void> updateCategory(HiveCategory updatedCategory) async {
    try {
      if (!categoryBox.containsKey(updatedCategory.id)) {
        await hiveService.put(categoryBox, updatedCategory.id, updatedCategory);
      }
      await AnalyticsService.logEvent(
          name: 'update_category',
          parameters: {'category_id': updatedCategory.id});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to update category');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoryBox.delete(categoryId);
      await AnalyticsService.logEvent(
          name: 'delete_category', parameters: {'category_id': categoryId});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to delete category');
    }
  }

  Future<void> putLevels(String categoryId, List<HiveLevel> levels) async {
    try {
      await hiveService.put(levelBox, categoryId, levels);
      await AnalyticsService.logEvent(
          name: 'put_levels',
          parameters: {'category_id': categoryId, 'count': levels.length});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to put levels');
    }
  }

  Future<List> getLevels(String categoryId) async {
    try {
      List levels = levelBox.get(categoryId, defaultValue: []) ?? [];
      await AnalyticsService.logEvent(
          name: 'get_levels',
          parameters: {'category_id': categoryId, 'count': levels.length});
      return levels;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to get levels');
      return [];
    }
  }

  Future<void> updateLevels(
      String categoryId, List<HiveLevel> updatedLevels) async {
    try {
      List existingLevels = await getLevels(categoryId);
      Map<String, HiveLevel> updatedLevelsMap = {
        for (var level in updatedLevels) level.id: level
      };

      List newLevels = existingLevels.map((existingLevel) {
        if (updatedLevelsMap.containsKey(existingLevel.id)) {
          return updatedLevelsMap[existingLevel.id]!;
        }
        return existingLevel;
      }).toList();

      for (var updatedLevel in updatedLevels) {
        if (!existingLevels.any((level) => level.id == updatedLevel.id)) {
          newLevels.add(updatedLevel);
        }
      }

      await hiveService.put(levelBox, categoryId, newLevels);
      await AnalyticsService.logEvent(name: 'update_levels', parameters: {
        'category_id': categoryId,
        'count': updatedLevels.length
      });
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to update levels');
    }
  }

  Future<void> deleteLevels(String categoryId) async {
    try {
      await levelBox.delete(categoryId);
      await AnalyticsService.logEvent(
          name: 'delete_levels', parameters: {'category_id': categoryId});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to delete levels');
    }
  }

  Future<void> putUserProgress(List<HiveUserStatus> userProgress) async {
    try {
      for (var userStatus in userProgress) {
        await hiveService.put(userStatusBox, userStatus.categoryID, userStatus);
      }
      await AnalyticsService.logEvent(
          name: 'put_user_progress',
          parameters: {'count': userProgress.length});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to put user progress');
    }
  }

  Future<void> putSingleUserProgress(HiveUserStatus userProgress) async {
    try {
      if (!userStatusBox.containsKey(userProgress.categoryID)) {
        await hiveService.put(
            userStatusBox, userProgress.categoryID, userProgress);
      }
      await AnalyticsService.logEvent(
          name: 'put_single_user_progress',
          parameters: {'category_id': userProgress.categoryID});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to put single user progress');
    }
  }

  Future<List<HiveUserStatus>> getUserProgress() async {
    try {
      List<HiveUserStatus> userProgress = userStatusBox.values
          .map((userStatus) => userStatus as HiveUserStatus)
          .toList();
      await AnalyticsService.logEvent(
          name: 'get_user_progress',
          parameters: {'count': userProgress.length});
      return userProgress;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to get user progress');
      return [];
    }
  }

  Future<void> deleteUserProgress() async {
    try {
      await userStatusBox.clear();
      await AnalyticsService.logEvent(name: 'delete_user_progress');
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to delete user progress');
    }
  }

  Future<void> updateUserProgress(HiveUserStatus updatedUserProgress) async {
    try {
      if (userStatusBox.containsKey(updatedUserProgress.categoryID)) {
        await hiveService.put(
            userStatusBox, updatedUserProgress.categoryID, updatedUserProgress);
      }
      await AnalyticsService.logEvent(
          name: 'update_user_progress',
          parameters: {'category_id': updatedUserProgress.categoryID});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to update user progress');
    }
  }

  Future<void> deleteSingleUserProgress(String categoryId) async {
    try {
      await userStatusBox.delete(categoryId);
      await AnalyticsService.logEvent(
          name: 'delete_single_user_progress',
          parameters: {'category_id': categoryId});
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace,
          reason: 'Failed to delete single user progress');
    }
  }

  Future<void> putSettings(HiveSettings settings) async {
    try {
      await hiveService.put(settingsBox, 'Settings', settings);
      await AnalyticsService.logEvent(name: 'put_settings', parameters: {
        'settings': [
          settings.isBgMusicPlaying,
          settings.isSfxMusicPlaying,
          settings.isVibrating
        ]
      });
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to put settings');
    }
  }

  HiveSettings getSettings() {
    try {
      HiveSettings? settings = settingsBox.get('Settings',
          defaultValue: HiveSettings(
              isBgMusicPlaying: true,
              isSfxMusicPlaying: true,
              isVibrating: true));
      AnalyticsService.logEvent(name: 'get_settings', parameters: {
        'settings': [
          settings!.isBgMusicPlaying,
          settings.isSfxMusicPlaying,
          settings.isVibrating
        ],
      });
      return settings;
    } catch (e, stackTrace) {
      CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to get settings');
      rethrow;
    }
  }

  Future<void> deleteMusic() async {
    try {
      await settingsBox.delete('isPlaying');
      await AnalyticsService.logEvent(name: 'delete_music');
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to delete music');
    }
  }

  Future<String> downloadLottie(
      String url, String fileName, String fileType) async {
    try {
      var filePath = await downloadFile(url, fileName, fileType);
      await AnalyticsService.logEvent(name: 'download_lottie', parameters: {
        'url': url,
        'file_name': fileName,
        'file_type': fileType
      });
      return filePath;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to download Lottie');
      return '';
    }
  }

  Future<String> getLottieFilePath(String fileName, String fileType) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName.$fileType';
    return File(filePath).exists().then((value) {
      AnalyticsService.logEvent(
          name: 'get_lottie_file_path',
          parameters: {'file_name': fileName, 'exists': value});
      if (value) {
        return filePath;
      } else {
        return '';
      }
    });
  }

  Future<String> downloadImageFile(String url, String filename) async {
    try {
      var filePath = await downloadImage(url, filename);
      await AnalyticsService.logEvent(
          name: 'download_image',
          parameters: {'url': url, 'file_name': filename, 'file_type': 'png'});
      return filePath;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Failed to download image');
      return '';
    }
  }

  Future<String> getImageFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename.png';
    return await File(filePath).exists().then((value) {
      if (value) {
        return filePath;
      } else {
        return '';
      }
    });
  }
}
