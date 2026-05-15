import 'package:flutter/foundation.dart';

@immutable
class Reply {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime timestamp;
  final int likes;
  final int commentCount;

  const Reply({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.timestamp,
    required this.likes,
    required this.commentCount,
  });

  Reply copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    DateTime? timestamp,
    int? likes,
    int? commentCount,
  }) {
    return Reply(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reply &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          content == other.content &&
          authorId == other.authorId &&
          authorName == other.authorName &&
          authorAvatar == other.authorAvatar &&
          timestamp == other.timestamp &&
          likes == other.likes &&
          commentCount == other.commentCount;

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      content.hashCode ^
      authorId.hashCode ^
      authorName.hashCode ^
      authorAvatar.hashCode ^
      timestamp.hashCode ^
      likes.hashCode ^
      commentCount.hashCode;

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as String,
      postId: json['postId'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      timestamp: (json['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      likes: json['likes'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timestamp': timestamp,
      'likes': likes,
      'commentCount': commentCount,
    };
  }

  @override
  String toString() {
    return 'Reply(id: $id, postId: $postId, content: $content, authorId: $authorId, authorName: $authorName, authorAvatar: $authorAvatar, timestamp: $timestamp, likes: $likes, commentCount: $commentCount)';
  }
}
