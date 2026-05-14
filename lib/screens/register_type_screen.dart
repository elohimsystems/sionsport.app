import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../i18n/app_translations.dart';

class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.of('register_type'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeCard(
                context,
                icon: Icons.person,
                title: AppTranslations.of('person_registration'),
                subtitle: AppTranslations.of('person_register_subtitle'),
                route: AppRoutes.registerPerson,
              ),
              const SizedBox(height: 24),
              _buildTypeCard(
                context,
                icon: Icons.business,
                title: AppTranslations.of('org_registration'),
                subtitle: AppTranslations.of('org_register_subtitle'),
                route: AppRoutes.registerOrganization,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? route,
    List<String>? items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            if (route != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, route),
                  child: Text(AppTranslations.of('register_btn')),
                ),
              ),
            if (items != null)
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register, arguments: item);
                      },
                      child: Text(AppTranslations.of('register_btn')),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
