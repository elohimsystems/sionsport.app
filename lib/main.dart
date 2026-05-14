import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/app_routes.dart';
import 'widgets/user_menu.dart';
import 'widgets/language_selector.dart';
import 'screens/login_screen.dart';
import 'screens/register_type_screen.dart';
import 'screens/register_user_person_screen.dart';
import 'screens/register_user_organization_screen.dart';
import 'screens/edit_user_person_screen.dart';
import 'screens/edit_user_organization_screen.dart';
import 'i18n/locale_provider.dart';
import 'i18n/app_translations.dart';

void main() {
  runApp(const MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, _) {
        return MaterialApp(
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Text(AppTranslations.of('app_name')),
              actions: [LanguageSelector(), UserMenu()],
            ),
          ),
          routes: {
            AppRoutes.home: (context) => MainScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.registerType: (context) => const RegisterTypeScreen(),
            AppRoutes.registerPerson: (context) {
              final type = ModalRoute.of(context)?.settings.arguments as String?;
              return RegisterUserPersonScreen(registerType: type);
            },
            AppRoutes.registerOrganization: (context) {
              final type = ModalRoute.of(context)?.settings.arguments as String?;
              return RegisterUserOrganizationScreen(registerType: type);
            },
            AppRoutes.editPerson: (context) => const EditUserPersonScreen(),
            AppRoutes.editOrganization: (context) => const EditUserOrganizationScreen(),
          },
        );
      },
    );
  }
}
