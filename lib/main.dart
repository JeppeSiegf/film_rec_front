import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/film_home_screen.dart';
import 'package:film_rec_front/ui/home_sceen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  runApp(const MyApp());
  
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});
  

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  void _toggleTheme() {
    setState(() {
      ThemeManager.toggleTheme();
    });
  }

  void _toggleLocale() {
    setState(() {
      LocalizationManager.toggleLocale();
    });
  }

  late final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            child: HomeScreen(
              toggleTheme: _toggleTheme,
              toggleLocale: _toggleLocale,
              currentTheme: ThemeManager.themeMode,
              currentLocale: LocalizationManager.locale,
            ),
          ),
        ),
        GoRoute(
          path: '/rec',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: FilmRecommenderScreen(
              toggleTheme: _toggleTheme,
              toggleLocale: _toggleLocale,
              currentTheme: ThemeManager.themeMode,
              currentLocale: LocalizationManager.locale,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ],
      errorPageBuilder: (context, state) => NoTransitionPage(
              child: Scaffold(
                  body: Center(
                      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_very_dissatisfied_sharp,
                size: 128,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 10),
              Text('404 – Page not found'),
            ],
          )))));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Siegfredsen.org',
      routerConfig: _router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeManager.themeMode,
      locale: LocalizationManager.locale,
    );
  }
}
