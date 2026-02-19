import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/presentation/pages/splash_screen.dart';
import 'package:universal_platform/universal_platform.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (UniversalPlatform.isWeb) {
    SystemChrome.setApplicationSwitcherDescription(
      const ApplicationSwitcherDescription(
        label: 'المقاومة الشعبية - نظام الإدارة',
        primaryColor: 0xFF764ba2,
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocaleProvider())],
      child: const ResistanceSystemApp(),
    ),
  );
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class ResistanceSystemApp extends StatelessWidget {
  const ResistanceSystemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          title: 'المقاومة الشعبية',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
