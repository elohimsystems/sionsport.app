import 'package:flutter/material.dart';
import '../storage/token_storage.dart';
import '../i18n/app_translations.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({super.key});

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  String? _fullName;
  String? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await TokenStorage.getFullName();
    final image = await TokenStorage.getImage();
    if (mounted) {
      setState(() {
        _fullName = name;
        _image = image;
      });
    }
  }

  void _logout() async {
    await TokenStorage.deleteToken();
    if (mounted) {
      setState(() {
        _fullName = null;
        _image = null;
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = _fullName != null;
    final imageUrl = _image != null
        ? 'http://localhost:3000/${_image!.replaceAll('\\', '/')}'
        : null;

    return PopupMenuButton<String>(
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null ? const Icon(Icons.person, size: 20) : null,
          ),
          const SizedBox(width: 6),
          Text(isLogged ? _fullName! : AppTranslations.of('user')),
        ],
      ),
      onSelected: (value) async {
        if (value == 'profile') {
          final target = await TokenStorage.getTarget();
          if (target == 'P') {
            Navigator.pushNamed(context, '/edit-person');
          } else if (target == 'O') {
            Navigator.pushNamed(context, '/edit-organization');
          }
        }
        else if (value == 'logout') { _logout(); }
        else if (value == 'login') {
          Navigator.pushNamed(context, '/login');
        } else if (value == 'register') {
          Navigator.pushNamed(context, '/register-type');
        }
      },
      itemBuilder: (_) => isLogged
          ? [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 18),
              const SizedBox(width: 8),
              Text(AppTranslations.of('edit')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18),
              const SizedBox(width: 8),
              Text(AppTranslations.of('logout')),
            ],
          ),
        ),
      ]
          : [
        PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              const Icon(Icons.login, size: 18),
              const SizedBox(width: 8),
              Text(AppTranslations.of('login')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'register',
          child: Row(
            children: [
              const Icon(Icons.person_add, size: 18),
              const SizedBox(width: 8),
              Text(AppTranslations.of('register')),
            ],
          ),
        ),
      ],
    );
  }
}
