import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/bid_model.dart';
import '../../models/gig_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/bid_card.dart';
import '../../widgets/loading_widget.dart';
import '../messaging/bid_screen.dart';

class GigDetailScreen extends StatefulWidget {
  final GigModel gig;

  const GigDetailScreen({
    required this.gig,
    Key? key,
  }) : super(key: key);

  @override
  State<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends State<GigDetailScreen> {
  final _firestoreService = FirestoreService();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool _isPostedByCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _isPostedByCurrentUser = widget.gig.posterId == _currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gig Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gig Image
            if (widget.gig.images.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  widget.gig.images[0],
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: AppColors.greyLight,
                child: Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: AppColors.grey,
                ),
              ),
            SizedBox(height: 20),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Budget
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.gig.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.gig.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              Formatters.formatCurrency(
                                widget.gig.budget.toDouble(),
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Budget',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Poster Info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.gig.posterName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    Formatters.formatRating(
                                      widget.gig.posterRating,
                                    ),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.gig.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Posted Time
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Posted ${Formatters.formatRelativeTime(widget.gig.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Bids
                  Text(
                    '${AppStrings.bids} (${widget.gig.bidCount})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            // Bids List
            _isPostedByCurrentUser
                ? StreamBuilder<List<BidModel>>(
                    stream: _firestoreService.getGigBids(widget.gig.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: LoadingWidget(),
                        );
                      }

                      final bids = snapshot.data ?? [];

                      if (bids.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No bids yet'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bids.length,
                        itemBuilder: (context, index) {
                          return BidCard(
                            bid: bids[index],
                            showActions: widget.gig.status == 'open',
                            onAccept: () {
                              // TODO: Accept bid
                            },
                            onReject: () {
                              // TODO: Reject bid
                            },
                          );
                        },
                      );
                    },
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BidScreen(gig: widget.gig),
                            ),
                          );
                        },
                        child: Text(AppStrings.interested),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
