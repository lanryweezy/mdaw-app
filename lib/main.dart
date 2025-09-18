import 'package:flutter/material.dart';
import 'package:studio_wiz/app_constants.dart';
import 'package:studio_wiz/app_theme.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // It's important to ensure Flutter bindings are initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DawViewModel(),
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
