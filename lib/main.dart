import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/notice_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => NoticeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const DigitalNoticeBoardApp(),
    ),
  );
}

class DigitalNoticeBoardApp extends StatelessWidget {
  const DigitalNoticeBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    return MaterialApp(
      title: 'Digital Notice Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVM.themeMode, 
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          if (authViewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (authViewModel.isAuthenticated) {
            return const HomeView();
          }
          return const LoginView();
        },
      ),
    );
  }
}
