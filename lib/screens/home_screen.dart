import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/supabase_service.dart';
import 'property_details_screen.dart';
import 'add_property_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  bool _loading = true;
  String? _areaFilter;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  static const areas = ['عين الباشا', 'البقعة', 'سحاب', 'الرصيفة', 'خريبة السوق', 'صويلح', 'الجبيهة', 'دابوق'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SupabaseService.fetchApprovedProperties(
        area: _areaFilter,
        minPrice: double.tryParse(_minCtrl.text),
        maxPrice: double.tryParse(_maxCtrl.text),
      );
      setState(() { _properties = list; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر تحميل العقارات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('بيتي')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        icon: const Icon(Icons.add),
        label: const Text('أضف عقارك'),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          _load();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _filterBar(),
            const SizedBox(height: 14),
            if (_loading) const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            if (!_loading && _properties.isEmpty)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('ولا عقار منشور لسه بهاي المنطقة', style: TextStyle(color: AppColors.muted)))),
            ..._properties.map((p) => _propertyCard(p)),
          ],
        ),
      ),
    );
  }

  Widget _filterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _areaFilter,
              decoration: const InputDecoration(labelText: 'المنطقة'),
              items: [const DropdownMenuItem(value: null, child: Text('كل المناطق')), ...areas.map((a) => DropdownMenuItem(value: a, child: Text(a)))],
              onChanged: (v) => setState(() => _areaFilter = v),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: _minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'أقل سعر'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'أعلى سعر'))),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _load, child: const Text('بحث'))),
          ],
        ),
      ),
    );
  }

  Widget _propertyCard(Property p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              color: AppColors.bluePale,
              child: p.photos.isNotEmpty
                  ? Image.network(p.photos.first, fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(child: Text('تعذر تحميل الصورة')))
                  : const Center(child: Text('ولا صورة', style: TextStyle(color: AppColors.muted))),
            ),
            Padding(
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
                  const SizedBox(height: 4),
                  Text('📍 ${p.area}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('🛏 ${p.bedrooms} غرف · 🚿 ${p.bathrooms} حمام${p.areaSqm != null ? ' · 📐 ${p.areaSqm!.toStringAsFixed(0)} م²' : ''}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
