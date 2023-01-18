import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'media_query_observer.dart';

class NestedApp extends StatefulWidget {
  const NestedApp({
    Key? key,
    required this.route,
    required this.size,
    required this.customWidget,
    required this.materialApp,
    required this.cupertinoApp,
    required this.widgetsApp,
    required this.child,
  }) : super(key: key);

  final Widget? child;
  final bool customWidget;
  final CupertinoApp? cupertinoApp;
  final MaterialApp? materialApp;
  final WidgetsApp? widgetsApp;
  final RouteSettings? route;
  final Size? size;

  @override
  _NestedAppState createState() => _NestedAppState();
}

class _NestedAppState extends State<NestedApp> {
  late GlobalObjectKey<NavigatorState> _navKey;

  @override
  void initState() {
    setup();
    super.initState();
  }

  void setup() {
    _navKey = GlobalObjectKey<NavigatorState>(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.route != null) {
        _navKey.currentState?.pushReplacementNamed(
          widget.route!.name!,
          arguments: widget.route!.arguments,
        );
      }
    });
  }

  @override
  void didUpdateWidget(NestedApp oldWidget) {
    if (oldWidget.materialApp != widget.materialApp) {
      if (mounted) setState(setup);
    }
    if (oldWidget.cupertinoApp != widget.cupertinoApp) {
      if (mounted) setState(setup);
    }
    if (oldWidget.widgetsApp != widget.widgetsApp) {
      if (mounted) setState(setup);
    }
    // if (oldWidget?.route != widget?.route) {
    //   if (mounted) setState(() => setup());
    // }
    super.didUpdateWidget(oldWidget);
  }

  Map<String, WidgetBuilder> get routes {
    if (widget.materialApp != null) return widget.materialApp!.routes!;
    if (widget.widgetsApp != null) return widget.widgetsApp!.routes!;
    if (widget.cupertinoApp != null) return widget.cupertinoApp!.routes!;
    return const <String, WidgetBuilder>{};
  }

  Locale? get locale {
    if (widget.materialApp != null) return widget.materialApp?.locale;
    if (widget.widgetsApp != null) return widget.widgetsApp?.locale;
    if (widget.cupertinoApp != null) return widget.cupertinoApp?.locale;
    return null;
  }

  Iterable<LocalizationsDelegate<dynamic>>? get localizationsDelegates {
    if (widget.materialApp != null) {
      return widget.materialApp?.localizationsDelegates;
    }
    if (widget.widgetsApp != null) {
      return widget.widgetsApp?.localizationsDelegates;
    }
    if (widget.cupertinoApp != null) {
      return widget.cupertinoApp?.localizationsDelegates;
    }
    return null;
  }

  Iterable<Locale> get supportedLocales {
    if (widget.materialApp != null) return widget.materialApp!.supportedLocales;
    if (widget.widgetsApp != null) return widget.widgetsApp!.supportedLocales;
    if (widget.cupertinoApp != null) {
      return widget.cupertinoApp!.supportedLocales;
    }
    return const <Locale>[Locale('en', 'US')];
  }

  LocaleResolutionCallback? get localeResolutionCallback {
    if (widget.materialApp != null) {
      return widget.materialApp?.localeResolutionCallback;
    }
    if (widget.widgetsApp != null) {
      return widget.widgetsApp?.localeResolutionCallback;
    }
    if (widget.cupertinoApp != null) {
      return widget.cupertinoApp?.localeResolutionCallback;
    }
    return null;
  }

  LocaleListResolutionCallback? get localeListResolutionCallback {
    if (widget.materialApp != null) {
      return widget.materialApp?.localeListResolutionCallback;
    }
    if (widget.widgetsApp != null) {
      return widget.widgetsApp?.localeListResolutionCallback;
    }
    if (widget.cupertinoApp != null) {
      return widget.cupertinoApp?.localeListResolutionCallback;
    }
    return null;
  }

  Map<Type, Action<Intent>>? get actions {
    if (widget.materialApp != null) return widget.materialApp?.actions;
    if (widget.widgetsApp != null) return widget.widgetsApp?.actions;
    if (widget.cupertinoApp != null) return widget.cupertinoApp?.actions;
    return null;
  }

  Map<ShortcutActivator, Intent>? get shortcuts {
    if (widget.materialApp != null) return widget.materialApp?.shortcuts;
    if (widget.widgetsApp != null) return widget.widgetsApp?.shortcuts;
    if (widget.cupertinoApp != null) return widget.cupertinoApp?.shortcuts;
    return null;
  }

  String get title {
    if (widget.materialApp != null) return widget.materialApp!.title;
    if (widget.widgetsApp != null) return widget.widgetsApp!.title;
    if (widget.cupertinoApp != null) return widget.cupertinoApp!.title;
    return '';
  }

  String Function(BuildContext)? get onGenerateTitle {
    if (widget.materialApp != null) return widget.materialApp?.onGenerateTitle;
    if (widget.widgetsApp != null) return widget.widgetsApp?.onGenerateTitle;
    if (widget.cupertinoApp != null) {
      return widget.cupertinoApp?.onGenerateTitle;
    }
    return null;
  }

  Widget builder(BuildContext context, Widget child) {
    if (widget.materialApp?.builder != null) {
      return widget.materialApp!.builder!(context, child);
    }
    if (widget.widgetsApp?.builder != null) {
      return widget.widgetsApp!.builder!(context, child);
    }
    if (widget.cupertinoApp?.builder != null) {
      return widget.cupertinoApp!.builder!(context, child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customWidget) {
      return MaterialApp(
        theme: widget.materialApp?.theme ?? ThemeData.light(),
        darkTheme: widget.materialApp?.darkTheme ?? ThemeData.dark(),
        themeMode: widget.materialApp?.themeMode ?? ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: widget.child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: widget.size),
          child: builder(context, val ?? Container()),
        ),
        color: widget.materialApp?.color,
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

    if (widget.materialApp != null) {
      return MaterialApp(
        navigatorKey: _navKey,
        theme: widget.materialApp?.theme ?? ThemeData.light(),
        darkTheme: widget.materialApp?.darkTheme ?? ThemeData.dark(),
        themeMode: widget.materialApp?.themeMode ?? ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: widget.materialApp?.onGenerateRoute,
        onUnknownRoute: widget.materialApp?.onUnknownRoute,
        onGenerateInitialRoutes: widget.materialApp?.onGenerateInitialRoutes,
        home: widget.child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: widget.size),
          child: builder(context, val ?? Container()),
        ),
        // initialRoute: route?.name,
        color: widget.materialApp?.color,
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
    if (widget.cupertinoApp != null) {
      return CupertinoApp(
        navigatorKey: _navKey,
        theme: widget.cupertinoApp?.theme ?? const CupertinoThemeData(),
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: widget.cupertinoApp?.onGenerateRoute,
        onUnknownRoute: widget.cupertinoApp?.onUnknownRoute,
        onGenerateInitialRoutes: widget.cupertinoApp?.onGenerateInitialRoutes,
        home: widget.child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: widget.size),
          child: builder(context, val ?? Container()),
        ),
        // initialRoute: route?.name,
        color: widget.cupertinoApp?.color,
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
    if (widget.widgetsApp != null) {
      return WidgetsApp(
        navigatorKey: _navKey,
        debugShowCheckedModeBanner: false,
        routes: routes,
        onGenerateRoute: widget.widgetsApp?.onGenerateRoute,
        onUnknownRoute: widget.widgetsApp?.onUnknownRoute,
        onGenerateInitialRoutes: widget.widgetsApp?.onGenerateInitialRoutes,
        home: widget.child,
        builder: (context, val) => MediaQueryObserver(
          data: MediaQuery.of(context).copyWith(size: widget.size),
          child: builder(context, val ?? Container()),
        ),
        // initialRoute: route?.name,
        color: widget.widgetsApp?.color ?? Colors.transparent,
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
    return widget.child ?? Container();
  }
}
