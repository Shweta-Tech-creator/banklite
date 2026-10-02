import 'firebase_banking_service.dart';

/// BankingService provides full Firebase backend connectivity and state management for BankLite.
/// Extends [FirebaseBankingService] to provide real-time Firestore synchronization,
/// Firebase Auth lifecycle management, and ACID transaction persistence.
class BankingService extends FirebaseBankingService {
  BankingService({super.prefs});
}
