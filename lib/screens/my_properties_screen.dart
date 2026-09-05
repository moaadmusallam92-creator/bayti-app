import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/supabase_service.dart';
import 'add_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});
  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> with SingleTickerProviderStateMixin {
  List<Property> _all = [];
  bool _loading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SupabaseService.fetchMyProperties();
      setState(() { _all = list; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _all.where((p) => p.availabilityStatus == 'available').toList();
    final unconfirmed = _all.where((p) => p.availabilityStatus == 'unconfirmed').toList();
    final rented = _all.where((p) => p.availabilityStatus == 'rented').toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('عقاراتي'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.orange,
          labelColor: Colors.white,
          tabs: [
            Tab(text: '🟢 متاح (${available.length})'),
            Tab(text: '🟡 غير مؤكد (${unconfirmed.length})'),
            Tab(text: '🔴 مؤجر (${rented.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        icon: const Icon(Icons.add),
        label: const Text('عقار جديد'),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          _load();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _list(available),
                _list(unconfirmed),
                _list(rented),
              ],
            ),
    );
  }

  Widget _list(List<Property> items) {
    if (items.isEmpty) {
      return const Center(child: Text('ولا عقار بهاي الحالة', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Text('${p.price.toStringAsFixed(0)} د.أ', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.orangeDark)),
                    ],
                  ),
                  Text('👁 ${p.views} مشاهدة · ${p.verificationStatus == 'pending' ? '🟡 تحت المراجعة' : '✓ منشور'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (p.availabilityStatus != 'rented')
                      OutlinedButton(
                        onPressed: () async { await SupabaseService.markPropertyRented(p.id); _load(); },
                        child: const Text('وضع كمؤجر'),
                      ),
                    if (p.availabilityStatus == 'unconfirmed')
                      OutlinedButton(
                        onPressed: () async { await SupabaseService.confirmAvailability(p.id); _load(); },
                        child: const Text('تأكيد التوفر'),
                      ),
                    OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('حذف العقار؟'),
                            content: const Text('هاد الإجراء لا يمكن التراجع عنه'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppColors.danger))),
                            ],
                          ),
                        );
                        if (confirm == true) { await SupabaseService.deleteProperty(p.id); _load(); }
                      },
                      child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
