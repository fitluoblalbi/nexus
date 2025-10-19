class GigModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int budget;
  final String posterId;
  final String posterName;
  final double posterRating;
  final String status; // open, hired, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final int bidCount;
  final List<String>? savedBy;

  GigModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.posterId,
    required this.posterName,
    required this.posterRating,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.bidCount = 0,
    this.savedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'posterId': posterId,
      'posterName': posterName,
      'posterRating': posterRating,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'images': images,
      'bidCount': bidCount,
      'savedBy': savedBy ?? [],
    };
  }

  factory GigModel.fromJson(Map<String, dynamic> json) {
    return GigModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      budget: json['budget'] ?? 0,
      posterId: json['posterId'] ?? '',
      posterName: json['posterName'] ?? '',
      posterRating: (json['posterRating'] ?? 0).toDouble(),
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
      bidCount: json['bidCount'] ?? 0,
      savedBy: List<String>.from(json['savedBy'] ?? []),
    );
  }
}
