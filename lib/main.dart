import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/config/env_config.dart';
import 'package:trusted/core/theme/theme.dart';
import 'package:trusted/features/admin/presentation/screens/admin_main_screen.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/features/auth/presentation/screens/confirmation_screen.dart';
import 'package:trusted/features/auth/presentation/screens/information_entry_screen.dart';
import 'package:trusted/features/auth/presentation/screens/login_screen.dart';
import 'package:trusted/features/auth/presentation/screens/rejected_screen.dart';
import 'package:trusted/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:trusted/features/auth/presentation/screens/waiting_screen.dart';
import 'package:trusted/features/profile/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
    debug: false,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    Future.microtask(() {
      ref.read(authStateProvider.notifier).initAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trusted',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
      locale: const Locale('ar'), // Default to Arabic
      // Set text direction to RTL for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup/role': (context) => const RoleSelectionScreen(),
        '/signup/information': (context) => const InformationEntryScreen(),
        '/signup/confirmation': (context) => const ConfirmationScreen(),
        '/waiting': (context) => const WaitingScreen(),
        '/rejected': (context) => const RejectedScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin/dashboard': (context) => const AdminMainScreen(),
      },
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // Check auth state and redirect accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authState.isLoading) {
        if (authState.user != null) {
          if (authState.user!.isAdmin) {
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else if (authState.user!.isActive) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (authState.user!.isPending) {
            Navigator.pushReplacementNamed(context, '/waiting');
          } else if (authState.user!.isRejected) {
            Navigator.pushReplacementNamed(context, '/rejected');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.security,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Trusted',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
