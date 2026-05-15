import 'package:flutter/foundation.dart';

@immutable
class ForumPost {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime timestamp;
  final int replyCount;

  const ForumPost({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.timestamp,
    required this.replyCount,
  });

  ForumPost copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    DateTime? timestamp,
    int? replyCount,
  }) {
    return ForumPost(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timestamp: timestamp ?? this.timestamp,
      replyCount: replyCount ?? this.replyCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForumPost &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          authorId == other.authorId &&
          authorName == other.authorName &&
          authorAvatar == other.authorAvatar &&
          timestamp == other.timestamp &&
          replyCount == other.replyCount;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      authorId.hashCode ^
      authorName.hashCode ^
      authorAvatar.hashCode ^
      timestamp.hashCode ^
      replyCount.hashCode;

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      timestamp: (json['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      replyCount: json['replyCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timestamp': timestamp,
      'replyCount': replyCount,
    };
  }

  @override
  String toString() {
    return 'ForumPost(id: $id, content: $content, authorId: $authorId, authorName: $authorName, authorAvatar: $authorAvatar, timestamp: $timestamp, replyCount: $replyCount)';
  }
}
