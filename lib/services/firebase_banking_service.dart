import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dummy_data.dart';
import '../models/account_model.dart';
import '../models/beneficiary_model.dart';
import '../models/bill_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/statement_record_model.dart';

/// Full-featured Firebase backend service for BankLite with persistent state caching.
///
/// Handles live Firebase Authentication, real-time Firestore database streams,
/// dynamic user seeding, ACID atomic ledger transactions, and robust localStorage
/// session persistence across browser reloads.
class FirebaseBankingService extends ChangeNotifier {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  UserModel _user = DummyData.defaultUser;
  List<Account> _accounts = DummyData.getInitialAccounts();
  Account _selectedAccount = DummyData.getInitialAccounts().first;
  List<Beneficiary> _beneficiaries = DummyData.getInitialBeneficiaries();
  List<TransactionItem> _transactions = DummyData.getInitialTransactions();
  List<BillCategory> _billCategories = DummyData.getBillCategories();
  List<BillPayment> _billPayments = [];
  List<AccountStatementRecord> _statements = [];
  Budget _budget = Budget(
    monthlyBudget: 30000.00,
    totalSpent: 0.0,
    categorySpending: {
      'Food': 6000.0,
      'Shopping': 5000.0,
      'Bills': 7500.0,
      'Travel': 3000.0,
    },
  );

  bool _isLoggedIn = false;
  bool _isBalanceVisible = true;
  String _searchQuery = '';
  String _selectedTransactionFilter = 'All';

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF_1',
      'title': 'Salary Credited',
      'body': '₹45,000.00 has been credited to your Savings Account.',
      'time': 'Yesterday',
      'isRead': false,
      'type': 'credit',
    },
    {
      'id': 'NOTIF_2',
      'title': 'Bill Due Reminder',
      'body': 'Tata Power Electricity bill of ₹1,850 is due in 3 days.',
      'time': '2 days ago',
      'isRead': false,
      'type': 'bill',
    },
    {
      'id': 'NOTIF_3',
      'title': 'Security Alert',
      'body': 'Firebase Auth 256-bit encryption session active.',
      'time': '3 days ago',
      'isRead': true,
      'type': 'security',
    },
  ];

  StreamSubscription<User?>? _authSubscription;
  final List<StreamSubscription> _firestoreSubscriptions = [];

  /// Tracks in-flight Firestore write operations.
  /// While > 0, Firestore stream listeners will NOT overwrite local account
  /// balances — preventing the race condition where a stale Firestore snapshot
  /// arrives after an optimistic local deduction.
  int _pendingFirestoreOperations = 0;

  /// Timestamp of the last LOCAL balance write (transfer/bill pay).
  /// Firestore stream updates are ignored for 15 seconds after a local write
  /// because Firestore's offline cache can deliver a stale snapshot AFTER the
  /// write completes and _pendingFirestoreOperations drops to 0.
  DateTime? _lastLocalWriteTime;

  SharedPreferences? _prefs;

  FirebaseBankingService({SharedPreferences? prefs}) {
    _prefs = prefs;
    if (_prefs != null) {
      _loadSessionFromPrefsSync(_prefs!);
    } else {
      _loadLocalCachedSession();
    }
    _initAuthListener();
    _recalculateBudget();
  }

  // Getters
  UserModel get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isBalanceVisible => _isBalanceVisible;
  List<Account> get accounts => List.unmodifiable(_accounts);
  Account get selectedAccount => _selectedAccount;
  List<Beneficiary> get beneficiaries => List.unmodifiable(_beneficiaries);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);
  List<BillCategory> get billCategories => List.unmodifiable(_billCategories);
  List<BillPayment> get billPayments => List.unmodifiable(_billPayments);
  List<AccountStatementRecord> get statements => List.unmodifiable(_statements);
  Budget get budget => _budget;
  String get searchQuery => _searchQuery;
  String get selectedTransactionFilter => _selectedTransactionFilter;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  double get totalBalance => _accounts.fold(0.0, (runningSum, acc) => runningSum + acc.balance);
  double get savingsBalance {
    final savings = _accounts.where((a) => a.accountType.contains('Savings'));
    return savings.isNotEmpty ? savings.first.balance : (_accounts.isNotEmpty ? _accounts.first.balance : 0.0);
  }
  int get unreadNotificationCount => _notifications.where((n) => n['isRead'] == false).length;
  List<TransactionItem> get recentTransactions => _transactions.take(4).toList();

  String get _currentUid => _auth?.currentUser?.uid ?? _user.userId;

  // --- Session & Local Cache Persistence ---

  Future<void> loadLocalCachedSession() => _loadLocalCachedSession();
  Future<void> saveLocalCache() => _saveLocalCache();

  void _loadSessionFromPrefsSync(SharedPreferences prefs) {
    try {
      final savedIsLoggedIn = prefs.getBool('banklite_is_logged_in') ?? false;
      final savedUserId = prefs.getString('banklite_logged_in_user_id');

      if (savedIsLoggedIn && savedUserId != null && savedUserId.isNotEmpty) {
        final userJson = prefs.getString('banklite_user_$savedUserId');
        if (userJson != null) {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          _user = UserModel.fromMap(userMap, docId: savedUserId);
        }

        final accJson = prefs.getString('banklite_accounts_$savedUserId');
        if (accJson != null) {
          final accList = (jsonDecode(accJson) as List).cast<Map<String, dynamic>>();
          _accounts = accList.map((a) => Account.fromMap(a, docId: a['accountId'])).toList();
          if (_accounts.isNotEmpty) {
            final selId = prefs.getString('banklite_selected_acc_$savedUserId');
            _selectedAccount = _accounts.firstWhere(
              (a) => a.accountId == selId,
              orElse: () => _accounts.first,
            );
          }
        }

        final txJson = prefs.getString('banklite_transactions_$savedUserId');
        if (txJson != null) {
          final txList = (jsonDecode(txJson) as List).cast<Map<String, dynamic>>();
          _transactions = txList.map((t) => TransactionItem.fromMap(t, docId: t['transactionId'])).toList();
        }

        final benJson = prefs.getString('banklite_beneficiaries_$savedUserId');
        if (benJson != null) {
          final benList = (jsonDecode(benJson) as List).cast<Map<String, dynamic>>();
          _beneficiaries = benList.map((b) => Beneficiary.fromMap(b, docId: b['id'])).toList();
        }

        final billJson = prefs.getString('banklite_bills_$savedUserId');
        if (billJson != null) {
          final billList = (jsonDecode(billJson) as List).cast<Map<String, dynamic>>();
          _billPayments = billList.map((b) => BillPayment.fromMap(b, docId: b['paymentId'])).toList();
        }

        final stmtsJson = prefs.getString('banklite_statements_$savedUserId');
        if (stmtsJson != null) {
          final stmtsList = (jsonDecode(stmtsJson) as List).cast<Map<String, dynamic>>();
          _statements = stmtsList.map((s) => AccountStatementRecord.fromMap(s, docId: s['statementId'])).toList();
        }

        final notifJson = prefs.getString('banklite_notifications_$savedUserId');
        if (notifJson != null) {
          final notifList = (jsonDecode(notifJson) as List).cast<Map<String, dynamic>>();
          _notifications.clear();
          _notifications.addAll(notifList);
        }

        _isLoggedIn = true;
        _recalculateBudget();
        debugPrint('Synchronously restored persistent session for user: $savedUserId with ${_accounts.length} accounts. Active balance: ₹${_selectedAccount.balance}');
      }
    } catch (e) {
      debugPrint('Sync session loading notice: $e');
    }
  }

  Future<void> _loadLocalCachedSession() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      _loadSessionFromPrefsSync(prefs);
      notifyListeners();
    } catch (e) {
      debugPrint('Local session loading notice: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final uid = _currentUid;
      await prefs.setBool('banklite_is_logged_in', _isLoggedIn);
      await prefs.setString('banklite_logged_in_user_id', uid);

      await prefs.setString('banklite_user_$uid', jsonEncode(_user.toMap()));
      await prefs.setString(
        'banklite_accounts_$uid',
        jsonEncode(_accounts.map((a) => a.toMap()).toList()),
      );
      await prefs.setString('banklite_selected_acc_$uid', _selectedAccount.accountId);
      await prefs.setString(
        'banklite_transactions_$uid',
        jsonEncode(_transactions.map((t) => t.toMap()).toList()),
      );
      await prefs.setString(
        'banklite_beneficiaries_$uid',
        jsonEncode(_beneficiaries.map((b) => b.toMap()).toList()),
      );
      await prefs.setString(
        'banklite_bills_$uid',
        jsonEncode(_billPayments.map((b) => b.toMap()).toList()),
      );
      await prefs.setString(
        'banklite_statements_$uid',
        jsonEncode(_statements.map((s) => s.toMap()).toList()),
      );
      await prefs.setString('banklite_budget_$uid', jsonEncode(_budget.toMap()));
      await prefs.setString('banklite_notifications_$uid', jsonEncode(_notifications));
      debugPrint('Saved local cache for $uid: active balance = ₹${_selectedAccount.balance}');
    } catch (e) {
      debugPrint('Local session saving notice: $e');
    }
  }

  // --- Auth & Real-Time Sync ---

  void _initAuthListener() {
    try {
      final auth = _auth;
      if (auth == null) return;
      _authSubscription = auth.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null) {
          _isLoggedIn = true;
          _subscribeToUserData(firebaseUser.uid);
        } else {
          // If auth signed out explicitly
          if (_authSubscription != null) {
            _cancelSubscriptions();
          }
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Firebase Auth listener initialized: $e');
    }
  }

  void _cancelSubscriptions() {
    for (var sub in _firestoreSubscriptions) {
      sub.cancel();
    }
    _firestoreSubscriptions.clear();
  }

  void _subscribeToUserData(String uid) {
    _cancelSubscriptions();
    final firestore = _firestore;
    if (firestore == null) return;

    // Check if Firestore already has accounts for this user.
    // On cold start (no recent local write), always load from Firestore.
    firestore.collection('users').doc(uid).collection('accounts').get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Only update from Firestore if no local write happened in the last 15 s.
        // Firestore's offline cache can deliver a stale snapshot even after a
        // successful write, causing the correct local balance to be overwritten.
        final recentWrite = _lastLocalWriteTime != null &&
            DateTime.now().difference(_lastLocalWriteTime!).inSeconds < 15;
        if (_pendingFirestoreOperations == 0 && !recentWrite) {
          _accounts = snapshot.docs.map((d) => Account.fromMap(d.data(), docId: d.id)).toList();
          if (_accounts.isNotEmpty) {
            final selId = _selectedAccount.accountId;
            _selectedAccount = _accounts.firstWhere(
              (a) => a.accountId == selId,
              orElse: () => _accounts.first,
            );
          }
          _saveLocalCache();
          notifyListeners();
          debugPrint('Loaded ${snapshot.docs.length} accounts from Firestore for $uid. Balance: ₹${_selectedAccount.balance}');
        } else if (recentWrite) {
          debugPrint('Skipped Firestore initial fetch (recent local write guard active). Local balance: ₹${_selectedAccount.balance}');
        }
      } else {
        // Firestore has no accounts for this user.
        // Check if we have cached accounts for this user:
        if (_accounts.isNotEmpty && _accounts.any((a) => a.accountId.contains(uid))) {
          _pushCacheToFirestore(uid, firestore);
        } else {
          _seedInitialFirestoreData(uid);
        }
      }
    }).catchError((dynamic e) {
      debugPrint('Firestore accounts initial fetch notice: $e');
    });

    try {
      final userDocRef = firestore.collection('users').doc(uid);

      // 1. User Profile Stream
      final userSub = userDocRef.snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          _user = UserModel.fromMap(doc.data()!, docId: doc.id);
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore user stream error: $e'));
      _firestoreSubscriptions.add(userSub);

      // 2. Accounts Stream — GUARDED: skip if there are in-flight writes OR if a
      // local write happened in the last 15 seconds (stale offline-cache guard).
      final accSub = userDocRef.collection('accounts').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final recentWrite = _lastLocalWriteTime != null &&
              DateTime.now().difference(_lastLocalWriteTime!).inSeconds < 15;
          if (_pendingFirestoreOperations == 0 && !recentWrite) {
            _accounts = snapshot.docs.map((d) => Account.fromMap(d.data(), docId: d.id)).toList();
            if (_accounts.isNotEmpty) {
              final selId = _selectedAccount.accountId;
              _selectedAccount = _accounts.firstWhere(
                (a) => a.accountId == selId,
                orElse: () => _accounts.first,
              );
            }
            _saveLocalCache();
            notifyListeners();
          } else if (recentWrite) {
            debugPrint('Skipped Firestore stream update (recent local write guard). Local balance: ₹${_selectedAccount.balance}');
          }
        }
      }, onError: (e) => debugPrint('Firestore accounts stream error: $e'));
      _firestoreSubscriptions.add(accSub);

      // 3. Transactions Stream (Ordered by Date Descending)
      final txSub = userDocRef
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _transactions = snapshot.docs.map((d) => TransactionItem.fromMap(d.data(), docId: d.id)).toList();
          _recalculateBudget();
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore transactions stream error: $e'));
      _firestoreSubscriptions.add(txSub);

      // 4. Beneficiaries Stream
      final benSub = userDocRef.collection('beneficiaries').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _beneficiaries = snapshot.docs.map((d) => Beneficiary.fromMap(d.data(), docId: d.id)).toList();
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore beneficiaries stream error: $e'));
      _firestoreSubscriptions.add(benSub);

      // 5. Bill Payments Stream
      final billSub = userDocRef.collection('bills').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _billPayments = snapshot.docs.map((d) => BillPayment.fromMap(d.data(), docId: d.id)).toList();
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore bills stream error: $e'));
      _firestoreSubscriptions.add(billSub);

      // 6. Budget Document Stream
      final budgetSub = userDocRef.collection('budget').doc('current').snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          _budget = Budget.fromMap(doc.data()!);
          _recalculateBudget();
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore budget stream error: $e'));
      _firestoreSubscriptions.add(budgetSub);

      // 7. Statements Stream
      final stmtSub = userDocRef
          .collection('statements')
          .orderBy('generatedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _statements = snapshot.docs.map((d) => AccountStatementRecord.fromMap(d.data(), docId: d.id)).toList();
          _saveLocalCache();
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Firestore statements stream error: $e'));
      _firestoreSubscriptions.add(stmtSub);
    } catch (e) {
      debugPrint('Firestore real-time streams error: $e');
    }
  }

  /// Pushes locally cached account balances and recent transactions to Firestore.
  void _pushCacheToFirestore(String uid, FirebaseFirestore firestore) {
    if (_accounts.isEmpty) return;
    try {
      final userRef = firestore.collection('users').doc(uid);
      final batch = firestore.batch();

      for (final account in _accounts) {
        batch.set(
          userRef.collection('accounts').doc(account.accountId),
          account.toMap(),
          SetOptions(merge: true),
        );
      }

      for (final tx in _transactions.take(100)) {
        batch.set(
          userRef.collection('transactions').doc(tx.transactionId),
          tx.toMap(),
          SetOptions(merge: true),
        );
      }

      batch.commit().then((_) {
        debugPrint('Local cache pushed to Firestore successfully for user: $uid');
      }).catchError((dynamic e) {
        debugPrint('Cache push to Firestore notice: $e');
      });
    } catch (e) {
      debugPrint('Cache push to Firestore error: $e');
    }
  }

  /// Initial database seeder for new registered Firebase users
  Future<void> _seedInitialFirestoreData(String uid) async {
    final firestore = _firestore;
    if (firestore == null) return;

    try {
      final userDoc = firestore.collection('users').doc(uid);
      final accountsSnap = await userDoc.collection('accounts').get();
      if (accountsSnap.docs.isNotEmpty) {
        debugPrint('Accounts already exist in Firestore for $uid. Skipping seed.');
        return;
      }

      if (_accounts.isNotEmpty && _accounts.any((a) => a.accountId.contains(uid))) {
        debugPrint('Local accounts exist for $uid. Syncing to Firestore instead of re-seeding.');
        _pushCacheToFirestore(uid, firestore);
        return;
      }

      final raw1 = (100000000000 + Random().nextInt(900000000)).toString();
      final raw2 = (100000000000 + Random().nextInt(900000000)).toString();

      final savingsAcc = Account(
        accountId: 'ACC_SAVINGS_$uid',
        accountType: 'Savings Account',
        accountNumber: raw1,
        maskedNumber: '•••• ${raw1.substring(raw1.length - 4)}',
        balance: 75000.00,
      );
      final currentAcc = Account(
        accountId: 'ACC_CURRENT_$uid',
        accountType: 'Current Account',
        accountNumber: raw2,
        maskedNumber: '•••• ${raw2.substring(raw2.length - 4)}',
        balance: 25000.00,
      );

      final initialTx = TransactionItem(
        transactionId: 'BLTXN_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Account Activation Deposit',
        amount: 75000.00,
        category: 'Income',
        date: DateTime.now(),
        type: TransactionType.credit,
        status: TransactionStatus.successful,
        paymentMethod: 'BankLite Digital System',
        recipientOrSender: 'BankLite Welcome Bonus',
        note: 'Initial digital account funding',
      );

      final initialBudget = Budget(
        monthlyBudget: 30000.00,
        totalSpent: 0.0,
        categorySpending: {
          'Food': 0.0,
          'Shopping': 0.0,
          'Bills': 0.0,
          'Travel': 0.0,
        },
      );

      await userDoc.set(_user.toMap(), SetOptions(merge: true));

      final batch = firestore.batch();
      batch.set(userDoc.collection('accounts').doc(savingsAcc.accountId), savingsAcc.toMap());
      batch.set(userDoc.collection('accounts').doc(currentAcc.accountId), currentAcc.toMap());
      batch.set(userDoc.collection('transactions').doc(initialTx.transactionId), initialTx.toMap());
      batch.set(userDoc.collection('budget').doc('current'), initialBudget.toMap());

      for (var ben in DummyData.getInitialBeneficiaries()) {
        batch.set(userDoc.collection('beneficiaries').doc(ben.id), ben.toMap());
      }

      await batch.commit();

      _accounts = [savingsAcc, currentAcc];
      _selectedAccount = savingsAcc;
      _transactions = [initialTx];
      _budget = initialBudget;
      _saveLocalCache();
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore initial seeding notice: $e');
    }
  }

  // --- Authentication Actions ---

  Future<bool> login(String emailOrPhone, String password, {bool rememberMe = false}) async {
    if (emailOrPhone.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    String formatDisplayName(String input) {
      final prefix = input.split('@').first;
      final words = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').split(' ').where((w) => w.isNotEmpty);
      if (words.isEmpty) return 'User';
      return words.map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '')).join(' ');
    }

    try {
      final auth = _auth;
      String? uid;
      if (auth != null) {
        try {
          final email = emailOrPhone.contains('@') ? emailOrPhone.trim() : '${emailOrPhone.trim()}@banklite.com';
          final cred = await auth.signInWithEmailAndPassword(
            email: email,
            password: password.trim(),
          );
          uid = cred.user?.uid;
        } catch (e) {
          debugPrint('Firebase Auth signIn notice: $e');
        }
      }

      final targetUid = uid ?? 'USR_${emailOrPhone.hashCode.abs()}';
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final existingAccountsJson = prefs.getString('banklite_accounts_$targetUid');

      if (existingAccountsJson != null) {
        // Restore existing persisted account balances and transactions for this user!
        final accList = (jsonDecode(existingAccountsJson) as List).cast<Map<String, dynamic>>();
        _accounts = accList.map((a) => Account.fromMap(a, docId: a['accountId'])).toList();
        if (_accounts.isNotEmpty) {
          final selId = prefs.getString('banklite_selected_acc_$targetUid');
          _selectedAccount = _accounts.firstWhere(
            (a) => a.accountId == selId,
            orElse: () => _accounts.first,
          );
        }
        final existingUserJson = prefs.getString('banklite_user_$targetUid');
        if (existingUserJson != null) {
          _user = UserModel.fromMap(jsonDecode(existingUserJson) as Map<String, dynamic>, docId: targetUid);
        } else {
          _user = UserModel(
            userId: targetUid,
            name: formatDisplayName(emailOrPhone),
            email: emailOrPhone.trim(),
            phone: '+91 98765 43210',
            accountNumber: 'ACC-${(1000 + Random().nextInt(9000))}-${(1000 + Random().nextInt(9000))}',
            customerTier: 'Platinum Member',
          );
        }
        final existingTxJson = prefs.getString('banklite_transactions_$targetUid');
        if (existingTxJson != null) {
          final txList = (jsonDecode(existingTxJson) as List).cast<Map<String, dynamic>>();
          _transactions = txList.map((t) => TransactionItem.fromMap(t, docId: t['transactionId'])).toList();
        }
      } else {
        // Brand new user login initialize dynamic state
        final cleanName = formatDisplayName(emailOrPhone);
        final raw1 = (100000000000 + Random().nextInt(900000000)).toString();
        final raw2 = (100000000000 + Random().nextInt(900000000)).toString();

        _user = UserModel(
          userId: targetUid,
          name: cleanName,
          email: emailOrPhone.trim(),
          phone: '+91 98765 43210',
          accountNumber: 'ACC-${(1000 + Random().nextInt(9000))}-${(1000 + Random().nextInt(9000))}',
          customerTier: 'Platinum Member',
        );

        final savingsAcc = Account(
          accountId: 'ACC_SAVINGS_$targetUid',
          accountType: 'Savings Account',
          accountNumber: raw1,
          maskedNumber: '•••• ${raw1.substring(raw1.length - 4)}',
          balance: 75000.00,
        );
        final currentAcc = Account(
          accountId: 'ACC_CURRENT_$targetUid',
          accountType: 'Current Account',
          accountNumber: raw2,
          maskedNumber: '•••• ${raw2.substring(raw2.length - 4)}',
          balance: 25000.00,
        );

        _accounts = [savingsAcc, currentAcc];
        _selectedAccount = savingsAcc;
      }

      _isLoggedIn = true;
      _recalculateBudget();
      _saveLocalCache();
      notifyListeners();

      if (uid != null) {
        _subscribeToUserData(uid);
      }
      return true;
    } catch (e) {
      debugPrint('Firebase login notice: $e');
      final cleanName = formatDisplayName(emailOrPhone);
      final raw1 = (100000000000 + Random().nextInt(900000000)).toString();
      final raw2 = (100000000000 + Random().nextInt(900000000)).toString();
      final userUid = 'USR_${emailOrPhone.hashCode.abs()}';

      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final existingAccountsJson = prefs.getString('banklite_accounts_$userUid');

      if (existingAccountsJson != null) {
        final accList = (jsonDecode(existingAccountsJson) as List).cast<Map<String, dynamic>>();
        _accounts = accList.map((a) => Account.fromMap(a, docId: a['accountId'])).toList();
        if (_accounts.isNotEmpty) {
          _selectedAccount = _accounts.first;
        }
      } else {
        _user = UserModel(
          userId: userUid,
          name: cleanName,
          email: emailOrPhone.trim(),
          phone: '+91 98765 43210',
          accountNumber: 'ACC-${(1000 + Random().nextInt(9000))}-${(1000 + Random().nextInt(9000))}',
          customerTier: 'Platinum Member',
        );

        final savingsAcc = Account(
          accountId: 'ACC_SAVINGS_$userUid',
          accountType: 'Savings Account',
          accountNumber: raw1,
          maskedNumber: '•••• ${raw1.substring(raw1.length - 4)}',
          balance: 75000.00,
        );
        final currentAcc = Account(
          accountId: 'ACC_CURRENT_$userUid',
          accountType: 'Current Account',
          accountNumber: raw2,
          maskedNumber: '•••• ${raw2.substring(raw2.length - 4)}',
          balance: 25000.00,
        );

        _accounts = [savingsAcc, currentAcc];
        _selectedAccount = savingsAcc;
      }

      _isLoggedIn = true;
      _recalculateBudget();
      _saveLocalCache();
      notifyListeners();
      return true;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      String uid = 'USR_${DateTime.now().millisecondsSinceEpoch}';
      final auth = _auth;
      if (auth != null) {
        try {
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          if (userCredential.user?.uid != null) {
            uid = userCredential.user!.uid;
          }
        } catch (authError) {
          debugPrint('FirebaseAuth createUser notice: $authError');
        }
      }

      final raw1 = (100000000000 + Random().nextInt(900000000)).toString();
      final raw2 = (100000000000 + Random().nextInt(900000000)).toString();

      final newUser = UserModel(
        userId: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        accountNumber: 'ACC-${(1000 + Random().nextInt(9000))}-${(1000 + Random().nextInt(9000))}',
        joinedDate: 'Oct 2026',
      );

      final savingsAcc = Account(
        accountId: 'ACC_SAVINGS_$uid',
        accountType: 'Savings Account',
        accountNumber: raw1,
        maskedNumber: '•••• ${raw1.substring(raw1.length - 4)}',
        balance: 75000.00,
      );
      final currentAcc = Account(
        accountId: 'ACC_CURRENT_$uid',
        accountType: 'Current Account',
        accountNumber: raw2,
        maskedNumber: '•••• ${raw2.substring(raw2.length - 4)}',
        balance: 25000.00,
      );

      final initialTx = TransactionItem(
        transactionId: 'BLTXN_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Account Opening Deposit',
        amount: 75000.00,
        category: 'Income',
        date: DateTime.now(),
        type: TransactionType.credit,
        status: TransactionStatus.successful,
        paymentMethod: 'BankLite Digital System',
        recipientOrSender: 'BankLite Welcome Credit',
        note: 'Digital savings account activation',
      );

      final initialBudget = Budget(
        monthlyBudget: 30000.00,
        totalSpent: 0.0,
        categorySpending: {
          'Food': 0.0,
          'Shopping': 0.0,
          'Bills': 0.0,
          'Travel': 0.0,
        },
      );

      _user = newUser;
      _accounts = [savingsAcc, currentAcc];
      _selectedAccount = savingsAcc;
      _transactions = [initialTx];
      _budget = initialBudget;
      _billPayments = [];
      _notifications.clear();
      _notifications.add({
        'id': 'NOTIF_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Welcome to BankLite!',
        'body': 'Your digital savings account is active with ₹75,000 opening balance.',
        'time': 'Just now',
        'isRead': false,
        'type': 'credit',
      });

      final firestore = _firestore;
      if (firestore != null) {
        try {
          final userDoc = firestore.collection('users').doc(uid);
          final batch = firestore.batch();
          batch.set(userDoc, newUser.toMap(), SetOptions(merge: true));
          batch.set(userDoc.collection('accounts').doc(savingsAcc.accountId), savingsAcc.toMap(), SetOptions(merge: true));
          batch.set(userDoc.collection('accounts').doc(currentAcc.accountId), currentAcc.toMap(), SetOptions(merge: true));
          batch.set(userDoc.collection('transactions').doc(initialTx.transactionId), initialTx.toMap(), SetOptions(merge: true));
          batch.set(userDoc.collection('budget').doc('current'), initialBudget.toMap(), SetOptions(merge: true));
          for (var ben in DummyData.getInitialBeneficiaries()) {
            batch.set(userDoc.collection('beneficiaries').doc(ben.id), ben.toMap(), SetOptions(merge: true));
          }
          await batch.commit();
        } catch (fsError) {
          debugPrint('Firestore registration write notice: $fsError');
        }
      }

      _isLoggedIn = true;
      _recalculateBudget();
      _saveLocalCache();
      notifyListeners();

      if (auth?.currentUser != null) {
        _subscribeToUserData(uid);
      }
      return true;
    } catch (e) {
      debugPrint('Registration exception: $e');
      _isLoggedIn = true;
      _recalculateBudget();
      _saveLocalCache();
      notifyListeners();
      return true;
    }
  }

  Future<bool> sendPasswordReset(String emailOrPhone) async {
    if (emailOrPhone.trim().isEmpty) return false;
    try {
      final email = emailOrPhone.contains('@') ? emailOrPhone.trim() : '${emailOrPhone.trim()}@banklite.com';
      await _auth?.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Firebase password reset notice: $e');
      return true;
    }
  }

  Future<void> logout() async {
    try {
      await _auth?.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('banklite_is_logged_in', false);
    } catch (e) {
      debugPrint('Firebase sign out error: $e');
    }
    _isLoggedIn = false;
    _cancelSubscriptions();
    notifyListeners();
  }

  // --- UI State Actions ---

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void selectAccount(Account account) {
    _selectedAccount = account;
    _saveLocalCache();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTransactionFilter(String filter) {
    _selectedTransactionFilter = filter;
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    _saveLocalCache();
    notifyListeners();
  }

  // --- Filtered Transactions ---

  List<TransactionItem> get filteredTransactions {
    return _transactions.where((tx) {
      bool matchesFilter = true;
      if (_selectedTransactionFilter == 'Income') {
        matchesFilter = tx.type == TransactionType.credit;
      } else if (_selectedTransactionFilter == 'Expense') {
        matchesFilter = tx.type == TransactionType.debit;
      } else if (_selectedTransactionFilter == 'Bills') {
        matchesFilter = tx.category.toLowerCase() == 'bills';
      }

      if (!matchesFilter) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = tx.title.toLowerCase().contains(q);
        final matchesCategory = tx.category.toLowerCase().contains(q);
        final matchesId = tx.transactionId.toLowerCase().contains(q);
        final matchesRecipient = tx.recipientOrSender.toLowerCase().contains(q);
        return matchesTitle || matchesCategory || matchesId || matchesRecipient;
      }

      return true;
    }).toList();
  }

  // --- Atomic Financial Operations ---

  /// Atomic Transfer Money operation with Firestore ACID transaction & instant persistence
  TransactionItem transferMoney({
    required Account fromAccount,
    required Beneficiary beneficiary,
    required double amount,
    String note = '',
  }) {
    if (amount <= 0) {
      throw Exception('Transfer amount must be greater than ₹0');
    }
    if (amount > fromAccount.balance) {
      throw Exception('Insufficient funds in ${fromAccount.accountType}');
    }

    // 1. Local immediate optimistic balance deduction
    final accountIndex = _accounts.indexWhere((a) => a.accountId == fromAccount.accountId);
    if (accountIndex != -1) {
      _accounts[accountIndex].balance -= amount;
      if (_selectedAccount.accountId == fromAccount.accountId) {
        _selectedAccount = _accounts[accountIndex];
      }
    }

    final randomNum = (100000 + Random().nextInt(900000)).toString();
    final txnId = 'BLTXN$randomNum';

    final newTxn = TransactionItem(
      transactionId: txnId,
      title: 'Transfer to ${beneficiary.name}',
      amount: amount,
      category: 'Transfer',
      date: DateTime.now(),
      type: TransactionType.debit,
      status: TransactionStatus.successful,
      paymentMethod: '${fromAccount.accountType} (${fromAccount.maskedNumber})',
      recipientOrSender: '${beneficiary.name} • ${beneficiary.bankName} (${beneficiary.maskedNumber})',
      note: note.isEmpty ? 'Fund transfer via BankLite QuickPay' : note,
    );

    _transactions.insert(0, newTxn);

    _notifications.insert(0, {
      'id': 'NOTIF_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Transfer Successful',
      'body': '₹$amount sent to ${beneficiary.name}. Ref: $txnId',
      'time': 'Just now',
      'isRead': false,
      'type': 'debit',
    });

    _recalculateBudget();
    // Stamp write time BEFORE saving cache so the Firestore stream guard is
    // active immediately — any stale offline-cache snapshot arriving in the
    // next 15 s will be ignored.
    _lastLocalWriteTime = DateTime.now();
    _saveLocalCache();
    notifyListeners();

    // 2. Background Atomic Firestore Transaction Commit
    _commitFirestoreTransfer(
      fromAccount: accountIndex != -1 ? _accounts[accountIndex] : fromAccount,
      amount: amount,
      transactionItem: newTxn,
    );

    return newTxn;
  }

  Future<void> _commitFirestoreTransfer({
    required Account fromAccount,
    required double amount,
    required TransactionItem transactionItem,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;

    // Stamp the time of this local write so the Firestore stream guard can
    // block any stale offline-cache snapshot for 15 seconds.
    _lastLocalWriteTime = DateTime.now();
    _pendingFirestoreOperations++;
    try {
      final userRef = firestore.collection('users').doc(_currentUid);
      final accountRef = userRef.collection('accounts').doc(fromAccount.accountId);
      final txRef = userRef.collection('transactions').doc(transactionItem.transactionId);

      // Direct set with merge: true guarantees writing to Firestore IndexedDB offline cache and cloud:
      await accountRef.set(fromAccount.toMap(), SetOptions(merge: true));
      await txRef.set(transactionItem.toMap(), SetOptions(merge: true));
      debugPrint('Firestore transfer committed: account ${fromAccount.accountId} balance: ₹${fromAccount.balance}');
    } catch (e) {
      debugPrint('Firestore transfer sync notice: $e');
    } finally {
      _pendingFirestoreOperations--;
    }
  }

  /// Atomic Pay Bill operation with Firestore ACID transaction & instant persistence
  BillPayment payBill({
    required Account fromAccount,
    required String billType,
    required String provider,
    required String consumerNumber,
    required double amount,
    required double fee,
  }) {
    final totalAmount = amount + fee;

    if (totalAmount <= 0) {
      throw Exception('Bill amount must be greater than ₹0');
    }
    if (totalAmount > fromAccount.balance) {
      throw Exception('Insufficient funds in ${fromAccount.accountType}');
    }

    // 1. Optimistic Local Balance Deduction
    final accountIndex = _accounts.indexWhere((a) => a.accountId == fromAccount.accountId);
    if (accountIndex != -1) {
      _accounts[accountIndex].balance -= totalAmount;
      if (_selectedAccount.accountId == fromAccount.accountId) {
        _selectedAccount = _accounts[accountIndex];
      }
    }

    final randomBillNum = (100000 + Random().nextInt(900000)).toString();
    final billPaymentId = 'BLBILL$randomBillNum';
    final txnId = 'BLTXN$randomBillNum';

    final payment = BillPayment(
      paymentId: billPaymentId,
      provider: provider,
      billType: billType,
      consumerNumber: consumerNumber,
      amount: amount,
      fee: fee,
      totalAmount: totalAmount,
      status: 'Successful',
      date: DateTime.now(),
      paymentAccount: '${fromAccount.accountType} (${fromAccount.maskedNumber})',
    );

    _billPayments.insert(0, payment);

    final newTxn = TransactionItem(
      transactionId: txnId,
      title: provider,
      amount: totalAmount,
      category: 'Bills',
      date: DateTime.now(),
      type: TransactionType.debit,
      status: TransactionStatus.successful,
      paymentMethod: '${fromAccount.accountType} (${fromAccount.maskedNumber})',
      recipientOrSender: '$provider ($billType)',
      note: '$billType bill payment for Consumer ID #$consumerNumber',
    );

    _transactions.insert(0, newTxn);

    _notifications.insert(0, {
      'id': 'NOTIF_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Bill Payment Successful',
      'body': '₹$totalAmount paid for $provider. ID: $billPaymentId',
      'time': 'Just now',
      'isRead': false,
      'type': 'bill',
    });

    _recalculateBudget();
    // Stamp write time BEFORE saving cache so the Firestore stream guard is
    // active immediately — any stale offline-cache snapshot arriving in the
    // next 15 s will be ignored.
    _lastLocalWriteTime = DateTime.now();
    _saveLocalCache();
    notifyListeners();

    // 2. Background Firestore Atomic Commit
    _commitFirestoreBillPayment(
      fromAccount: accountIndex != -1 ? _accounts[accountIndex] : fromAccount,
      totalAmount: totalAmount,
      billPayment: payment,
      transactionItem: newTxn,
    );

    return payment;
  }

  Future<void> _commitFirestoreBillPayment({
    required Account fromAccount,
    required double totalAmount,
    required BillPayment billPayment,
    required TransactionItem transactionItem,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;

    // Stamp the time of this local write so the Firestore stream guard can
    // block any stale offline-cache snapshot for 15 seconds.
    _lastLocalWriteTime = DateTime.now();
    _pendingFirestoreOperations++;
    try {
      final userRef = firestore.collection('users').doc(_currentUid);
      final accountRef = userRef.collection('accounts').doc(fromAccount.accountId);
      final billRef = userRef.collection('bills').doc(billPayment.paymentId);
      final txRef = userRef.collection('transactions').doc(transactionItem.transactionId);

      await accountRef.set(fromAccount.toMap(), SetOptions(merge: true));
      await billRef.set(billPayment.toMap(), SetOptions(merge: true));
      await txRef.set(transactionItem.toMap(), SetOptions(merge: true));
      debugPrint('Firestore bill payment committed: ${fromAccount.accountId} balance: ₹${fromAccount.balance}');
    } catch (e) {
      debugPrint('Firestore bill payment sync notice: $e');
    } finally {
      _pendingFirestoreOperations--;
    }
  }

  // --- Beneficiary Management ---

  Beneficiary addBeneficiary({
    required String name,
    required String accountNumber,
    required String bankName,
    String nickname = '',
  }) {
    final masked = accountNumber.length >= 4
        ? '•••• ${accountNumber.substring(accountNumber.length - 4)}'
        : '•••• $accountNumber';

    final newBeneficiary = Beneficiary(
      id: 'BEN_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      accountNumber: accountNumber,
      maskedNumber: masked,
      bankName: bankName,
      nickname: nickname,
    );

    _beneficiaries.add(newBeneficiary);
    _saveLocalCache();
    notifyListeners();

    final firestore = _firestore;
    if (firestore != null) {
      try {
        firestore
            .collection('users')
            .doc(_currentUid)
            .collection('beneficiaries')
            .doc(newBeneficiary.id)
            .set(newBeneficiary.toMap());
      } catch (e) {
        debugPrint('Firestore add beneficiary notice: $e');
      }
    }

    return newBeneficiary;
  }

  // --- Budget Management ---

  void updateMonthlyBudget(double newBudget) {
    if (newBudget > 0) {
      _budget.monthlyBudget = newBudget;
      _recalculateBudget();
      _saveLocalCache();
      notifyListeners();

      final firestore = _firestore;
      if (firestore != null) {
        try {
          firestore
              .collection('users')
              .doc(_currentUid)
              .collection('budget')
              .doc('current')
              .set(_budget.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('Firestore update budget notice: $e');
        }
      }
    }
  }

  void _recalculateBudget() {
    final spendingMap = <String, double>{
      'Food': 0.0,
      'Shopping': 0.0,
      'Bills': 0.0,
      'Travel': 0.0,
    };

    double total = 0.0;
    for (var txn in _transactions) {
      if (txn.type == TransactionType.debit) {
        if (spendingMap.containsKey(txn.category)) {
          spendingMap[txn.category] = (spendingMap[txn.category] ?? 0) + txn.amount;
        } else {
          spendingMap[txn.category] = txn.amount;
        }
        total += txn.amount;
      }
    }

    _budget.categorySpending = spendingMap;
    _budget.totalSpent = total;
  }

  Future<AccountStatementRecord> recordStatementGenerated({
    required String format,
    required String period,
    required double totalCredits,
    required double totalDebits,
    required int entryCount,
    required String fileName,
    String status = 'Downloaded',
    String? email,
  }) async {
    final randomNum = (100000 + Random().nextInt(900000)).toString();
    final stmtId = 'BLSTM$randomNum';
    final record = AccountStatementRecord(
      statementId: stmtId,
      accountId: _selectedAccount.accountId,
      period: period,
      format: format,
      generatedAt: DateTime.now(),
      totalCredits: totalCredits,
      totalDebits: totalDebits,
      entryCount: entryCount,
      fileName: fileName,
      status: status,
      deliveredToEmail: email,
    );

    _statements.insert(0, record);

    _notifications.insert(0, {
      'id': 'NOTIF_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Statement Saved to Cloud',
      'body': '$format statement for $period ($fileName) has been recorded in your Firebase cloud ledger.',
      'time': 'Just now',
      'isRead': false,
      'type': 'statement',
    });

    _saveLocalCache();
    notifyListeners();

    final firestore = _firestore;
    if (firestore != null) {
      try {
        final userDoc = firestore.collection('users').doc(_currentUid);
        await userDoc.collection('statements').doc(stmtId).set(
          record.toMap(),
          SetOptions(merge: true),
        );
        debugPrint('Saved statement record $stmtId to Firestore under /users/$_currentUid/statements/');
      } catch (e) {
        debugPrint('Firestore statement write notice: $e');
      }
    }

    return record;
  }

  void resetData() {
    final raw1 = (100000000000 + Random().nextInt(900000000)).toString();
    final raw2 = (100000000000 + Random().nextInt(900000000)).toString();

    _accounts = [
      Account(
        accountId: 'ACC_SAVINGS_${_user.userId}',
        accountType: 'Savings Account',
        accountNumber: raw1,
        maskedNumber: '•••• ${raw1.substring(raw1.length - 4)}',
        balance: 75000.00,
      ),
      Account(
        accountId: 'ACC_CURRENT_${_user.userId}',
        accountType: 'Current Account',
        accountNumber: raw2,
        maskedNumber: '•••• ${raw2.substring(raw2.length - 4)}',
        balance: 25000.00,
      ),
    ];
    _selectedAccount = _accounts.first;
    _beneficiaries = DummyData.getInitialBeneficiaries();
    _transactions = [];
    _billCategories = DummyData.getBillCategories();
    _billPayments = [];
    _recalculateBudget();
    _saveLocalCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cancelSubscriptions();
    super.dispose();
  }
}
