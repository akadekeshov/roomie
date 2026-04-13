/// Model for listing from GET /api/listings and nested in GET /api/saved.
/// Matches backend Prisma Listing + owner select.
class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    required this.country,
    required this.price,
    required this.roomType,
    this.availableFrom,
    this.availableTo,
    required this.amenities,
    required this.images,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  final String id;
  final String title;
  final String description;
  final String address;
  final String city;
  final String? state;
  final String? zipCode;
  final String country;
  final double price;
  final String roomType;
  final String? availableFrom;
  final String? availableTo;
  final List<String> amenities;
  final List<String> images;
  final String ownerId;
  final String createdAt;
  final String updatedAt;
  final ListingOwner? owner;

  String get displayLocation {
    final parts = [city];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.join(', ');
  }

  String get ownerDisplayName {
    if (owner == null) return 'Пользователь';
    final first = owner!.firstName ?? '';
    final last = owner!.lastName ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? (owner!.email ?? 'Пользователь') : name;
  }

  String get firstImageUrl => images.isNotEmpty ? images.first : '';

  static Listing fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String,
      price: (json['price'] as num).toDouble(),
      roomType: json['roomType'] as String,
      availableFrom: json['availableFrom'] as String?,
      availableTo: json['availableTo'] as String?,
      amenities: _toStringList(json['amenities']),
      images: _toStringList(json['images']),
      ownerId: json['ownerId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      owner: json['owner'] != null
          ? ListingOwner.fromJson(
              (json['owner'] as Map<String, dynamic>).cast<String, dynamic>(),
            )
          : null,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'price': price,
      'roomType': roomType,
      'availableFrom': availableFrom,
      'availableTo': availableTo,
      'amenities': amenities,
      'images': images,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (owner != null) 'owner': owner!.toJson(),
    };
  }
}

class ListingOwner {
  const ListingOwner({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;

  static ListingOwner fromJson(Map<String, dynamic> json) {
    return ListingOwner(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };
}
