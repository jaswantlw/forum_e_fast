import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:forum_e_fast/blocs/forum_posts_bloc/forum_posts_bloc.dart';
import 'package:forum_e_fast/repositories/forum_posts_repository.dart';

@GenerateMocks([ForumPostsRepository])
void main() {
  group('ForumPostsBloc', () {
    late MockForumPostsRepository mockForumPostsRepository;
    late ForumPostsBloc forumPostsBloc;

    setUp(() {
      mockForumPostsRepository = MockForumPostsRepository();
      forumPostsBloc = ForumPostsBloc(
        forumPostsRepository: mockForumPostsRepository,
      );
    });

    tearDown(() {
      forumPostsBloc.close();
    });

    final testPosts = [
      ForumPost(
        id: 'post1',
        content: 'Test post 1',
        authorId: 'user1',
        authorName: 'John',
        authorAvatar: '',
        timestamp: DateTime.now(),
        replyCount: 0,
      ),
      ForumPost(
        id: 'post2',
        content: 'Test post 2',
        authorId: 'user2',
        authorName: 'Jane',
        authorAvatar: '',
        timestamp: DateTime.now(),
        replyCount: 2,
      ),
    ];

    group('FetchPostsEvent', () {
      blocTest<ForumPostsBloc, ForumPostsState>(
        'emits [ForumPostsLoading, ForumPostsLoaded] when posts are fetched successfully',
        build: () {
          when(
            mockForumPostsRepository.getPostsPaginated(limit: 10),
          ).thenAnswer((_) async => testPosts);
          return forumPostsBloc;
        },
        act: (bloc) => bloc.add(const FetchPostsEvent()),
        expect: () => [
          isA<ForumPostsLoading>(),
          isA<ForumPostsLoaded>()
              .having((state) => state.posts.length, 'posts length', 2)
              .having((state) => state.hasMoreToLoad, 'hasMoreToLoad', false),
        ],
      );

      blocTest<ForumPostsBloc, ForumPostsState>(
        'emits [ForumPostsLoading, ForumPostsError] when fetch fails',
        build: () {
          when(
            mockForumPostsRepository.getPostsPaginated(limit: 10),
          ).thenThrow(Exception('Failed to fetch posts'));
          return forumPostsBloc;
        },
        act: (bloc) => bloc.add(const FetchPostsEvent()),
        expect: () => [isA<ForumPostsLoading>(), isA<ForumPostsError>()],
      );
    });

    group('CreatePostEvent', () {
      blocTest<ForumPostsBloc, ForumPostsState>(
        'emits [PostCreated, ForumPostsLoaded] when post is created',
        build: () {
          final newPost = ForumPost(
            id: 'post3',
            content: 'New post',
            authorId: 'user1',
            authorName: 'John',
            authorAvatar: '',
            timestamp: DateTime.now(),
            replyCount: 0,
          );
          when(
            mockForumPostsRepository.createPost(
              content: 'New post',
              authorId: 'user1',
              authorName: 'John',
              authorAvatar: '',
            ),
          ).thenAnswer((_) async => newPost);
          return forumPostsBloc;
        },
        act: (bloc) => bloc.add(
          const CreatePostEvent(
            content: 'New post',
            authorId: 'user1',
            authorName: 'John',
            authorAvatar: '',
          ),
        ),
        expect: () => [isA<PostCreated>(), isA<ForumPostsLoaded>()],
      );
    });

    group('DeletePostEvent', () {
      blocTest<ForumPostsBloc, ForumPostsState>(
        'emits [ForumPostsLoaded] with post removed when deletion succeeds',
        seed: () => ForumPostsLoaded(posts: testPosts, hasMoreToLoad: false),
        build: () {
          when(
            mockForumPostsRepository.deletePost('post1'),
          ).thenAnswer((_) async => {});
          return forumPostsBloc;
        },
        act: (bloc) => bloc.add(const DeletePostEvent(postId: 'post1')),
        expect: () => [
          isA<ForumPostsLoaded>()
              .having((state) => state.posts.length, 'posts length', 1)
              .having(
                (state) => state.posts[0].id,
                'remaining post id',
                'post2',
              ),
        ],
      );
    });
  });
}
