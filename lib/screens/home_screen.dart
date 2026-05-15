import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_e_fast/blocs/auth_bloc/auth_bloc.dart';
import 'package:forum_e_fast/blocs/forum_posts_bloc/forum_posts_bloc.dart';
import 'package:forum_e_fast/config/routes.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:forum_e_fast/widgets/create_post_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial posts
    context.read<ForumPostsBloc>().add(const FetchPostsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User scrolled to end, load more posts
      context.read<ForumPostsBloc>().add(const FetchMorePostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forum E-FAST'), elevation: 0),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return Column(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text('User');
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthBloc>().add(const LogoutEvent());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: BlocConsumer<ForumPostsBloc, ForumPostsState>(
        listener: (context, state) {
          if (state is ForumPostsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ForumPostsInitial || state is ForumPostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ForumPostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text('No posts yet. Create one!'));
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount:
                  state.posts.length +
                  (state.hasMoreToLoad ? 1 : 0), // Add loader at end
              itemBuilder: (context, index) {
                // Show loading indicator while fetching more
                if (index == state.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = state.posts[index];
                return PostTile(
                  post: post,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.postDetail, arguments: post.id);
                  },
                );
              },
            );
          } else if (state is ForumPostsError) {
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
                      context.read<ForumPostsBloc>().add(
                        const FetchPostsEvent(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreatePostDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Simple post tile widget
class PostTile extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;

  const PostTile({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('by ${post.authorName}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${post.replyCount} replies',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(child: const Text('View'), onTap: onTap),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Post?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ForumPostsBloc>().add(
                            DeletePostEvent(postId: post.id),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post deleted'),
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
            ),
          ],
        ),
      ),
    );
  }
}
