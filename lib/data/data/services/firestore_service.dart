import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time stream of notices
  Stream<List<Notice>> getNoticesStream() {
    return _db
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList());
  }

  // Create notice
  Future<void> addNotice(Notice notice) async {
    try {
      await _db.collection('notices').doc(notice.id).set(notice.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update notice
  Future<void> updateNotice(Notice notice) async {
    try {
      await _db.collection('notices').doc(notice.id).update(notice.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotice(String id) async {
    try {
      await _db.collection('notices').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementViews(String id) async {
    try {
      await _db.collection('notices').doc(id).update({
        'views': FieldValue.increment(1)
      });
    } catch (e) {
      print('Notice not found for increment');
    }
  }

  Future<void> incrementLikes(String id) async {
    try { await _db.collection('notices').doc(id).update({'likes': FieldValue.increment(1)}); } catch (_) {}
  }
  
  Future<void> incrementDislikes(String id) async {
    try { await _db.collection('notices').doc(id).update({'dislikes': FieldValue.increment(1)}); } catch (_) {}
  }

  Stream<QuerySnapshot> getComments(String noticeId) {
    return _db
        .collection('notices')
        .doc(noticeId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addComment(String noticeId, String authorId, String text) async {
    await _db.collection('notices').doc(noticeId).collection('comments').add({
      'authorId': authorId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
