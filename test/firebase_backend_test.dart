import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_lite/models/account_model.dart';
import 'package:bank_lite/models/beneficiary_model.dart';
import 'package:bank_lite/models/bill_model.dart';
import 'package:bank_lite/models/budget_model.dart';
import 'package:bank_lite/models/transaction_model.dart';
import 'package:bank_lite/models/user_model.dart';
import 'package:bank_lite/services/firebase_banking_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Data Models Firestore Serialization Tests', () {
    test('UserModel serialization to and from Map', () {
      final user = UserModel(
        userId: 'USER_101',
        name: 'Sweta Kadam',
        email: 'sweta.kadam@example.com',
        phone: '+91 98765 43210',
        accountNumber: 'ACC-8821-4920',
        customerTier: 'Platinum Member',
        isKycVerified: true,
        joinedDate: 'Jan 2024',
      );

      final map = user.toMap();
      expect(map['name'], 'Sweta Kadam');
      expect(map['customerTier'], 'Platinum Member');

      final reconstructed = UserModel.fromMap(map, docId: 'USER_101');
      expect(reconstructed.userId, 'USER_101');
      expect(reconstructed.name, user.name);
      expect(reconstructed.email, user.email);
      expect(reconstructed.isKycVerified, isTrue);
    });

    test('Account serialization to and from Map', () {
      final account = Account(
        accountId: 'ACC_001',
        accountType: 'Savings Account',
        accountNumber: '892144024920',
        maskedNumber: '•••• 4920',
        balance: 124850.75,
        bankName: 'BankLite National Bank',
        ifscCode: 'BLTE0001234',
      );

      final map = account.toMap();
      expect(map['balance'], 124850.75);
      expect(map['accountType'], 'Savings Account');

      final reconstructed = Account.fromMap(map, docId: 'ACC_001');
      expect(reconstructed.accountId, 'ACC_001');
      expect(reconstructed.balance, 124850.75);
      expect(reconstructed.bankName, 'BankLite National Bank');
    });

    test('TransactionItem serialization to and from Map', () {
      final now = DateTime.now();
      final txn = TransactionItem(
        transactionId: 'TXN_TEST_1',
        title: 'Starbucks Coffee',
        amount: 340.0,
        category: 'Food',
        date: now,
        type: TransactionType.debit,
        status: TransactionStatus.successful,
        paymentMethod: 'Savings Account (•••• 4920)',
        recipientOrSender: 'Starbucks BKC',
        note: 'Cold brew and snacks',
      );

      final map = txn.toMap();
      expect(map['title'], 'Starbucks Coffee');
      expect(map['type'], 'debit');
      expect(map['status'], 'successful');

      final reconstructed = TransactionItem.fromMap(map, docId: 'TXN_TEST_1');
      expect(reconstructed.transactionId, 'TXN_TEST_1');
      expect(reconstructed.amount, 340.0);
      expect(reconstructed.type, TransactionType.debit);
      expect(reconstructed.status, TransactionStatus.successful);
    });

    test('Beneficiary and BillPayment serialization', () {
      final ben = Beneficiary(
        id: 'BEN_99',
        name: 'Rahul Sharma',
        accountNumber: '9876543210',
        maskedNumber: '•••• 3210',
        bankName: 'HDFC Bank',
        nickname: 'Rahul HDFC',
      );

      final benMap = ben.toMap();
      final benReconstructed = Beneficiary.fromMap(benMap, docId: 'BEN_99');
      expect(benReconstructed.name, 'Rahul Sharma');
      expect(benReconstructed.bankName, 'HDFC Bank');

      final bill = BillPayment(
        paymentId: 'BILL_01',
        provider: 'Tata Power',
        billType: 'Electricity',
        consumerNumber: '99887766',
        amount: 1850.0,
        fee: 20.0,
        totalAmount: 1870.0,
        status: 'Successful',
        date: DateTime.now(),
        paymentAccount: 'Savings Account (•••• 4920)',
      );

      final billMap = bill.toMap();
      final billReconstructed = BillPayment.fromMap(billMap, docId: 'BILL_01');
      expect(billReconstructed.paymentId, 'BILL_01');
      expect(billReconstructed.totalAmount, 1870.0);
    });

    test('Budget serialization and calculation', () {
      final budget = Budget(
        monthlyBudget: 50000.0,
        totalSpent: 21500.0,
        categorySpending: {
          'Food': 6000.0,
          'Shopping': 5000.0,
          'Bills': 7500.0,
          'Travel': 3000.0,
        },
      );

      final map = budget.toMap();
      expect(map['monthlyBudget'], 50000.0);
      final reconstructed = Budget.fromMap(map);
      expect(reconstructed.monthlyBudget, 50000.0);
      expect(reconstructed.remaining, 28500.0);
      expect(reconstructed.percentageUsed, 43.0);
    });
  });

  group('FirebaseBankingService Backend Core Operations Tests', () {
    test('Authentication and Registration flow', () async {
      final service = FirebaseBankingService();
      
      final loginSuccess = await service.login('sweta.kadam@example.com', 'banklite@123');
      expect(loginSuccess, isTrue);
      expect(service.isLoggedIn, isTrue);

      final registerSuccess = await service.register(
        name: 'New User',
        email: 'newuser@banklite.com',
        phone: '9876543210',
        password: 'password123',
      );
      expect(registerSuccess, isTrue);
      expect(service.user.name, 'New User');
      expect(service.user.email, 'newuser@banklite.com');

      await service.logout();
      expect(service.isLoggedIn, isFalse);
    });

    test('Atomic Ledger Fund Transfer updates balance and budget', () {
      final service = FirebaseBankingService();
      final initialBalance = service.selectedAccount.balance;
      final ben = service.beneficiaries.first;

      final txn = service.transferMoney(
        fromAccount: service.selectedAccount,
        beneficiary: ben,
        amount: 2500.0,
        note: 'Rent share',
      );

      expect(txn.amount, 2500.0);
      expect(service.selectedAccount.balance, initialBalance - 2500.0);
      expect(service.notifications.first['title'], 'Transfer Successful');
    });

    test('Search and category filtering filters transactions properly', () {
      final service = FirebaseBankingService();

      service.setTransactionFilter('Income');
      for (var tx in service.filteredTransactions) {
        expect(tx.type, TransactionType.credit);
      }

      service.setTransactionFilter('Expense');
      for (var tx in service.filteredTransactions) {
        expect(tx.type, TransactionType.debit);
      }

      service.setTransactionFilter('All');
      service.setSearchQuery('Salary');
      for (var tx in service.filteredTransactions) {
        expect(tx.title.toLowerCase().contains('salary') || tx.category.toLowerCase().contains('salary'), isTrue);
      }
    });

    test('Add Beneficiary and Update Monthly Budget', () {
      final service = FirebaseBankingService();

      final ben = service.addBeneficiary(
        name: 'Aarav Patel',
        accountNumber: '1122334455',
        bankName: 'ICICI Bank',
        nickname: 'Aarav ICICI',
      );
      expect(service.beneficiaries.any((b) => b.id == ben.id), isTrue);

      service.updateMonthlyBudget(45000.0);
      expect(service.budget.monthlyBudget, 45000.0);
    });

    test('State persistence and balance deduction across browser reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final service1 = FirebaseBankingService();
      await service1.loadLocalCachedSession();
      await service1.login('aniket12@gmail.com', 'pass123');
      expect(service1.selectedAccount.balance, 75000.0);

      // Pay bill or transfer 2000
      final ben = service1.beneficiaries.first;
      service1.transferMoney(
        fromAccount: service1.selectedAccount,
        beneficiary: ben,
        amount: 2000.0,
      );
      expect(service1.selectedAccount.balance, 73000.0);
      await service1.saveLocalCache();

      // Simulate browser refresh by creating a new service instance with pre-loaded prefs (matching main())
      final prefs = await SharedPreferences.getInstance();
      final service2 = FirebaseBankingService(prefs: prefs);
      expect(service2.isLoggedIn, isTrue);
      expect(service2.selectedAccount.balance, 73000.0);
      expect(service2.transactions.first.amount, 2000.0);
    });
  });
}
