import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isFav = false;
  String _ownerName = '';
  String _ownerPhone = '';

  @override
  void initState() {
    super.initState();
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    try {
      final row = await SupabaseService.client.from('profiles').select().eq('id', widget.property.ownerId).maybeSingle();
      if (row != null && mounted) {
        setState(() { _ownerName = row['full_name'] ?? ''; _ownerPhone = row['phone'] ?? ''; });
      }
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    await SupabaseService.toggleFavorite(widget.property.id, _isFav);
    setState(() => _isFav = !_isFav);
  }

  Future<void> _openWhatsapp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.navy,
            actions: [IconButton(icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border), onPressed: _toggleFav)],
            flexibleSpace: FlexibleSpaceBar(
              background: p.photos.isNotEmpty
                  ? Image.network(p.photos.first, fit: BoxFit.cover)
                  : Container(color: AppColors.bluePale),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${p.price.toStringAsFixed(0)} د.أ / شهر',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.orangeDark)),
                      Chip(label: Text(_statusLabel(p.availabilityStatus))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('📍 ${p.area}${p.neighborhood != null ? ' — ${p.neighborhood}' : ''}',
                      style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 14),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _specChip('🛏', '${p.bedrooms} غرف'),
                    _specChip('🚿', '${p.bathrooms} حمام'),
                    if (p.areaSqm != null) _specChip('📐', '${p.areaSqm!.toStringAsFixed(0)} م²'),
                    _specChip('🏠', p.furnished ? 'مفروش' : 'غير مفروش'),
                  ]),
                  if (p.description != null && p.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('الوصف', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(p.description!),
                  ],
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _ownerPhone.isEmpty ? null : () => _openWhatsapp(_ownerPhone),
                        icon: const Icon(Icons.chat),
                        label: const Text('واتساب'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              propertyId: p.id,
                              propertyTitle: p.title,
                              otherUserId: p.ownerId,
                              otherUserName: _ownerName.isEmpty ? 'المالك' : _ownerName,
                            ),
                          ));
                        },
                        icon: const Icon(Icons.forum_outlined),
                        label: const Text('مراسلة داخل التطبيق'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await SupabaseService.requestViewing(
                          propertyId: p.id, landlordId: p.ownerId, slot: 'أقرب وقت متاح',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب المعاينة ✓')));
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('حجز معاينة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'available': return '🟢 متاح';
      case 'unconfirmed': return '🟡 غير مؤكد';
      case 'rented': return '🔴 مؤجر';
      default: return s;
    }
  }

  Widget _specChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(10)),
      child: Text('$icon $label', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
