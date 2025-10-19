class BidModel {
  final String id;
  final String gigId;
  final String freelancerId;
  final String freelancerName;
  final double freelancerRating;
  final int proposedPrice;
  final String message;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  BidModel({
    required this.id,
    required this.gigId,
    required this.freelancerId,
    required this.freelancerName,
    required this.freelancerRating,
    required this.proposedPrice,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt, 
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'freelancerId': freelancerId,
      'freelancerName': freelancerName,
      'freelancerRating': freelancerRating,
      'proposedPrice': proposedPrice,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] ?? '',
      gigId: json['gigId'] ?? '',
      freelancerId: json['freelancerId'] ?? '',
      freelancerName: json['freelancerName'] ?? '',
      freelancerRating: (json['freelancerRating'] ?? 0).toDouble(),
      proposedPrice: json['proposedPrice'] ?? 0,
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
