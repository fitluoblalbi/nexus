
# NEXUS Lite - Technical Architecture

## Tech Stack

### Frontend
- **Flutter** (iOS + Android in one codebase)
- **Provider** (state management)
- **Dio** (API calls)

### Backend
- **Firebase** (Database + Auth + Hosting)
- **Cloud Firestore** (NoSQL database)
- **Cloud Storage** (Images)
- **Cloud Functions** (Backend logic)

### Payment
- **Stripe** (Process payments, escrow)

### Analytics
- **Firebase Analytics** (Track user behavior)

---

## Database Schema

### Collection: `users`

/users/{userId} ├── email: "john@example.com [blocked]" ├── name: "John Doe" ├── skills: ["design", "writing"] ├── hourlyRate: 50 ├── bio: "Expert designer, 5+ years" ├── profileImage: "gs://bucket/profile/john.jpg" ├── rating: 4.8 ├── totalEarned: 5000 ├── completedGigs: 12 ├── joinedDate: 1704067200000 ├── stripeAccountId: "acct_xxx" └── verified: true


### Collection: `gigs`

/gigs/{gigId} ├── title: "Design a modern logo" ├── description: "Need a logo for my startup..." ├── category: "Design" ├── budget: 500 ├── posterId: "user123" ├── posterName: "Jane" ├── posterRating: 4.5 ├── status: "open" // open, hired, completed, cancelled ├── createdAt: 1704067200000 ├── updatedAt: 1704067200000 ├── images: ["gs://bucket/gig/design1.jpg"] ├── bidCount: 12 └── savedBy: ["user456", "user789"]


### Collection: `gigs/{gigId}/bids`

/gigs/{gigId}/bids/{bidId} ├── freelancerId: "user456" ├── freelancerName: "John" ├── freelancerRating: 4.8 ├── proposedPrice: 450 ├── message: "I can do this in 3 days..." ├── status: "pending" // pending, accepted, rejected ├── createdAt: 1704067200000 └── updatedAt: 1704067200000


### Collection: `conversations`

/conversations/{conversationId} ├── participantIds: ["user123", "user456"] ├── gigId: "gig789" ├── gigTitle: "Design a logo" ├── lastMessage: "Sounds good, I'll start tomorrow" ├── lastMessageTime: 1704067200000 ├── unreadCount: {"user123": 0, "user456": 2} └── createdAt: 1704067200000

/conversations/{conversationId}/messages/{messageId} ├── senderId: "user123" ├── senderName: "Jane" ├── text: "Can you start by Friday?" ├── timestamp: 1704067200000 ├── read: true ├── messageType: "text" // text, image, attachment └── metadata: {}


### Collection: `transactions`

/transactions/{transactionId} ├── gigId: "gig789" ├── buyerId: "user123" ├── sellerId: "user456" ├── amount: 500 ├── platformFee: 75 // 15% ├── stripeFee: 15 // 2.9% ├── sellerPayout: 410 ├── status: "completed" // pending, processing, completed, failed ├── stripePaymentIntentId: "pi_xxx" ├── stripeTransferId: "tr_xxx" ├── createdAt: 1704067200000 ├── completedAt: 1704154600000 ├── buyerRating: 5 ├── sellerRating: 5 ├── buyerReview: "Great work! Highly recommend" └── sellerReview: "Easy to work with"


### Collection: `payouts`

/payouts/{payoutId} ├── userId: "user456" ├── amount: 1000 ├── bankAccount: "***4242" ├── status: "completed" // pending, processing, completed, failed ├── stripePayoutId: "po_xxx" ├── requestedAt: 1704067200000 ├── completedAt: 1704153600000 └── metadata: {}


---

## Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
      allow list: if true; // Can see public profiles
    }

    // Gigs are public to read
    match /gigs/{gigId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.posterId;
      
      // Bids - only owner can read their bids
      match /bids/{bidId} {
        allow create: if request.auth != null;
        allow read: if request.auth.uid == resource.data.freelancerId || 
                       request.auth.uid == get(/databases/$(database)/documents/gigs/$(gigId)).data.posterId;
      }
    }

    // Conversations - only participants can read/write
    match /conversations/{conversationId} {
      allow read, write: if request.auth.uid in resource.data.participantIds;
      
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participantIds;
      }
    }

    // Transactions - only participants can read
    match /transactions/{transactionId} {
      allow read: if request.auth.uid == resource.data.buyerId || 
                     request.auth.uid == resource.data.sellerId;
      allow write: if false; // Only backend can write
    }

    // Payouts - only owner can read
    match /payouts/{payoutId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if false; // Only backend can write
    }
  }
}

API Endpoints (Cloud Functions)
1. Create Payment Intent

POST /api/payments/create-intent
Body: {
  gigId: "gig123",
  amount: 500,
  buyerId: "user123"
}
Response: {
  clientSecret: "pi_xxx_secret_xxx",
  paymentIntentId: "pi_xxx"
}

2. Confirm Payment

POST /api/payments/confirm
Body: {
  paymentIntentId: "pi_xxx",
  gigId: "gig123"
}
Response: {
  status: "success",
  transactionId: "txn_xxx"
}

3. Release Payment

POST /api/payments/release
Body: {
  transactionId: "txn_xxx"
}
Response: {
  status: "released",
  sellerAmount: 410
}

4. Request Payout

POST /api/payouts/request
Body: {
  amount: 1000,
  bankAccount: "tok_xxx"
}
Response: {
  payoutId: "po_xxx",
  status: "pending"
}

File Structure

nexus-lite-mvp/
├── README.md
├── docs/
│   ├── PROJECT_PLAN.md
│   ├── ARCHITECTURE.md
│   ├── FEATURES.md
│   ├── ROADMAP.md
│   └── REVENUE_MODEL.md
└── flutter_code/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── gig_model.dart
    │   │   ├── bid_model.dart
    │   │   └── transaction_model.dart
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── signup_screen.dart
    │   │   │   ├── login_screen.dart
    │   │   │   └── profile_setup_screen.dart
    │   │   ├── marketplace/
    │   │   │   ├── browse_gigs_screen.dart
    │   │   │   ├── gig_detail_screen.dart
    │   │   │   ├── post_gig_screen.dart
    │   │   │   └── my_gigs_screen.dart
    │   │   ├── messaging/
    │   │   │   ├── conversations_screen.dart
    │   │   │   └── chat_screen.dart
    │   │   ├── dashboard/
    │   │   │   ├── dashboard_screen.dart
    │   │   │   ├── income_screen.dart
    │   │   │   └── profile_screen.dart
    │   │   └── payments/
    │   │       ├── payment_screen.dart
    │   │       └── cashout_screen.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   ├── firestore_service.dart
    │   │   ├── storage_service.dart
    │   │   ├── stripe_service.dart
    │   │   └── notification_service.dart
    │   ├── widgets/
    │   │   ├── gig_card.dart
    │   │   ├── bid_card.dart
    │   │   ├── message_bubble.dart
    │   │   └── loading_widget.dart
    │   ├── constants/
    │   │   ├── colors.dart
    │   │   ├── strings.dart
    │   │   └── firebase_config.dart
    │   └── utils/
    │       ├── validators.dart
    │       └── formatters.dart
    ├── pubspec.yaml
    ├── ios/
    ├── android/
    └── web/

Development Workflow
1. Authentication Flow

User → SignUp Screen → Firebase Auth → Profile Setup → Home
     ↓
     Login Screen → Firebase Auth → Home

2. Gig Posting Flow

User → Post Gig Screen → Upload Image → Firestore Save → Browse Screen

3. Bidding Flow

Buyer posts gig → Freelancer sees it → Bids → Buyer accepts → Chat starts

4. Payment Flow

Buyer clicks "Hire" → Payment Screen → Stripe Payment Intent
→ Money held in escrow → Freelancer completes work → Buyer approves
→ Release payment to freelancer → We take 15%

Deployment
Phase 1: Local Testing

flutter run (iOS)
flutter run -d chrome (Web)

Phase 2: Firebase Deploy

firebase deploy --functions
firebase deploy --hosting

Phase 3: App Store

iOS: Xcode build → TestFlight → App Store
Android: Android Studio build → Google Play

Performance Targets

    App startup: < 3 seconds
    Gig loading: < 1 second
    Payment processing: < 5 seconds
    Chat messages: < 500ms
