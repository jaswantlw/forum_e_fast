import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_service/models/comment.dart';
import 'package:firebase_service/models/forum_post.dart';
import 'package:firebase_service/models/reply.dart';

class FirebaseServiceException implements Exception {
  final String message;
  final String? code;

  FirebaseServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== AUTH FUNCTIONS ====================

  /// Sign up with email and password
  Future<User> signUp({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(
        'Sign up failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirebaseServiceException('Unexpected error during sign up: $e');
    }
  }

  /// Login with email and password
  Future<User> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(
        'Login failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirebaseServiceException('Unexpected error during login: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw FirebaseServiceException('Logout failed: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // ==================== FORUM POST FUNCTIONS ====================

  /// Create a new forum post
  Future<ForumPost> createPost({
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      final docRef = await _firestore.collection('posts').add({
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'timestamp': FieldValue.serverTimestamp(),
        'replyCount': 0,
      });

      final newPost = ForumPost(
        id: docRef.id,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        timestamp: DateTime.now(),
        replyCount: 0,
      );

      return newPost;
    } catch (e) {
      throw FirebaseServiceException('Failed to create post: $e');
    }
  }

  /// Get paginated posts with initial load
  Future<List<ForumPost>> getPostsPaginated({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ForumPost.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw FirebaseServiceException('Failed to fetch posts: $e');
    }
  }

  /// Get stream of posts for real-time updates
  Stream<List<ForumPost>> getPostsStream({required int limit}) {
    try {
      return _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => ForumPost.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }),
                )
                .toList(),
          );
    } catch (e) {
      throw FirebaseServiceException('Failed to get posts stream: $e');
    }
  }

  /// Get single post detail
  Future<ForumPost> getPostDetail(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        throw FirebaseServiceException('Post not found');
      }
      return ForumPost.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to fetch post detail: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw FirebaseServiceException('Failed to delete post: $e');
    }
  }

  // ==================== REPLY FUNCTIONS ====================

  /// Create a reply to a post
  Future<Reply> createReply({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
  }) async {
    try {
      // Create reply document
      final docRef = await _firestore.collection('replies').add({
        'postId': postId,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'commentCount': 0,
      });

      // Increment reply count on post
      await _firestore.collection('posts').doc(postId).update({
        'replyCount': FieldValue.increment(1),
      });

      final newReply = Reply(
        id: docRef.id,
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        timestamp: DateTime.now(),
        likes: 0,
        commentCount: 0,
      );

      return newReply;
    } catch (e) {
      throw FirebaseServiceException('Failed to create reply: $e');
    }
  }

  /// Get paginated replies for a post
  Future<List<Reply>> getRepliesPaginated({
    required String postId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('replies')
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => Reply.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw FirebaseServiceException('Failed to fetch replies: $e');
    }
  }

  /// Get stream of replies for real-time updates
  Stream<List<Reply>> getRepliesStream({
    required String postId,
    required int limit,
  }) {
    try {
      return _firestore
          .collection('replies')
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Reply.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }),
                )
                .toList(),
          );
    } catch (e) {
      throw FirebaseServiceException('Failed to get replies stream: $e');
    }
  }

  /// Like/unlike a reply
  Future<void> likeReply(String replyId) async {
    try {
      await _firestore.collection('replies').doc(replyId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to like reply: $e');
    }
  }

  /// Delete a reply
  Future<void> deleteReply(String replyId) async {
    try {
      // Get the reply to find postId
      final doc = await _firestore.collection('replies').doc(replyId).get();
      final postId = (doc.data() as Map<String, dynamic>)['postId'];

      // Delete reply
      await _firestore.collection('replies').doc(replyId).delete();

      // Decrement reply count on post
      await _firestore.collection('posts').doc(postId).update({
        'replyCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to delete reply: $e');
    }
  }

  // ==================== COMMENT FUNCTIONS ====================

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
      // Create comment document
      final docRef = await _firestore.collection('comments').add({
        'postId': postId,
        'replyId': replyId,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment comment count on reply
      await _firestore.collection('replies').doc(replyId).update({
        'commentCount': FieldValue.increment(1),
      });

      final newComment = Comment(
        id: docRef.id,
        postId: postId,
        replyId: replyId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        timestamp: DateTime.now(),
      );

      return newComment;
    } catch (e) {
      throw FirebaseServiceException('Failed to create comment: $e');
    }
  }

  /// Get paginated comments for a reply
  Future<List<Comment>> getCommentsPaginated({
    required String replyId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('comments')
          .where('replyId', isEqualTo: replyId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => Comment.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw FirebaseServiceException('Failed to fetch comments: $e');
    }
  }

  /// Get stream of comments for real-time updates
  Stream<List<Comment>> getCommentsStream({
    required String replyId,
    required int limit,
  }) {
    try {
      return _firestore
          .collection('comments')
          .where('replyId', isEqualTo: replyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Comment.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }),
                )
                .toList(),
          );
    } catch (e) {
      throw FirebaseServiceException('Failed to get comments stream: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      // Get the comment to find replyId
      final doc = await _firestore.collection('comments').doc(commentId).get();
      final replyId = (doc.data() as Map<String, dynamic>)['replyId'];

      // Delete comment
      await _firestore.collection('comments').doc(commentId).delete();

      // Decrement comment count on reply
      await _firestore.collection('replies').doc(replyId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw FirebaseServiceException('Failed to delete comment: $e');
    }
  }
}
