import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/firebase_config.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _publishableKey = 

  // Create payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount, // in cents
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_publishableKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('Create payment intent error: $e');
      rethrow;
    }
  }

  // Confirm payment
  static Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $_publishableKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method': paymentMethodId,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      print('Confirm payment error: $e');
      rethrow;
    }
  }

  // Calculate fees
  static Map<String, int> calculateFees(int amount) {
    final platformFee = (amount * 0.15).toInt(); // 15%
    final stripeFee = (amount * 0.029).toInt() + 30; // 2.9% + $0.30
    final sellerPayout = amount - platformFee - stripeFee;

    return {
      'platformFee': platformFee,
      'stripeFee': stripeFee,
      'sellerPayout': sellerPayout,
    };
  }
}
