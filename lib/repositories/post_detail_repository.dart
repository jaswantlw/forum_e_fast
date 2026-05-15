import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_service/firebase_service_exports.dart';

class PostDetailRepository {
  final FirebaseService _firebaseService;

  PostDetailRepository({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  /// Get single post detail
  Future<ForumPost> getPostDetail(String postId) async {
    try {
      return await _firebaseService.getPostDetail(postId);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a reply to a post
  Future<Reply> createReply({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      return await _firebaseService.createReply(
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated replies for a post
  Future<List<Reply>> getRepliesPaginated({
    required String postId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      return await _firebaseService.getRepliesPaginated(
        postId: postId,
        limit: limit,
        startAfter: startAfter,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get stream of replies
  Stream<List<Reply>> getRepliesStream({
    required String postId,
    required int limit,
  }) {
    return _firebaseService.getRepliesStream(postId: postId, limit: limit);
  }

  /// Create a comment on a reply
  Future<Comment> createComment({
    required String postId,
    required String replyId,
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      return await _firebaseService.createComment(
        postId: postId,
        replyId: replyId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated comments for a reply
  Future<List<Comment>> getCommentsPaginated({
    required String replyId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      return await _firebaseService.getCommentsPaginated(
        replyId: replyId,
        limit: limit,
        startAfter: startAfter,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get stream of comments
  Stream<List<Comment>> getCommentsStream({
    required String replyId,
    required int limit,
  }) {
    return _firebaseService.getCommentsStream(replyId: replyId, limit: limit);
  }

  /// Like a reply
  Future<void> likeReply(String replyId) async {
    try {
      await _firebaseService.likeReply(replyId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a reply
  Future<void> deleteReply(String replyId) async {
    try {
      await _firebaseService.deleteReply(replyId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firebaseService.deleteComment(commentId);
    } catch (e) {
      rethrow;
    }
  }
}
