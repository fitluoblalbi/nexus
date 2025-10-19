import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/gig_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/loading_widget.dart';
import 'gig_detail_screen.dart';
import 'post_gig_screen.dart';

class MyGigsScreen extends StatefulWidget {
  const MyGigsScreen({Key? key}) : super(key: key);

  @override
  State<MyGigsScreen> createState() => _MyGigsScreenState();
}

class _MyGigsScreenState extends State<MyGigsScreen> {
  final _firestoreService = FirestoreService();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String _filterStatus = 'all'; // all, open, hired, completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myGigs),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostGigScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['all', 'open', 'hired', 'completed']
                          .map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              status.toUpperCase(),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _filterStatus = status);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Gigs list
          Expanded(
            child: StreamBuilder<List<GigModel>>(
              stream: _firestoreService.getUserGigs(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget(message: 'Loading your gigs...');
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<GigModel> gigs = snapshot.data ?? [];

                // Apply filter
                if (_filterStatus != 'all') {
                  gigs = gigs
                      .where((gig) => gig.status == _filterStatus)
                      .toList();
                }

                if (gigs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppColors.greyLighter,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No gigs yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostGigScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Post Your First Gig'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: gigs.length,
                  itemBuilder: (context, index) {
                    return GigCard(
                      gig: gigs[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GigDetailScreen(gig: gigs[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
