# Rupiah Finance Tracker

**Rupiah Finance Tracker** is a mobile application developed using the Flutter framework, designed to facilitate efficient personal financial management. The application enables users to track income and expenses across multiple distinct wallets, providing real-time synchronization of financial data and net worth calculation.

## Project Overview

This application serves as a centralized platform for tracking financial health. It leverages a feature-first architecture to ensure scalability and maintainability. Key functionalities include secure authentication, real-time database updates, and comprehensive wallet management.

## Key Features

* **Secure Authentication**: Implements Google Sign-In via Firebase Authentication for secure and seamless user access.
* **Wallet Management**: Allows users to create multiple wallets (e.g., Bank, Cash) with custom initial balances. Users can also delete wallets as needed.
* **Transaction Tracking**: Facilitates the recording of income and expense transactions. The system automatically adjusts wallet balances based on the transaction type.
* **Real-Time Dashboard**: Displays a live overview of total net worth and individual wallet balances, updated instantly via reactive streams.
* **Currency Formatting**: Built-in localization support for the Indonesian Rupiah (IDR) format.

## Technology Stack

The project utilizes a modern Flutter technology stack integrated with Firebase services.

### Core Framework
* **Flutter**: SDK version ^3.10.3.
* **Dart**: The primary programming language used for application logic.

### Backend Services
* **Firebase Authentication**: Manages user identity and authentication flows.
* **Cloud Firestore**: A NoSQL cloud database used for storing transaction and wallet data.

### State Management
* **Riverpod**: The application uses `flutter_riverpod` for robust state management and dependency injection.
    * **StreamProvider**: utilized for listening to real-time data changes from Firestore.
    * **AsyncNotifier**: employed to handle asynchronous business logic and state mutations.

### Dependencies
Key packages included in `pubspec.yaml`:
* `flutter_riverpod`
* `firebase_core`, `firebase_auth`, `cloud_firestore`
* `google_sign_in`
* `intl`
* `equatable`
* `uuid`

## Project Structure

The codebase follows a modular, feature-first directory structure to separate concerns effectively.

```text
lib/
├── core/
│   └── utils/              # Shared utilities (e.g., CurrencyFormatter)
├── features/
│   ├── auth/               # Authentication logic and UI
│   ├── transactions/       # Transaction data layer, domain, and presentation
│   └── wallets/            # Wallet management and dashboard UI
└── main.dart               # Application entry point

## Getting Started
Follow these instructions to set up the project locally.

### Prerequisites
* Flutter SDK installed on your machine.
* A Firebase project created via the Firebase Console.

### Installation
1. Clone the repository

```git clone [https://github.com/your-username/rupiah-finance-tracker.git](https://github.com/your-username/rupiah-finance-tracker.git)```

2. Install dependencies Navigate to the project directory and run:

```flutter pub get```

3. Configure Firebase Ensure you have the google-services.json (for Android) and GoogleService-Info.plist (for iOS) placed in their respective directories (android/app/ and ios/Runner/).

4. Run the application

```flutter run```