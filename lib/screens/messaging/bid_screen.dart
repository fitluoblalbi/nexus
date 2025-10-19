import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/bid_model.dart';
import '../../models/gig_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';

class BidScreen extends StatefulWidget {
  final GigModel gig;

  const BidScreen({
    required this.gig,
    Key? key,
  }) : super(key: key);

  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late TextEditingController _priceController;
  late TextEditingController _messageController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bid = BidModel(
        id: const Uuid().v4(),
        gigId: widget.gig.id,
        freelancerId: _currentUserId,
        freelancerName: 'Current User', // TODO: Get from auth
        freelancerRating: 0.0,
        proposedPrice: int.parse(_priceController.text),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.postBid(
        gigId: widget.gig.id,
        bid: bid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting bid: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Bid'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gig info
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
                      'Budget: \$${widget.gig.budget}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Proposed price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Proposed Price',
                  prefixText: '\$ ',
                  helperText:
                      'Budget for this gig is \$${widget.gig.budget}',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = int.tryParse(value);
                  if (price == null) {
                    return 'Invalid price';
                  }
                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Cover Letter',
                  hintText: 'Tell the client why you\'re the perfect fit...',
                ),
                validator: Validators.validateMessage,
              ),
              SizedBox(height: 32),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBid,
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Submit Bid'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
