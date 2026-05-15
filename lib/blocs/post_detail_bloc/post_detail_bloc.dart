import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_e_fast/repositories/post_detail_repository.dart';

part 'post_detail_event.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostDetailRepository _postDetailRepository;

  // Pagination state for replies
  List<Reply> _currentReplies = [];
  DocumentSnapshot? _lastReplyDocument;
  bool _hasMoreReplies = true;

  // Pagination state for comments per reply
  Map<String, List<Comment>> _commentsPerReply = {};
  Map<String, DocumentSnapshot?> _lastCommentDocumentPerReply = {};
  Map<String, bool> _hasMoreCommentsPerReply = {};

  PostDetailBloc({required PostDetailRepository postDetailRepository})
    : _postDetailRepository = postDetailRepository,
      super(const PostDetailInitial()) {
    on<FetchPostDetailEvent>(_onFetchPostDetailEvent);
    on<FetchMoreRepliesEvent>(_onFetchMoreRepliesEvent);
    on<CreateReplyEvent>(_onCreateReplyEvent);
    on<FetchMoreCommentsEvent>(_onFetchMoreCommentsEvent);
    on<CreateCommentEvent>(_onCreateCommentEvent);
    on<LikeReplyEvent>(_onLikeReplyEvent);
    on<DeleteReplyEvent>(_onDeleteReplyEvent);
    on<DeleteCommentEvent>(_onDeleteCommentEvent);
  }

  /// Handle FetchPostDetailEvent
  Future<void> _onFetchPostDetailEvent(
    FetchPostDetailEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(const PostDetailLoading());
    try {
      final post = await _postDetailRepository.getPostDetail(event.postId);
      final replies = await _postDetailRepository.getRepliesPaginated(
        postId: event.postId,
        limit: event.repliesLimit,
      );

      _currentReplies = replies;
      _hasMoreReplies = replies.length == event.repliesLimit;
      _lastReplyDocument = null;

      emit(
        PostDetailLoaded(
          post: post,
          replies: replies,
          hasMoreReplies: _hasMoreReplies,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle FetchMoreRepliesEvent
  Future<void> _onFetchMoreRepliesEvent(
    FetchMoreRepliesEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    if (!_hasMoreReplies) return;

    final currentState = state;
    if (currentState is! PostDetailLoaded) return;

    emit(
      PostDetailLoadingMoreReplies(
        post: currentState.post,
        replies: _currentReplies,
      ),
    );

    try {
      final newReplies = await _postDetailRepository.getRepliesPaginated(
        postId: event.postId,
        limit: event.limit,
        startAfter: _lastReplyDocument,
      );

      _currentReplies.addAll(newReplies);
      _hasMoreReplies = newReplies.length == event.limit;

      emit(
        PostDetailLoaded(
          post: currentState.post,
          replies: _currentReplies,
          hasMoreReplies: _hasMoreReplies,
          lastReplyDocument: _lastReplyDocument,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle CreateReplyEvent
  Future<void> _onCreateReplyEvent(
    CreateReplyEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) return;

    try {
      final newReply = await _postDetailRepository.createReply(
        postId: event.postId,
        content: event.content,
        authorId: event.authorId,
        authorName: event.authorName,
        authorAvatar: event.authorAvatar,
      );

      // Add to beginning of list
      _currentReplies.insert(0, newReply);

      emit(ReplyCreated(newReply: newReply));

      // Emit loaded state with updated list
      emit(
        PostDetailLoaded(
          post: currentState.post.copyWith(
            replyCount: currentState.post.replyCount + 1,
          ),
          replies: _currentReplies,
          hasMoreReplies: _hasMoreReplies,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle FetchMoreCommentsEvent
  Future<void> _onFetchMoreCommentsEvent(
    FetchMoreCommentsEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final hasMore = _hasMoreCommentsPerReply[event.replyId] ?? true;
    if (!hasMore) return;

    final currentComments = _commentsPerReply[event.replyId] ?? [];
    emit(
      LoadingMoreComments(replyId: event.replyId, comments: currentComments),
    );

    try {
      final newComments = await _postDetailRepository.getCommentsPaginated(
        replyId: event.replyId,
        limit: event.limit,
        startAfter: _lastCommentDocumentPerReply[event.replyId],
      );

      currentComments.addAll(newComments);
      _commentsPerReply[event.replyId] = currentComments;
      _hasMoreCommentsPerReply[event.replyId] =
          newComments.length == event.limit;

      emit(
        CommentsLoaded(
          replyId: event.replyId,
          comments: currentComments,
          hasMoreComments: _hasMoreCommentsPerReply[event.replyId] ?? false,
          lastCommentDocument: _lastCommentDocumentPerReply[event.replyId],
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle CreateCommentEvent
  Future<void> _onCreateCommentEvent(
    CreateCommentEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    try {
      final newComment = await _postDetailRepository.createComment(
        postId: event.postId,
        replyId: event.replyId,
        content: event.content,
        authorId: event.authorId,
        authorName: event.authorName,
        authorAvatar: event.authorAvatar,
      );

      // Update reply comment count in local list
      final replyIndex = _currentReplies.indexWhere(
        (r) => r.id == event.replyId,
      );
      if (replyIndex != -1) {
        _currentReplies[replyIndex] = _currentReplies[replyIndex].copyWith(
          commentCount: _currentReplies[replyIndex].commentCount + 1,
        );
      }

      emit(CommentCreated(newComment: newComment));

      // Re-emit loaded state if current state is PostDetailLoaded
      if (currentState is PostDetailLoaded) {
        emit(
          PostDetailLoaded(
            post: currentState.post,
            replies: _currentReplies,
            hasMoreReplies: _hasMoreReplies,
          ),
        );
      }
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle LikeReplyEvent
  Future<void> _onLikeReplyEvent(
    LikeReplyEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) return;

    try {
      await _postDetailRepository.likeReply(event.replyId);

      // Update like count in local list
      final replyIndex = _currentReplies.indexWhere(
        (r) => r.id == event.replyId,
      );
      if (replyIndex != -1) {
        _currentReplies[replyIndex] = _currentReplies[replyIndex].copyWith(
          likes: _currentReplies[replyIndex].likes + 1,
        );
      }

      emit(
        PostDetailLoaded(
          post: currentState.post,
          replies: _currentReplies,
          hasMoreReplies: _hasMoreReplies,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle DeleteReplyEvent
  Future<void> _onDeleteReplyEvent(
    DeleteReplyEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) return;

    try {
      await _postDetailRepository.deleteReply(event.replyId);

      // Remove from local list
      _currentReplies.removeWhere((r) => r.id == event.replyId);

      emit(
        PostDetailLoaded(
          post: currentState.post.copyWith(
            replyCount: currentState.post.replyCount - 1,
          ),
          replies: _currentReplies,
          hasMoreReplies: _hasMoreReplies,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }

  /// Handle DeleteCommentEvent
  Future<void> _onDeleteCommentEvent(
    DeleteCommentEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) return;

    try {
      await _postDetailRepository.deleteComment(event.commentId);

      // Update reply comment count
      final replyIndex = _currentReplies.indexWhere(
        (r) => r.id == event.replyId,
      );
      if (replyIndex != -1) {
        _currentReplies[replyIndex] = _currentReplies[replyIndex].copyWith(
          commentCount: (_currentReplies[replyIndex].commentCount - 1)
              .clamp(0, double.infinity)
              .toInt(),
        );
      }

      emit(
        PostDetailLoaded(
          post: currentState.post,
          replies: _currentReplies,
          hasMoreReplies: _hasMoreReplies,
        ),
      );
    } on Exception catch (e) {
      emit(PostDetailError(message: e.toString()));
    }
  }
}
