import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService() : _firestore = FirebaseFirestore.instance {
    _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  // Getting the collection from Firestore
  Future<QuerySnapshot> getCollection(String collectionPath) async {
    try {
      return await _firestore.collection(collectionPath).get();
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error getting collection');
      rethrow;
    }
  }

  // Getting a document from Firestore
  Future<DocumentSnapshot> getDocument(
      String collectionPath, String documentId) async {
    try {
      return await _firestore.collection(collectionPath).doc(documentId).get();
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error getting document');
      rethrow;
    }
  }

  // Getting a subcollection from Firestore
  Future<QuerySnapshot> getSubcollectionOrdered(
      String collectionPath, String documentId, String subcollection) async {
    try {
      return await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollection)
          .orderBy(FieldPath.documentId)
          .get();
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error getting subcollection');
      rethrow;
    }
  }

  // Setting a document in Firestore
  Future<void> setDocument(
      String collectionPath, String documentId, Map<String, dynamic> data,
      {bool merge = true}) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error setting document');
      rethrow;
    }
  }

  // Updating a document in Firestore
  Future<void> updateDocument(String collectionPath, String documentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error updating document');
      rethrow;
    }
  }

  CollectionReference getCollectionReference(String path) {
    return FirebaseFirestore.instance.collection(path);
  }

  // Get a DocumentReference for a document path
  DocumentReference getDocumentReference(String collectionPath, String docId) {
    return FirebaseFirestore.instance.collection(collectionPath).doc(docId);
  }

  // Existing method for ordered subcollection retrieval
  CollectionReference getOrderedSubcollection(
      String collectionPath, String docId, String subcollectionPath) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docId)
        .collection(subcollectionPath);
  }
}
