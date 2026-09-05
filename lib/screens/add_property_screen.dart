import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/supabase_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _areaSqmCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  String _type = 'شقة';
  String _area = 'عين الباشا';
  bool _furnished = false;
  bool _loading = false;

  static const types = ['شقة', 'بيت مستقل', 'طابق', 'استوديو'];
  static const areas = ['عين الباشا', 'البقعة', 'سحاب', 'الرصيفة', 'خريبة السوق', 'صويلح', 'الجبيهة', 'دابوق'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final draft = Property(
        id: '', ownerId: '', propertyType: _type, title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        bedrooms: int.parse(_bedroomsCtrl.text),
        bathrooms: int.parse(_bathroomsCtrl.text),
        areaSqm: double.tryParse(_areaSqmCtrl.text),
        furnished: _furnished,
        photos: _photoUrlCtrl.text.trim().isNotEmpty ? [_photoUrlCtrl.text.trim()] : [],
        area: _area,
        createdAt: DateTime.now(),
      );
      await SupabaseService.addProperty(draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال العقار — بانتظار موافقة الإدارة (verification_status = pending)')),
        );
        Navigator.of(context).pop();
      }
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
      appBar: AppBar(title: const Text('إضافة عقار')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _type, decoration: const InputDecoration(labelText: 'نوع العقار'),
              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الإعلان'),
                validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _bedroomsCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'غرف النوم'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null)),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(controller: _bathroomsCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الحمامات'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null)),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _areaSqmCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المساحة (م²)')),
            const SizedBox(height: 12),
            TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر الشهري (د.أ)'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _area, decoration: const InputDecoration(labelText: 'المنطقة'),
              items: areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) => setState(() => _area = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _furnished, onChanged: (v) => setState(() => _furnished = v),
              title: const Text('مفروش'), contentPadding: EdgeInsets.zero,
            ),
            TextFormField(controller: _photoUrlCtrl, decoration: const InputDecoration(
                labelText: 'رابط صورة', hintText: 'ارفع الصورة لـ Supabase Storage والصق الرابط هون')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('نشر العقار'),
            ),
          ],
        ),
      ),
    );
  }
}
