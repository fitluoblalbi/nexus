import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/gig_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/loading_widget.dart';
import 'gig_detail_screen.dart';

class BrowseGigsScreen extends StatefulWidget {
  const BrowseGigsScreen({Key? key}) : super(key: key);

  @override
  State<BrowseGigsScreen> createState() => _BrowseGigsScreenState();
}

class _BrowseGigsScreenState extends State<BrowseGigsScreen> {
  final _firestoreService = FirestoreService();
  
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Design',
    'Writing',
    'Coding',
    'Marketing',
    'Video',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.browseGigs),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search gigs...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Categories
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Gigs List
          Expanded(
            child: StreamBuilder<List<GigModel>>(
              stream: _firestoreService.getAllGigs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget(message: 'Loading gigs...');
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading gigs: ${snapshot.error}'),
                  );
                }

                List<GigModel> gigs = snapshot.data ?? [];

                // Filter by category
                if (_selectedCategory != 'All') {
                  gigs = gigs
                      .where((gig) => gig.category == _selectedCategory)
                      .toList();
                }

                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  gigs = gigs
                      .where((gig) =>
                          gig.title.toLowerCase().contains(query) ||
                          gig.description.toLowerCase().contains(query))
                      .toList();
                }

                if (gigs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.greyLighter,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No gigs found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
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
