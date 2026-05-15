import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_e_fast/blocs/forum_posts_bloc/forum_posts_bloc.dart';
import 'package:forum_e_fast/blocs/auth_bloc/auth_bloc.dart';

/// Dialog for creating a new forum post
class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      final content = _contentController.text.trim();
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        context.read<ForumPostsBloc>().add(
          CreatePostEvent(
            content: content,
            authorId: authState.userId,
            authorName: authState.email.split('@')[0],
            authorAvatar: '',
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumPostsBloc, ForumPostsState>(
      listener: (context, state) {
        if (state is ForumPostsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Create Post'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 4,
                minLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Post content cannot be empty';
                  }
                  if (value.trim().length < 3) {
                    return 'Post must be at least 3 characters';
                  }
                  if (value.trim().length > 1000) {
                    return 'Post must be less than 1000 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<ForumPostsBloc, ForumPostsState>(
            builder: (context, state) {
              final isLoading = state is ForumPostsLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _submitPost,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              );
            },
          ),
        ],
      ),
    );
  }
}
