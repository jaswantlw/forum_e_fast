import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_service/firebase_service_exports.dart';

class ForumPostsRepository {
  final FirebaseService _firebaseService;

  ForumPostsRepository({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  /// Create a new forum post
  Future<ForumPost> createPost({
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      return await _firebaseService.createPost(
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated posts
  Future<List<ForumPost>> getPostsPaginated({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      return await _firebaseService.getPostsPaginated(
        limit: limit,
        startAfter: startAfter,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get stream of posts
  Stream<List<ForumPost>> getPostsStream({required int limit}) {
    return _firebaseService.getPostsStream(limit: limit);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firebaseService.deletePost(postId);
    } catch (e) {
      rethrow;
    }
  }
}
