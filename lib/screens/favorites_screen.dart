import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/supabase_service.dart';
import 'property_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Property> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SupabaseService.fetchFavoriteProperties();
      setState(() { _items = list; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('المفضلة')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? ListView(children: const [
                    Padding(
                      padding: EdgeInsets.all(60),
                      child: Center(child: Text('ما ضفت أي عقار للمفضلة بعد', style: TextStyle(color: AppColors.muted))),
                    ),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final p = _items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 60, height: 60,
                              child: p.photos.isNotEmpty
                                  ? Image.network(p.photos.first, fit: BoxFit.cover)
                                  : Container(color: AppColors.bluePale),
                            ),
                          ),
                          title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${p.area} · ${p.price.toStringAsFixed(0)} د.أ'),
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p)));
                            _load();
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
