part of 'post_detail_bloc.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

/// Loading post detail
class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

/// Post detail loaded successfully
class PostDetailLoaded extends PostDetailState {
  final ForumPost post;
  final List<Reply> replies;
  final bool hasMoreReplies;
  final DocumentSnapshot? lastReplyDocument;

  const PostDetailLoaded({
    required this.post,
    required this.replies,
    required this.hasMoreReplies,
    this.lastReplyDocument,
  });

  @override
  List<Object?> get props => [post, replies, hasMoreReplies, lastReplyDocument];
}

/// Loading more replies
class PostDetailLoadingMoreReplies extends PostDetailState {
  final ForumPost post;
  final List<Reply> replies;

  const PostDetailLoadingMoreReplies({
    required this.post,
    required this.replies,
  });

  @override
  List<Object?> get props => [post, replies];
}

/// Reply created successfully
class ReplyCreated extends PostDetailState {
  final Reply newReply;

  const ReplyCreated({required this.newReply});

  @override
  List<Object?> get props => [newReply];
}

/// Comment created successfully
class CommentCreated extends PostDetailState {
  final Comment newComment;

  const CommentCreated({required this.newComment});

  @override
  List<Object?> get props => [newComment];
}

/// Loading more comments for a reply
class LoadingMoreComments extends PostDetailState {
  final String replyId;
  final List<Comment> comments;

  const LoadingMoreComments({required this.replyId, required this.comments});

  @override
  List<Object?> get props => [replyId, comments];
}

/// Comments loaded
class CommentsLoaded extends PostDetailState {
  final String replyId;
  final List<Comment> comments;
  final bool hasMoreComments;
  final DocumentSnapshot? lastCommentDocument;

  const CommentsLoaded({
    required this.replyId,
    required this.comments,
    required this.hasMoreComments,
    this.lastCommentDocument,
  });

  @override
  List<Object?> get props => [
    replyId,
    comments,
    hasMoreComments,
    lastCommentDocument,
  ];
}

/// Error occurred
class PostDetailError extends PostDetailState {
  final String message;

  const PostDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
