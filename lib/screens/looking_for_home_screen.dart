import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class LookingForHomeScreen extends StatefulWidget {
  const LookingForHomeScreen({super.key});
  @override
  State<LookingForHomeScreen> createState() => _LookingForHomeScreenState();
}

class _LookingForHomeScreenState extends State<LookingForHomeScreen> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _area;
  String _familyStatus = 'family';
  bool _loading = false;
  List<Map<String, dynamic>> _mine = [];

  static const areas = ['عين الباشا', 'البقعة', 'سحاب', 'الرصيفة', 'خريبة السوق', 'صويلح', 'الجبيهة', 'دابوق'];

  @override
  void initState() {
    super.initState();
    _loadMine();
  }

  Future<void> _loadMine() async {
    try {
      final list = await SupabaseService.fetchMyRentalRequests();
      setState(() => _mine = list);
    } catch (_) {}
  }

  Future<void> _publish() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.addRentalRequest({
        'area': _area,
        'min_price': double.tryParse(_minCtrl.text),
        'max_price': double.tryParse(_maxCtrl.text),
        'family_status': _familyStatus,
        'requirements': _notesCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر طلبك ✓')));
      }
      _minCtrl.clear(); _maxCtrl.clear(); _notesCtrl.clear();
      await _loadMine();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('أنا أبحث عن سكن')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _area, decoration: const InputDecoration(labelText: 'المنطقة المفضلة'),
            items: areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => _area = v),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'أقل ميزانية'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'أعلى ميزانية'))),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _familyStatus, decoration: const InputDecoration(labelText: 'الحالة'),
            items: const [DropdownMenuItem(value: 'family', child: Text('عائلة')), DropdownMenuItem(value: 'single', child: Text('فرد'))],
            onChanged: (v) => setState(() => _familyStatus = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'متطلبات إضافية')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _publish,
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('نشر الطلب'),
          ),
          if (_mine.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('طلباتي السابقة', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ..._mine.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('${r['area'] ?? 'أي منطقة'} · ${r['min_price'] ?? '-'}—${r['max_price'] ?? '-'} د.أ'),
                    subtitle: Text(r['family_status'] == 'family' ? 'عائلة' : 'فرد'),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
