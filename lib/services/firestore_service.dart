import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gig_model.dart';
import '../models/bid_model.dart';
import '../models/message_model.dart';
import '../models/transaction_model.dart';
import '../constants/firebase_config.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ GIGS ============

  // Post a new gig
  Future<String> postGig({
    required GigModel gig,
  }) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .add(gig.toJson());
      return docRef.id;
    } catch (e) {
      print('Post gig error: $e');
      rethrow;
    }
  }

  // Get all gigs
  Stream<List<GigModel>> getAllGigs() {
    return _firestore
        .collection(FirebaseConfig.gigsCollection)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GigModel.fromJson(data);
      }).toList();
    });
  }

  // Get user's gigs
  Stream<List<GigModel>> getUserGigs(String userId) {
    return _firestore
        .collection(FirebaseConfig.gigsCollection)
        .where('posterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GigModel.fromJson(data);
      }).toList();
    });
  }

  // Get single gig
  Future<GigModel?> getGig(String gigId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .doc(gigId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return GigModel.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Get gig error: $e');
      return null;
    }
  }

  // Update gig status
  Future<void> updateGigStatus(String gigId, String status) async {
    try {
      await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .doc(gigId)
          .update({'status': status, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Update gig status error: $e');
      rethrow;
    }
  }

  // ============ BIDS ============

  // Post a bid
  Future<String> postBid({
    required String gigId,
    required BidModel bid,
  }) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .doc(gigId)
          .collection(FirebaseConfig.bidsCollection)
          .add(bid.toJson());

      // Update bid count
      await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .doc(gigId)
          .update({'bidCount': FieldValue.increment(1)});

      return docRef.id;
    } catch (e) {
      print('Post bid error: $e');
      rethrow;
    }
  }

  // Get bids for a gig
  Stream<List<BidModel>> getGigBids(String gigId) {
    return _firestore
        .collection(FirebaseConfig.gigsCollection)
        .doc(gigId)
        .collection(FirebaseConfig.bidsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['gigId'] = gigId;
        return BidModel.fromJson(data);
      }).toList();
    });
  }

  // Get user's bids
  Stream<List<BidModel>> getUserBids(String userId) {
    return _firestore
        .collectionGroup(FirebaseConfig.bidsCollection)
        .where('freelancerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BidModel.fromJson(data);
      }).toList();
    });
  }

  // Accept bid
  Future<void> acceptBid({
    required String gigId,
    required String bidId,
    required String freelancerId,
  }) async {
    try {
      // Update bid status
      await _firestore
          .collection(FirebaseConfig.gigsCollection)
          .doc(gigId)
          .collection(FirebaseConfig.bidsCollection)
          .doc(bidId)
          .update({
        'status': 'accepted',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update gig status
      await updateGigStatus(gigId, 'hired');

      // Create conversation
      await createConversation(
        participantIds: [_firestore.collection('dummy').doc().id, freelancerId],
        gigId: gigId,
      );
    } catch (e) {
      print('Accept bid error: $e');
      rethrow;
    }
  }

  // ============ MESSAGING ============

  // Create conversation
  Future<String> createConversation({
    required List<String> participantIds,
    required String gigId,
  }) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .add({
        'participantIds': participantIds,
        'gigId': gigId,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      return docRef.id;
    } catch (e) {
      print('Create conversation error: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String conversationId,
    required MessageModel message,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .collection(FirebaseConfig.messagesCollection)
          .add(message.toJson());

      // Update last message
      await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .update({
        'lastMessage': message.text,
        'lastMessageTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Send message error: $e');
      rethrow;
    }
  }

  // Get messages
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection(FirebaseConfig.conversationsCollection)
        .doc(conversationId)
        .collection(FirebaseConfig.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MessageModel.fromJson(data);
      }).toList();
    });
  }

  // Get conversations for user
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    return _firestore
        .collection(FirebaseConfig.conversationsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============ TRANSACTIONS ============

  // Create transaction
  Future<String> createTransaction({
    required TransactionModel transaction,
  }) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.transactionsCollection)
          .add(transaction.toJson());

      return docRef.id;
    } catch (e) {
      print('Create transaction error: $e');
      rethrow;
    }
  }

  // Get transaction
  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.transactionsCollection)
          .doc(transactionId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Get transaction error: $e');
      return null;
    }
  }

  // Get user transactions
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    });
  }

  // Update transaction status
  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _firestore
          .collection(FirebaseConfig.transactionsCollection)
          .doc(transactionId)
          .update({
        'status': status,
        if (status == 'completed') 'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Update transaction status error: $e');
      rethrow;
    }
  }
}
