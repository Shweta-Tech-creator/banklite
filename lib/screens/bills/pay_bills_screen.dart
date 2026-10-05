import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/account_model.dart';
import '../../models/bill_model.dart';
import '../../services/banking_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/responsive_wrapper.dart';
import 'bill_confirm_dialog.dart';
import 'bill_success_screen.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _consumerNumberController = TextEditingController(text: '123456789');
  final _amountController = TextEditingController(text: '1850');

  late BillCategory _selectedCategory;
  String? _selectedProvider;
  Account? _selectedAccount;
  double _fee = 20.0;
  double _total = 1870.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final banking = context.banking;
    _selectedCategory = banking.billCategories.first;
    _selectedProvider ??= _selectedCategory.providers.first;
    _fee = _selectedCategory.defaultFee;
    _selectedAccount ??= banking.selectedAccount;
    _updateTotal();
  }

  @override
  void dispose() {
    _consumerNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onCategorySelected(BillCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedProvider = category.providers.first;
      _fee = category.defaultFee;
      if (category.id == 'electricity') {
        _amountController.text = '1850';
      } else if (category.id == 'mobile') {
        _amountController.text = '699';
      } else if (category.id == 'internet') {
        _amountController.text = '1199';
      } else if (category.id == 'water') {
        _amountController.text = '450';
      } else if (category.id == 'gas') {
        _amountController.text = '850';
      }
      _updateTotal();
    });
  }

  void _updateTotal() {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    setState(() {
      _total = amt + _fee;
    });
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case 'electricity':
        return Icons.bolt_rounded;
      case 'mobile':
        return Icons.smartphone_rounded;
      case 'internet':
        return Icons.wifi_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'gas':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  void _onContinueToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProvider == null || _selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select provider and payment account')),
        );
        return;
      }

      final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (amt <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid bill amount')),
        );
        return;
      }

      if (_total > _selectedAccount!.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient balance in ${_selectedAccount!.accountType}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      BillConfirmDialog.show(
        context,
        billType: _selectedCategory.name,
        provider: _selectedProvider!,
        consumerNumber: _consumerNumberController.text.trim(),
        amount: amt,
        fee: _fee,
        totalAmount: _total,
        paymentAccount: _selectedAccount!,
        onConfirm: () {
          final banking = context.bankingRead;
          final billPayment = banking.payBill(
            fromAccount: _selectedAccount!,
            billType: _selectedCategory.name,
            provider: _selectedProvider!,
            consumerNumber: _consumerNumberController.text.trim(),
            amount: amt,
            fee: _fee,
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BillSuccessScreen(billPayment: billPayment),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final categories = banking.billCategories;
    final accounts = banking.accounts;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Utility Bill Payments'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bill Categories Carousel
                  const Text(
                    'Select Utility Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 98,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat.id == _selectedCategory.id;

                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _onCategorySelected(cat);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 86,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : AppColors.cardBorder.withValues(alpha: 0.9),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryNavy.withValues(alpha: 0.28),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : AppColors.softBlueBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(cat.id),
                                    color: isSelected ? AppColors.electricCyan : AppColors.accentBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form Details Section Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.9),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider Dropdown
                        const Text(
                          'Select Provider / Operator',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedProvider,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          items: _selectedCategory.providers.map((p) {
                            return DropdownMenuItem<String>(
                              value: p,
                              child: Text(p, style: const TextStyle(fontSize: 13.5)),
                            );
                          }).toList(),
                          onChanged: (p) {
                            setState(() {
                              _selectedProvider = p;
                            });
                          },
                          validator: (p) => p == null ? 'Please select provider' : null,
                        ),

                        const SizedBox(height: 18),

                        // Consumer Account / ID Number
                        const Text(
                          'Consumer ID / Account Number',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _consumerNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 10-digit consumer ID',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner, size: 20),
                              tooltip: 'Scan Bill QR',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Simulated: Consumer ID scanned from paper bill'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter consumer number';
                            }
                            if (val.trim().length < 6) {
                              return 'Consumer number must be at least 6 digits';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Bill Amount
                        const Text(
                          'Bill Amount (₹)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Text(
                                '₹',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          ),
                          onChanged: (_) => _updateTotal(),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter bill amount';
                            }
                            final amt = double.tryParse(val.trim());
                            if (amt == null || amt <= 0) {
                              return 'Amount must be greater than ₹0';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Payment Account
                        const Text(
                          'Payment Account',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Account>(
                          initialValue: accounts.any((a) => a.accountId == _selectedAccount?.accountId)
                              ? accounts.firstWhere((a) => a.accountId == _selectedAccount?.accountId)
                              : (accounts.isNotEmpty ? accounts.first : null),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          items: accounts.map((acc) {
                            return DropdownMenuItem<Account>(
                              value: acc,
                              child: Text(
                                '${acc.accountType} (${CurrencyFormatter.format(acc.balance)})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (acc) {
                            setState(() {
                              _selectedAccount = acc;
                            });
                          },
                          validator: (acc) => acc == null ? 'Select payment account' : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Calculation Summary Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.9),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bill Amount', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            Text(
                              CurrencyFormatter.format(double.tryParse(_amountController.text.trim()) ?? 0.0),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Convenience Fee', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            Text(
                              _fee == 0 ? 'FREE' : CurrencyFormatter.format(_fee),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _fee == 0 ? AppColors.successDark : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Payable',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              CurrencyFormatter.format(_total),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Continue to Payment Button
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _onContinueToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 19, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
