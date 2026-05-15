part of 'post_detail_bloc.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch post detail and initial replies
class FetchPostDetailEvent extends PostDetailEvent {
  final String postId;
  final int repliesLimit;

  const FetchPostDetailEvent({required this.postId, this.repliesLimit = 10});

  @override
  List<Object?> get props => [postId, repliesLimit];
}

/// Fetch more replies (pagination)
class FetchMoreRepliesEvent extends PostDetailEvent {
  final String postId;
  final int limit;

  const FetchMoreRepliesEvent({required this.postId, this.limit = 10});

  @override
  List<Object?> get props => [postId, limit];
}

/// Create a reply
class CreateReplyEvent extends PostDetailEvent {
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;

  const CreateReplyEvent({
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
  });

  @override
  List<Object?> get props => [
    postId,
    content,
    authorId,
    authorName,
    authorAvatar,
  ];
}

/// Fetch more comments for a reply (pagination)
class FetchMoreCommentsEvent extends PostDetailEvent {
  final String replyId;
  final int limit;

  const FetchMoreCommentsEvent({required this.replyId, this.limit = 10});

  @override
  List<Object?> get props => [replyId, limit];
}

/// Create a comment on a reply
class CreateCommentEvent extends PostDetailEvent {
  final String postId;
  final String replyId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;

  const CreateCommentEvent({
    required this.postId,
    required this.replyId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
  });

  @override
  List<Object?> get props => [
    postId,
    replyId,
    content,
    authorId,
    authorName,
    authorAvatar,
  ];
}

/// Like a reply
class LikeReplyEvent extends PostDetailEvent {
  final String replyId;

  const LikeReplyEvent({required this.replyId});

  @override
  List<Object?> get props => [replyId];
}

/// Delete a reply
class DeleteReplyEvent extends PostDetailEvent {
  final String replyId;

  const DeleteReplyEvent({required this.replyId});

  @override
  List<Object?> get props => [replyId];
}

/// Delete a comment
class DeleteCommentEvent extends PostDetailEvent {
  final String commentId;
  final String replyId;

  const DeleteCommentEvent({required this.commentId, required this.replyId});

  @override
  List<Object?> get props => [commentId, replyId];
}
