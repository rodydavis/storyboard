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

  const NestedApp({
    Key key,
    @required this.route,
    @required this.size,
    @required this.customWidget,
    @required this.materialApp,
    @required this.cupertinoApp,
    @required this.widgetsApp,
    @required this.child,
  }) : super(key: key);

  Map<String, WidgetBuilder> get routes {
    if (materialApp != null) return materialApp?.routes;
    if (widgetsApp != null) return widgetsApp?.routes;
    if (cupertinoApp != null) return cupertinoApp?.routes;
    return null;
  }

  Locale get locale {
    if (materialApp != null) return materialApp?.locale;
    if (widgetsApp != null) return widgetsApp?.locale;
    if (cupertinoApp != null) return cupertinoApp?.locale;
    return null;
  }

  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    if (materialApp != null) return materialApp?.localizationsDelegates;
    if (widgetsApp != null) return widgetsApp?.localizationsDelegates;
    if (cupertinoApp != null) return cupertinoApp?.localizationsDelegates;
    return null;
  }

  Iterable<Locale> get supportedLocales {
    if (materialApp != null) return materialApp?.supportedLocales;
    if (widgetsApp != null) return widgetsApp?.supportedLocales;
    if (cupertinoApp != null) return cupertinoApp?.supportedLocales;
    return null;
  }

  LocaleResolutionCallback get localeResolutionCallback {
    if (materialApp != null) return materialApp?.localeResolutionCallback;
    if (widgetsApp != null) return widgetsApp?.localeResolutionCallback;
    if (cupertinoApp != null) return cupertinoApp?.localeResolutionCallback;
    return null;
  }

  LocaleListResolutionCallback get localeListResolutionCallback {
    if (materialApp != null) return materialApp?.localeListResolutionCallback;
    if (widgetsApp != null) return widgetsApp?.localeListResolutionCallback;
    if (cupertinoApp != null) return cupertinoApp?.localeListResolutionCallback;
    return null;
  }

  Map<Type, Action<Intent>> get actions {
    if (materialApp != null) return materialApp?.actions;
    if (widgetsApp != null) return widgetsApp?.actions;
    if (cupertinoApp != null) return cupertinoApp?.actions;
    return null;
  }

  Map<LogicalKeySet, Intent> get shortcuts {
    if (materialApp != null) return materialApp?.shortcuts;
    if (widgetsApp != null) return widgetsApp?.shortcuts;
    if (cupertinoApp != null) return cupertinoApp?.shortcuts;
    return null;
  }

  String get title {
    if (materialApp != null) return materialApp?.title;
    if (widgetsApp != null) return widgetsApp?.title;
    if (cupertinoApp != null) return cupertinoApp?.title;
    return null;
  }

  String Function(BuildContext) get onGenerateTitle {
    if (materialApp != null) return materialApp?.onGenerateTitle;
    if (widgetsApp != null) return widgetsApp?.onGenerateTitle;
    if (cupertinoApp != null) return cupertinoApp?.onGenerateTitle;
    return null;
  }

  Widget builder(BuildContext context, Widget child) {
    if (materialApp?.builder != null) return materialApp?.builder(context, child);
    if (widgetsApp?.builder != null) return widgetsApp?.builder(context, child);
    if (cupertinoApp?.builder != null) return cupertinoApp?.builder(context, child);
    return child;
  }

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
          child: builder(context, val),
        ),
        color: materialApp?.color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        localeResolutionCallback: localeResolutionCallback,
        localeListResolutionCallback: localeListResolutionCallback,
        actions: actions,
        shortcuts: shortcuts,
        title: title,
        onGenerateTitle: onGenerateTitle,
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
          child: builder(context, val),
        ),
        initialRoute: route?.name,
        color: materialApp?.color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        localeResolutionCallback: localeResolutionCallback,
        localeListResolutionCallback: localeListResolutionCallback,
        actions: actions,
        shortcuts: shortcuts,
        title: title,
        onGenerateTitle: onGenerateTitle,
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
          child: builder(context, val),
        ),
        initialRoute: route?.name,
        color: cupertinoApp?.color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        localeResolutionCallback: localeResolutionCallback,
        localeListResolutionCallback: localeListResolutionCallback,
        actions: actions,
        shortcuts: shortcuts,
        title: title,
        onGenerateTitle: onGenerateTitle,
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
          child: builder(context, val),
        ),
        initialRoute: route?.name,
        color: widgetsApp?.color,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        localeResolutionCallback: localeResolutionCallback,
        localeListResolutionCallback: localeListResolutionCallback,
        actions: actions,
        shortcuts: shortcuts,
        title: title,
        onGenerateTitle: onGenerateTitle,
      );
    }
    return child;
  }
}
