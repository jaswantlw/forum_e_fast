part of 'forum_posts_bloc.dart';

abstract class ForumPostsEvent extends Equatable {
  const ForumPostsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial posts
class FetchPostsEvent extends ForumPostsEvent {
  final int limit;

  const FetchPostsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Fetch more posts for pagination/infinite scroll
class FetchMorePostsEvent extends ForumPostsEvent {
  final int limit;

  const FetchMorePostsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Create a new forum post
class CreatePostEvent extends ForumPostsEvent {
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;

  const CreatePostEvent({
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
  });

  @override
  List<Object?> get props => [content, authorId, authorName, authorAvatar];
}

/// Refresh the posts list
class RefreshPostsEvent extends ForumPostsEvent {
  final int limit;

  const RefreshPostsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Delete a post
class DeletePostEvent extends ForumPostsEvent {
  final String postId;

  const DeletePostEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}
