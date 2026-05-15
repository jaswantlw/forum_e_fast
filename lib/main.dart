import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_service/firebase_service_exports.dart'
    as firebase_service;
import 'package:forum_e_fast/blocs/auth_bloc/auth_bloc.dart';
import 'package:forum_e_fast/blocs/forum_posts_bloc/forum_posts_bloc.dart';
import 'package:forum_e_fast/blocs/post_detail_bloc/post_detail_bloc.dart';
import 'package:forum_e_fast/config/routes.dart';
import 'firebase_options.dart';
import 'package:forum_e_fast/repositories/auth_repository.dart';
import 'package:forum_e_fast/repositories/forum_posts_repository.dart';
import 'package:forum_e_fast/repositories/post_detail_repository.dart';
import 'package:forum_e_fast/screens/home_screen.dart';
import 'package:forum_e_fast/screens/login_screen.dart';
import 'package:forum_e_fast/screens/logo_screen.dart';
import 'package:forum_e_fast/screens/post_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize FirebaseService (singleton)
    final firebaseService = firebase_service.FirebaseService();

    // Initialize Repositories
    final authRepository = AuthRepository(firebaseService: firebaseService);
    final forumPostsRepository = ForumPostsRepository(
      firebaseService: firebaseService,
    );
    final postDetailRepository = PostDetailRepository(
      firebaseService: firebaseService,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(const CheckAuthStatusEvent()), // Check if already logged in
        ),
        BlocProvider<ForumPostsBloc>(
          create: (context) =>
              ForumPostsBloc(forumPostsRepository: forumPostsRepository),
        ),
        BlocProvider<PostDetailBloc>(
          create: (context) =>
              PostDetailBloc(postDetailRepository: postDetailRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Forum E-FAST',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // This listener will handle navigation on auth state changes
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Show appropriate screen based on auth state
              if (state is AuthInitial) {
                return const LogoScreen();
              } else if (state is AuthLoading) {
                return const LogoScreen();
              } else if (state is AuthAuthenticated) {
                return const HomeScreen();
              } else if (state is AuthUnauthenticated) {
                return const LoginScreen();
              } else if (state is AuthError) {
                return const LoginScreen(); // Show login on error
              }
              return const LogoScreen();
            },
          ),
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.home:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case AppRoutes.logo:
              return MaterialPageRoute(builder: (_) => const LogoScreen());
            case AppRoutes.postDetail:
              final postId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: postId),
              );
            default:
              return MaterialPageRoute(builder: (_) => const LogoScreen());
          }
        },
      ),
    );
  }
}
