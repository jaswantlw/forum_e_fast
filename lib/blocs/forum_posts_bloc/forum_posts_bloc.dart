import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_e_fast/repositories/forum_posts_repository.dart';

part 'forum_posts_event.dart';
part 'forum_posts_state.dart';

class ForumPostsBloc extends Bloc<ForumPostsEvent, ForumPostsState> {
  final ForumPostsRepository _forumPostsRepository;

  // Pagination state
  List<ForumPost> _currentPosts = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMoreToLoad = true;

  ForumPostsBloc({required ForumPostsRepository forumPostsRepository})
    : _forumPostsRepository = forumPostsRepository,
      super(const ForumPostsInitial()) {
    on<FetchPostsEvent>(_onFetchPostsEvent);
    on<FetchMorePostsEvent>(_onFetchMorePostsEvent);
    on<CreatePostEvent>(_onCreatePostEvent);
    on<RefreshPostsEvent>(_onRefreshPostsEvent);
    on<DeletePostEvent>(_onDeletePostEvent);
  }

  /// Handle FetchPostsEvent - initial load
  Future<void> _onFetchPostsEvent(
    FetchPostsEvent event,
    Emitter<ForumPostsState> emit,
  ) async {
    emit(const ForumPostsLoading());
    try {
      final posts = await _forumPostsRepository.getPostsPaginated(
        limit: event.limit,
      );

      _currentPosts = posts;
      _hasMoreToLoad = posts.length == event.limit;
      _lastDocument = null; // Reset pagination

      emit(ForumPostsLoaded(posts: posts, hasMoreToLoad: _hasMoreToLoad));
    } on Exception catch (e) {
      emit(ForumPostsError(message: e.toString()));
    }
  }

  /// Handle FetchMorePostsEvent - pagination
  Future<void> _onFetchMorePostsEvent(
    FetchMorePostsEvent event,
    Emitter<ForumPostsState> emit,
  ) async {
    if (!_hasMoreToLoad) return; // Don't fetch if no more posts

    emit(ForumPostsLoadingMore(posts: _currentPosts));
    try {
      final newPosts = await _forumPostsRepository.getPostsPaginated(
        limit: event.limit,
        startAfter: _lastDocument,
      );

      _currentPosts.addAll(newPosts);
      _hasMoreToLoad = newPosts.length == event.limit;

      emit(
        ForumPostsLoaded(
          posts: _currentPosts,
          hasMoreToLoad: _hasMoreToLoad,
          lastDocument: _lastDocument,
        ),
      );
    } on Exception catch (e) {
      emit(ForumPostsError(message: e.toString()));
    }
  }

  /// Handle CreatePostEvent
  Future<void> _onCreatePostEvent(
    CreatePostEvent event,
    Emitter<ForumPostsState> emit,
  ) async {
    try {
      final newPost = await _forumPostsRepository.createPost(
        content: event.content,
        authorId: event.authorId,
        authorName: event.authorName,
        authorAvatar: event.authorAvatar,
      );

      // Add to beginning of list
      _currentPosts.insert(0, newPost);

      emit(PostCreated(newPost: newPost));

      // Emit loaded state with updated list
      emit(
        ForumPostsLoaded(posts: _currentPosts, hasMoreToLoad: _hasMoreToLoad),
      );
    } on Exception catch (e) {
      emit(ForumPostsError(message: e.toString()));
    }
  }

  /// Handle RefreshPostsEvent - refresh from scratch
  Future<void> _onRefreshPostsEvent(
    RefreshPostsEvent event,
    Emitter<ForumPostsState> emit,
  ) async {
    try {
      final posts = await _forumPostsRepository.getPostsPaginated(
        limit: event.limit,
      );

      _currentPosts = posts;
      _hasMoreToLoad = posts.length == event.limit;
      _lastDocument = null;

      emit(ForumPostsLoaded(posts: posts, hasMoreToLoad: _hasMoreToLoad));
    } on Exception catch (e) {
      emit(ForumPostsError(message: e.toString()));
    }
  }

  /// Handle DeletePostEvent
  Future<void> _onDeletePostEvent(
    DeletePostEvent event,
    Emitter<ForumPostsState> emit,
  ) async {
    try {
      await _forumPostsRepository.deletePost(event.postId);

      // Remove from local list
      _currentPosts.removeWhere((p) => p.id == event.postId);

      emit(
        ForumPostsLoaded(posts: _currentPosts, hasMoreToLoad: _hasMoreToLoad),
      );
    } on Exception catch (e) {
      emit(ForumPostsError(message: e.toString()));
    }
  }
}
