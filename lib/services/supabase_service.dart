import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';

const String supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
const String supabaseAnonKey = 'YOUR-ANON-KEY';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static Future<void> signInWithPhone(String phone) async {
    await client.auth.signInWithOtp(phone: phone);
  }

  static Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    return client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  static Future<void> signInWithEmailMagicLink(String email) async {
    await client.auth.signInWithOtp(email: email);
  }

  static User? get currentUser => client.auth.currentUser;

  static Future<void> upsertProfile({required String fullName, required String phone}) async {
    final uid = currentUser!.id;
    await client.from('profiles').upsert({
      'id': uid,
      'full_name': fullName,
      'phone': phone,
    });
  }

  static Future<List<Property>> fetchApprovedProperties({
    String? area,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    var query = client.from('properties').select().eq('verification_status', 'approved');
    if (area != null && area.isNotEmpty) query = query.eq('area', area);
    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);
    if (bedrooms != null) query = query.eq('bedrooms', bedrooms);

    final rows = await query.order('created_at', ascending: false);
    return (rows as List).map((r) => Property.fromJson(r)).toList();
  }

  static Future<void> addProperty(Property draft) async {
    final data = draft.toInsertJson();
    data['owner_id'] = currentUser!.id;
    await client.from('properties').insert(data);
  }

  static Future<void> markPropertyRented(String propertyId) async {
    await client.from('properties').update({'availability_status': 'rented'}).eq('id', propertyId);
  }

  static Future<void> confirmAvailability(String propertyId) async {
    await client.from('properties').update({'availability_status': 'available'}).eq('id', propertyId);
  }

  static Future<void> togglePause(String propertyId, bool currentlyPaused) async {
    await client.from('properties').update({'paused': !currentlyPaused}).eq('id', propertyId);
  }

  static Future<void> deleteProperty(String propertyId) async {
    await client.from('properties').delete().eq('id', propertyId);
  }

  static Future<List<Property>> fetchMyProperties() async {
    final rows = await client.from('properties').select().eq('owner_id', currentUser!.id).order('created_at', ascending: false);
    return (rows as List).map((r) => Property.fromJson(r)).toList();
  }

  static Future<List<Property>> fetchFavoriteProperties() async {
    final rows = await client
        .from('favorites')
        .select('property_id, properties(*)')
        .eq('user_id', currentUser!.id);
    return (rows as List)
        .where((r) => r['properties'] != null)
        .map((r) => Property.fromJson(r['properties']))
        .toList();
  }

  static Future<Set<String>> fetchFavoriteIds() async {
    final rows = await client.from('favorites').select('property_id').eq('user_id', currentUser!.id);
    return (rows as List).map((r) => r['property_id'] as String).toSet();
  }

  static Future<void> toggleFavorite(String propertyId, bool isFav) async {
    final uid = currentUser!.id;
    if (isFav) {
      await client.from('favorites').delete().match({'user_id': uid, 'property_id': propertyId});
    } else {
      await client.from('favorites').insert({'user_id': uid, 'property_id': propertyId});
    }
  }

  static Future<void> sendMessage({
    required String receiverId,
    required String propertyId,
    required String body,
  }) async {
    await client.from('messages').insert({
      'sender_id': currentUser!.id,
      'receiver_id': receiverId,
      'property_id': propertyId,
      'body': body,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchThread(String propertyId, String otherUserId) async {
    final uid = currentUser!.id;
    final rows = await client
        .from('messages')
        .select()
        .eq('property_id', propertyId)
        .or('and(sender_id.eq.$uid,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$uid)')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> addRentalRequest(Map<String, dynamic> data) async {
    data['tenant_id'] = currentUser!.id;
    await client.from('rental_requests').insert(data);
  }

  static Future<List<Map<String, dynamic>>> fetchMyRentalRequests() async {
    final rows = await client.from('rental_requests').select().eq('tenant_id', currentUser!.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> fetchOpenRentalRequests() async {
    final rows = await client.from('rental_requests').select().eq('status', 'active').order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>?> fetchMyProfile() async {
    final row = await client.from('profiles').select().eq('id', currentUser!.id).maybeSingle();
    return row;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> requestViewing({
    required String propertyId,
    required String landlordId,
    required String slot,
  }) async {
    await client.from('viewing_requests').insert({
      'property_id': propertyId,
      'tenant_id': currentUser!.id,
      'landlord_id': landlordId,
      'requested_slot': slot,
    });
  }
}
