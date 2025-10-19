class TransactionModel {
  final String id;
  final String gigId;
  final String buyerId;
  final String sellerId;
  final int amount;
  final int platformFee;
  final int stripeFee;
  final int sellerPayout;
  final String status; // pending, processing, completed, failed
  final String? stripePaymentIntentId;
  final String? stripeTransferId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? buyerRating;
  final int? sellerRating;
  final String? buyerReview;
  final String? sellerReview;

  TransactionModel({
    required this.id,
    required this.gigId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.platformFee,
    required this.stripeFee,
    required this.sellerPayout,
    this.status = 'pending',
    this.stripePaymentIntentId,
    this.stripeTransferId,
    required this.createdAt,
    this.completedAt,
    this.buyerRating,
    this.sellerRating,
    this.buyerReview,
    this.sellerReview,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'amount': amount,
      'platformFee': platformFee,
      'stripeFee': stripeFee,
      'sellerPayout': sellerPayout,
      'status': status,
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeTransferId': stripeTransferId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'buyerRating': buyerRating,
      'sellerRating': sellerRating,
      'buyerReview': buyerReview,
      'sellerReview': sellerReview,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      gigId: json['gigId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      amount: json['amount'] ?? 0,
      platformFee: json['platformFee'] ?? 0,
      stripeFee: json['stripeFee'] ?? 0,
      sellerPayout: json['sellerPayout'] ?? 0,
      status: json['status'] ?? 'pending',
      stripePaymentIntentId: json['stripePaymentIntentId'],
      stripeTransferId: json['stripeTransferId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      buyerRating: json['buyerRating'],
      sellerRating: json['sellerRating'],
      buyerReview: json['buyerReview'],
      sellerReview: json['sellerReview'],
    );
  }
}
