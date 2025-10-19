class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final List<String> skills;
  final int? hourlyRate;
  final String? bio;
  final double rating;
  final int completedGigs;
  final double totalEarned;
  final DateTime joinedDate;
  final String? stripeAccountId;
  final bool verified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.skills = const [],
    this.hourlyRate,
    this.bio,
    this.rating = 0.0,
    this.completedGigs = 0,
    this.totalEarned = 0.0,
    required this.joinedDate,
    this.stripeAccountId,
    this.verified = false,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'rating': rating,
      'completedGigs': completedGigs,
      'totalEarned': totalEarned,
      'joinedDate': joinedDate.toIso8601String(),
      'stripeAccountId': stripeAccountId,
      'verified': verified,
    };
  }

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      skills: List<String>.from(json['skills'] ?? []),
      hourlyRate: json['hourlyRate'],
      bio: json['bio'],
      rating: (json['rating'] ?? 0).toDouble(),
      completedGigs: json['completedGigs'] ?? 0,
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      joinedDate: DateTime.parse(json['joinedDate'] ?? DateTime.now().toIso8601String()),
      stripeAccountId: json['stripeAccountId'],
      verified: json['verified'] ?? false,
    );
  }

  // Copy with updates
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    List<String>? skills,
    int? hourlyRate,
    String? bio,
    double? rating,
    int? completedGigs,
    double? totalEarned,
    DateTime? joinedDate,
    String? stripeAccountId,
    bool? verified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      skills: skills ?? this.skills,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      completedGigs: completedGigs ?? this.completedGigs,
      totalEarned: totalEarned ?? this.totalEarned,
      joinedDate: joinedDate ?? this.joinedDate,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      verified: verified ?? this.verified,
    );
  }
}
