import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/gig_model.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import '../../services/stripe_service.dart';
import '../../utils/formatters.dart';

class PaymentScreen extends StatefulWidget {
  final GigModel gig;
  final int proposedPrice;
  final String freelancerId;

  const PaymentScreen({
    required this.gig,
    required this.proposedPrice,
    required this.freelancerId,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _firestoreService = FirestoreService();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = false;
  bool _agreeToTerms = false;

  Future<void> _processPayment() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to terms')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fees = StripeService.calculateFees(widget.proposedPrice);

      // Create transaction
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        gigId: widget.gig.id,
        buyerId: _currentUserId,
        sellerId: widget.freelancerId,
        amount: widget.proposedPrice,
        platformFee: fees['platformFee']!,
        stripeFee: fees['stripeFee']!,
        sellerPayout: fees['sellerPayout']!,
        createdAt: DateTime.now(),
      );

      final transactionId = await _firestoreService.createTransaction(
        transaction: transaction,
      );

      // TODO: Integrate Stripe payment processing here

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.paymentSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.paymentFailed}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fees = StripeService.calculateFees(widget.proposedPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.confirmPayment),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gig info
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.gig.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Freelancer: ${widget.freelancerId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Breakdown
            Text(
              'Price Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 12),
            _buildBreakdownRow(
              'Service Amount',
              Formatters.formatCurrency(widget.proposedPrice.toDouble()),
            ),
            SizedBox(height: 8),
            _buildBreakdownRow(
              'Platform Fee (15%)',
              Formatters.formatCurrency(fees['platformFee']!.toDouble()),
              isSubtle: true,
            ),
            SizedBox(height: 8),
            _buildBreakdownRow(
              'Payment Processing',
              Formatters.formatCurrency(fees['stripeFee']!.toDouble()),
              isSubtle: true,
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            _buildBreakdownRow(
              'Total Amount',
              Formatters.formatCurrency(
                (widget.proposedPrice + fees['platformFee']! + fees['stripeFee']!)
                    .toDouble(),
              ),
              isBold: true,
            ),
            SizedBox(height: 24),
            // Terms
            CheckboxListTile(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() => _agreeToTerms = value ?? false);
              },
              title: Text(
                'I agree to the terms and conditions',
                style: TextStyle(fontSize: 12),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 32),
            // Payment button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Pay ${Formatters.formatCurrency((widget.proposedPrice + fees['platformFee']! + fees['stripeFee']!).toDouble())}',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String amount, {
    bool isSubtle = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSubtle ? AppColors.grey : AppColors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
