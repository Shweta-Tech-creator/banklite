import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/bills/pay_bills_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'services/banking_provider.dart';
import 'services/banking_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/account_statement_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialization notice: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(BankLiteApp(prefs: prefs));
}

class BankLiteApp extends StatefulWidget {
  final SharedPreferences? prefs;
  const BankLiteApp({super.key, this.prefs});

  @override
  State<BankLiteApp> createState() => _BankLiteAppState();
}

class _BankLiteAppState extends State<BankLiteApp> {
  late final BankingService _bankingService;

  @override
  void initState() {
    super.initState();
    _bankingService = BankingService(prefs: widget.prefs);
  }

  @override
  void dispose() {
    _bankingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BankingProvider(
      service: _bankingService,
      child: MaterialApp(
        title: 'BankLite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/transfer': (context) => const TransferScreen(),
          '/bills': (context) => const PayBillsScreen(),
          '/statement': (context) => const Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(child: AccountStatementSheet()),
              ),
        },
      ),
    );
  }
}
