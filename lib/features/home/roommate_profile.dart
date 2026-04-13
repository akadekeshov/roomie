class RoommateProfile {
  const RoommateProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.status,
    required this.budget,
    required this.imageUrl,
    required this.verified,
  });

  final String id;
  final String name;
  final int age;
  final String location;
  final String status;
  final String budget;
  final String imageUrl;
  final bool verified;
}
