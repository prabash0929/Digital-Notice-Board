import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String description; // Using description as 'content'
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? publishAt;
  final DateTime? expiresAt;
  final bool isPinned;
  final bool isUrgent;
  final String status; // draft, pending, approved, rejected
  final String? mediaUrl;
  final String? summary; // AI generated
  final List<String> boardIds;
  final String authorId;
  final int views;
  final int likes;
  final int dislikes;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    this.publishAt,
    this.expiresAt,
    this.isPinned = false,
    this.isUrgent = false,
    this.status = 'approved',
    this.mediaUrl,
    this.summary,
    this.boardIds = const ['main'],
    required this.authorId,
    this.views = 0,
    this.likes = 0,
    this.dislikes = 0,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishAt: (data['publishAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isPinned: data['isPinned'] ?? false,
      isUrgent: data['isUrgent'] ?? false,
      status: data['status'] ?? 'approved',
      mediaUrl: data['mediaUrl'],
      summary: data['summary'],
      boardIds: List<String>.from(data['boardIds'] ?? ['main']),
      authorId: data['authorId'] ?? '',
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      if (publishAt != null) 'publishAt': Timestamp.fromDate(publishAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'isPinned': isPinned,
      'isUrgent': isUrgent,
      'status': status,
      'mediaUrl': mediaUrl,
      'summary': summary,
      'boardIds': boardIds,
      'authorId': authorId,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  Notice copyWith({
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    bool? isPinned,
    bool? isUrgent,
    String? status,
    int? views,
    int? likes,
    int? dislikes,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      publishAt: publishAt,
      expiresAt: expiresAt,
      isPinned: isPinned ?? this.isPinned,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      mediaUrl: mediaUrl,
      summary: summary,
      boardIds: boardIds,
      authorId: authorId,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }
}
