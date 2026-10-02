import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_lite/main.dart';
import 'package:bank_lite/services/banking_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('BankLite app launches splash screen and transitions to login', (WidgetTester tester) async {
    await tester.pumpWidget(const BankLiteApp());

    // Verify Splash Screen
    expect(find.text('BankLite'), findsOneWidget);
    expect(find.text('Simple. Secure. Smarter Banking.'), findsOneWidget);

    // Advance past the 2.5s timer
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // Verify Login Screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to Account'), findsOneWidget);
  });

  testWidgets('BankLite Login to Dashboard and Navigation Flow', (WidgetTester tester) async {
    await tester.pumpWidget(const BankLiteApp());
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(find.byType(TextFormField).first, 'sweta.kadam@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'banklite@123');

    // Tap Login Button
    final loginButton = find.text('Login to Account');
    expect(loginButton, findsOneWidget);
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    // Wait for simulated auth delay
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verify Dashboard is loaded
    expect(find.text('Sweta Kadam'), findsAny);
    expect(find.text('Transfer\nMoney'), findsOneWidget);
    expect(find.text('Pay\nBills'), findsOneWidget);

    // Test Tab Navigation to Transactions tab in NavigationBar
    final navBar = find.byType(NavigationBar);
    final transactionsTab = find.descendant(
      of: navBar,
      matching: find.text('Transactions'),
    );
    await tester.tap(transactionsTab);
    await tester.pumpAndSettle();
    expect(find.text('Income'), findsAtLeastNWidgets(1));
    expect(find.text('Expense'), findsAtLeastNWidgets(1));
    expect(find.text('Bills'), findsAtLeastNWidgets(1));

    // Test Tab Navigation to Budget tab in NavigationBar
    final budgetTab = find.descendant(
      of: navBar,
      matching: find.text('Budget'),
    );
    await tester.tap(budgetTab);
    await tester.pumpAndSettle();
    expect(find.text('Budget & Insights'), findsOneWidget);
    expect(find.text('Monthly Spending Budget'), findsOneWidget);

    // Test Tab Navigation to Profile tab in NavigationBar
    final profileTab = find.descendant(
      of: navBar,
      matching: find.text('Profile'),
    );
    await tester.tap(profileTab);
    await tester.pumpAndSettle();
    expect(find.text('Account Profile'), findsOneWidget);
    expect(find.text('Personal Information & KYC'), findsOneWidget);
  });

  test('BankingService local logic unit test for transfer and bill payments', () {
    final service = BankingService();
    final initialBalance = service.selectedAccount.balance;
    final initialTransactionsCount = service.transactions.length;
    final beneficiary = service.beneficiaries.first;

    // 1. Test Fund Transfer
    const transferAmt = 5000.0;
    final txn = service.transferMoney(
      fromAccount: service.selectedAccount,
      beneficiary: beneficiary,
      amount: transferAmt,
      note: 'Test Transfer',
    );

    expect(txn.amount, transferAmt);
    expect(service.selectedAccount.balance, initialBalance - transferAmt);
    expect(service.transactions.length, initialTransactionsCount + 1);
    expect(service.transactions.first.transactionId.startsWith('BLTXN'), true);

    // 2. Test Bill Payment
    const billAmt = 1850.0;
    const fee = 20.0;
    const total = billAmt + fee;
    final balanceBeforeBill = service.selectedAccount.balance;

    final billPayment = service.payBill(
      fromAccount: service.selectedAccount,
      billType: 'Electricity',
      provider: 'Tata Power',
      consumerNumber: '123456789',
      amount: billAmt,
      fee: fee,
    );

    expect(billPayment.totalAmount, total);
    expect(service.selectedAccount.balance, balanceBeforeBill - total);
    expect(service.budget.categorySpending['Bills'], isNotNull);
  });
}
