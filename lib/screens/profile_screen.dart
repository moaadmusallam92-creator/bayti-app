import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'my_properties_screen.dart';
import 'looking_for_home_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SupabaseService.fetchMyProfile();
    setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['full_name'] ?? '';
    final phone = _profile?['phone'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 28, backgroundColor: AppColors.bluePale,
              child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.orangeDark, fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              Text(phone, style: const TextStyle(color: AppColors.muted)),
            ]),
          ]),
          const SizedBox(height: 20),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.home_work_outlined),
                title: const Text('عقاراتي'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyPropertiesScreen())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('طلبات البحث عن سكن'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LookingForHomeScreen())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('المفضلة'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false);
              }
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger)),
          ),
          const SizedBox(height: 12),
          const Text('لوحة تحكم Admin لمراجعة الإعلانات هي واجهة ويب منفصلة عن التطبيق — تحتاج بناء مستقل.',
              style: TextStyle(fontSize: 11, color: AppColors.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
