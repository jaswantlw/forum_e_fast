part of 'forum_posts_bloc.dart';

abstract class ForumPostsState extends Equatable {
  const ForumPostsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ForumPostsInitial extends ForumPostsState {
  const ForumPostsInitial();
}

/// Loading posts for the first time
class ForumPostsLoading extends ForumPostsState {
  const ForumPostsLoading();
}

/// Loading more posts (pagination)
class ForumPostsLoadingMore extends ForumPostsState {
  final List<ForumPost> posts;

  const ForumPostsLoadingMore({required this.posts});

  @override
  List<Object?> get props => [posts];
}

/// Posts loaded successfully
class ForumPostsLoaded extends ForumPostsState {
  final List<ForumPost> posts;
  final bool hasMoreToLoad;
  final DocumentSnapshot? lastDocument;

  const ForumPostsLoaded({
    required this.posts,
    required this.hasMoreToLoad,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [posts, hasMoreToLoad, lastDocument];
}

/// Error occurred
class ForumPostsError extends ForumPostsState {
  final String message;

  const ForumPostsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Post created successfully
class PostCreated extends ForumPostsState {
  final ForumPost newPost;

  const PostCreated({required this.newPost});

  @override
  List<Object?> get props => [newPost];
}
