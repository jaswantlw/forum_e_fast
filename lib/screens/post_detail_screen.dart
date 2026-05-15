import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:forum_e_fast/blocs/post_detail_bloc/post_detail_bloc.dart';
import 'package:forum_e_fast/blocs/auth_bloc/auth_bloc.dart';
import 'package:forum_e_fast/widgets/reply_tile.dart';
import 'package:forum_e_fast/widgets/comment_tile.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late ScrollController _scrollController;
  late TextEditingController _replyController;
  Map<String, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _replyController = TextEditingController();

    // Load post detail and replies
    context.read<PostDetailBloc>().add(
      FetchPostDetailEvent(postId: widget.postId),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyController.dispose();
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<PostDetailBloc>().add(
        FetchMoreRepliesEvent(postId: widget.postId),
      );
    }
  }

  void _showCreateReplyDialog() {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: _replyController,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 4,
          minLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              final isLoading = state is PostDetailLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final content = _replyController.text.trim();
                        if (content.isNotEmpty && content.length >= 3) {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<PostDetailBloc>().add(
                              CreateReplyEvent(
                                postId: widget.postId,
                                content: content,
                                authorId: authState.userId,
                                authorName: authState.email.split('@')[0],
                                authorAvatar: '',
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reply must be at least 3 characters',
                              ),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reply'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateCommentDialog(Reply reply) {
    if (!_commentControllers.containsKey(reply.id)) {
      _commentControllers[reply.id] = TextEditingController();
    }
    _commentControllers[reply.id]!.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentControllers[reply.id],
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
          minLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              final isLoading = state is PostDetailLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final content = _commentControllers[reply.id]!.text
                            .trim();
                        if (content.isNotEmpty && content.length >= 3) {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<PostDetailBloc>().add(
                              CreateCommentEvent(
                                postId: widget.postId,
                                replyId: reply.id,
                                content: content,
                                authorId: authState.userId,
                                authorName: authState.email.split('@')[0],
                                authorAvatar: '',
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Comment must be at least 3 characters',
                              ),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Comment'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: BlocConsumer<PostDetailBloc, PostDetailState>(
        listener: (context, state) {
          if (state is PostDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostDetailInitial || state is PostDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostDetailLoaded) {
            return Column(
              children: [
                // Post header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.post.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(state.post.content),
                          const SizedBox(height: 12),
                          Text(
                            state.post.timestamp.toString().split('.')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Divider
                const Divider(),
                // Replies section header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Replies (${state.post.replyCount})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateReplyDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Reply'),
                      ),
                    ],
                  ),
                ),
                // Replies list
                Expanded(
                  child: state.replies.isEmpty
                      ? const Center(child: Text('No replies yet'))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              state.replies.length +
                              (state.hasMoreReplies ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.replies.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final reply = state.replies[index];
                            return ReplyTile(
                              reply: reply,
                              onLike: () {
                                context.read<PostDetailBloc>().add(
                                  LikeReplyEvent(replyId: reply.id),
                                );
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Reply?'),
                                    content: const Text(
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<PostDetailBloc>().add(
                                            DeleteReplyEvent(replyId: reply.id),
                                          );
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Reply deleted'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onReplyToComment: () =>
                                  _showCreateCommentDialog(reply),
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (state is PostDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PostDetailBloc>().add(
                        FetchPostDetailEvent(postId: widget.postId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
