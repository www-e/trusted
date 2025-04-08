# Trusted App

A production-ready Flutter application targeting Android and iOS with a multi-step sign-up process, Google OAuth integration, and role-based access. The app uses Supabase for authentication and data storage, supports Arabic RTL, and is compatible with older devices.

## Features

- **Authentication**
  - Google OAuth Sign-In with in-app account selection
  - Role-based access control
  - Admin authentication via email/password

- **Multi-Step Sign-Up Flow**
  - Step 1: Role Selection (Buyer/Seller, Merchant, Mediator)
  - Step 2: Information Entry with role-specific fields
  - Step 3: Confirmation and submission

- **Admin Dashboard**
  - View pending users
  - Approve or reject user registrations

- **Modern UI/UX**
  - Dark and light mode support
  - Full Arabic RTL support
  - Smooth transitions between sign-up steps
  - Progress bar for multi-step processes

## Technical Specifications

- **State Management**: Flutter Riverpod
- **Authentication**: Supabase + Google Sign-In
- **Database**: Supabase
- **Form Handling**: Flutter Form Builder
- **Architecture**: SOLID principles with feature-based modules
- **Compatibility**: Android SDK 21+ and iOS 11+

## Project Structure

```
lib/
├── core/
│   ├── config/         # Environment configuration
│   ├── constants/      # Application constants
│   ├── theme/          # Theme configuration
│   ├── utils/          # Utility functions
│   └── widgets/        # Shared widgets
├── features/
│   ├── admin/          # Admin dashboard feature
│   │   ├── data/       # Data layer
│   │   ├── domain/     # Domain layer (models, repositories)
│   │   └── presentation/ # UI layer
│   ├── auth/           # Authentication feature
│   │   ├── data/       # Data layer
│   │   ├── domain/     # Domain layer (models, repositories)
│   │   └── presentation/ # UI layer
│   └── profile/        # User profile feature
│       ├── data/       # Data layer
│       ├── domain/     # Domain layer (models, repositories)
│       └── presentation/ # UI layer
└── main.dart           # Application entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK (^3.0.0)
- Android Studio / VS Code
- Supabase account
- Google Cloud Platform account (for OAuth)

### Environment Setup

1. Clone the repository
2. Create a `.env` file in the root directory with the following variables:
   ```
   # Supabase Configuration
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key

   # Google Sign-In Configuration
   GOOGLE_CLIENT_ID_ANDROID=your_android_client_id
   GOOGLE_CLIENT_ID_IOS=your_ios_client_id

   # Deep Link Configuration
   DEEP_LINK_SCHEME=trusted
   DEEP_LINK_HOST=auth
   ```

3. Configure your Google OAuth credentials:
   - For Android: Add your SHA-1 and SHA-256 fingerprints to your Google Cloud project
   - For iOS: Configure the URL types in your Info.plist

### Database Setup

Run the SQL script in `supabase/migrations/20250408_create_users_table.sql` in your Supabase SQL editor to create the required tables and security policies.

### Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Admin Access

- Admin email: omarasj445@gmail.com
- Password: Set this in your Supabase authentication settings

## Best Practices Implemented

- SOLID principles
- Clean architecture
- Separation of concerns
- Responsive design
- Error handling
- Form validation
- Secure authentication
- Proper state management
- Arabic localization and RTL support

## License

This project is proprietary and confidential.
