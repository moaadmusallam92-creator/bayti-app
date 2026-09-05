import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'add_property_screen.dart';
import 'looking_for_home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [HomeScreen(), FavoritesScreen(), _AddChoicePage(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blueLight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.orange), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite, color: AppColors.orange), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: AppColors.orange), label: 'إضافة'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.orange), label: 'حسابي'),
        ],
      ),
    );
  }
}

/// شاشة وسيطة بسيطة لاختيار: عندي عقار / أنا أبحث عن سكن
class _AddChoicePage extends StatelessWidget {
  const _AddChoicePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('شو حاب تسوي؟')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _OptionCard(
            icon: Icons.house_outlined,
            label: 'عندي عقار للإيجار',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
          ),
          const SizedBox(height: 14),
          _OptionCard(
            icon: Icons.search,
            label: 'أنا أبحث عن سكن',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LookingForHomeScreen())),
          ),
        ]),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OptionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Icon(icon, size: 32, color: AppColors.orange),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
        ),
      ),
    );
  }
}
