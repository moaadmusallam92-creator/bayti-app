class Property {
  final String id;
  final String ownerId;
  final String propertyType;
  final String title;
  final String? description;
  final double price;
  final double deposit;
  final bool negotiable;
  final int bedrooms;
  final int bathrooms;
  final double? areaSqm;
  final String? floor;
  final bool furnished;
  final List<String> features;
  final List<String> photos;
  final String area;
  final String? neighborhood;
  final bool approximateLocation;
  final bool suitableFamily;
  final bool suitableSingle;
  final bool petsAllowed;
  final bool smokingAllowed;
  final String availabilityStatus;
  final String verificationStatus;
  final int views;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.propertyType,
    required this.title,
    this.description,
    required this.price,
    this.deposit = 0,
    this.negotiable = false,
    required this.bedrooms,
    required this.bathrooms,
    this.areaSqm,
    this.floor,
    this.furnished = false,
    this.features = const [],
    this.photos = const [],
    required this.area,
    this.neighborhood,
    this.approximateLocation = true,
    this.suitableFamily = false,
    this.suitableSingle = false,
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.availabilityStatus = 'available',
    this.verificationStatus = 'pending',
    this.views = 0,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      propertyType: json['property_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      negotiable: json['negotiable'] as bool? ?? false,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      floor: json['floor'] as String?,
      furnished: json['furnished'] as bool? ?? false,
      features: List<String>.from(json['features'] ?? const []),
      photos: List<String>.from(json['photos'] ?? const []),
      area: json['area'] as String,
      neighborhood: json['neighborhood'] as String?,
      approximateLocation: json['approximate_location'] as bool? ?? true,
      suitableFamily: json['suitable_family'] as bool? ?? false,
      suitableSingle: json['suitable_single'] as bool? ?? false,
      petsAllowed: json['pets_allowed'] as bool? ?? false,
      smokingAllowed: json['smoking_allowed'] as bool? ?? false,
      availabilityStatus: json['availability_status'] as String? ?? 'available',
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      views: json['views'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'property_type': propertyType,
      'title': title,
      'description': description,
      'price': price,
      'deposit': deposit,
      'negotiable': negotiable,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqm': areaSqm,
      'floor': floor,
      'furnished': furnished,
      'features': features,
      'photos': photos,
      'area': area,
      'neighborhood': neighborhood,
      'approximate_location': approximateLocation,
      'suitable_family': suitableFamily,
      'suitable_single': suitableSingle,
      'pets_allowed': petsAllowed,
      'smoking_allowed': smokingAllowed,
    };
  }
}
