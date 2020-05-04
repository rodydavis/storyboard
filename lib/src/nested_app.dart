import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'media_query_observer.dart';

class NestedApp extends StatelessWidget {
  final Widget child;
  final RouteSettings route;
  final Size size;
  final bool customWidget;
  final MaterialApp materialApp;
  final CupertinoApp cupertinoApp;
  final WidgetsApp widgetsApp;
  final Map<String, WidgetBuilder> routes;

  const NestedApp({
    Key key,
    @required this.route,
    @required this.size,
    @required this.customWidget,
    @required this.materialApp,
    @required this.cupertinoApp,
    @required this.widgetsApp,
    @required this.child,
    @required this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(child != null || route != null);
    if (customWidget) {
      return MaterialApp(
        theme: materialApp?.theme ?? ThemeData.light(),
        darkTheme: materialApp?.darkTheme ?? ThemeData.dark(),
        themeMode: materialApp?.themeMode ?? ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: size),
          child: val,
        ),
        color: materialApp?.color,
      );
    }
    if (materialApp != null) {
      return MaterialApp(
        theme: materialApp?.theme ?? ThemeData.light(),
        darkTheme: materialApp?.darkTheme ?? ThemeData.dark(),
        themeMode: materialApp?.themeMode ?? ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: materialApp?.onGenerateRoute,
        onUnknownRoute: materialApp?.onUnknownRoute,
        onGenerateInitialRoutes: materialApp?.onGenerateInitialRoutes,
        home: child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: size),
          child: val,
        ),
        initialRoute: route?.name,
        color: materialApp?.color,
      );
    }
    if (cupertinoApp != null) {
      return CupertinoApp(
        theme: cupertinoApp?.theme ?? CupertinoThemeData(),
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: cupertinoApp?.onGenerateRoute,
        onUnknownRoute: cupertinoApp?.onUnknownRoute,
        onGenerateInitialRoutes: cupertinoApp?.onGenerateInitialRoutes,
        home: child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: size),
          child: val,
        ),
        initialRoute: route?.name,
        color: cupertinoApp?.color,
      );
    }
    if (widgetsApp != null) {
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: widgetsApp?.onGenerateRoute,
        onUnknownRoute: widgetsApp?.onUnknownRoute,
        onGenerateInitialRoutes: widgetsApp?.onGenerateInitialRoutes,
        home: child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: size),
          child: val,
        ),
        initialRoute: route?.name,
        color: widgetsApp?.color,
      );
    }
    return child;
  }
}
