import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/notice_model.dart';
import '../data/services/firestore_service.dart';

class NoticeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Notice> _notices = [];
  List<Notice> _filteredNotices = [];
  
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Academic', 'Events', 'Urgent', 'General'
  
  bool _isLoading = false;

  List<Notice> get notices => _filteredNotices;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  NoticeViewModel() {
    _listenToNotices();
  }

  void _listenToNotices() {
    _isLoading = true;
    notifyListeners();
    
    _firestoreService.getNoticesStream().listen((noticesData) {
      _notices = noticesData;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final now = DateTime.now();
    _filteredNotices = _notices.where((notice) {
      // 1. Check expiration
      if (notice.expiresAt != null && notice.expiresAt!.isBefore(now)) {
        return false;
      }
      // 2. Check publish scheduling
      if (notice.publishAt != null && notice.publishAt!.isAfter(now)) {
        return false;
      }
      // 3. Category matching
      final matchesCategory = _selectedCategory == 'All' || notice.category == _selectedCategory;
      // 4. Search text matching
      final matchesSearch = notice.title.toLowerCase().contains(_searchQuery) ||
                            notice.description.toLowerCase().contains(_searchQuery);
                            
      return matchesCategory && matchesSearch;
    }).toList();
    
    // Sort logic: Urgent > Pinned > Newest
    _filteredNotices.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> addNotice(Notice notice) async {
    await _firestoreService.addNotice(notice);
  }

  Future<void> updateNotice(Notice notice) async {
    await _firestoreService.updateNotice(notice);
  }

  Future<void> deleteNotice(String id) async {
    await _firestoreService.deleteNotice(id);
  }
  
  Future<void> incrementViews(String id) async {
    await _firestoreService.incrementViews(id);
  }

  Future<void> incrementLikes(String id) async {
    await _firestoreService.incrementLikes(id);
  }

  Future<void> incrementDislikes(String id) async {
    await _firestoreService.incrementDislikes(id);
  }

  Future<void> addComment(String noticeId, String authorId, String text) async {
    await _firestoreService.addComment(noticeId, authorId, text);
  }

  Stream<QuerySnapshot> getCommentsStream(String noticeId) {
    return _firestoreService.getComments(noticeId);
  }
}
