import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/account_model.dart';
import '../../models/beneficiary_model.dart';
import '../../services/banking_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/responsive_wrapper.dart';
import 'transfer_confirm_dialog.dart';
import 'transfer_success_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Account? _selectedAccount;
  Beneficiary? _selectedBeneficiary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final banking = context.banking;
    _selectedAccount ??= banking.selectedAccount;
    if (_selectedBeneficiary == null && banking.beneficiaries.isNotEmpty) {
      _selectedBeneficiary = banking.beneficiaries.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddBeneficiaryDialog() {
    final nameCtrl = TextEditingController();
    final accCtrl = TextEditingController();
    final bankCtrl = TextEditingController(text: 'HDFC Bank');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Beneficiary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Beneficiary Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter beneficiary name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: accCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Account Number', prefixIcon: Icon(Icons.account_balance_outlined)),
                  validator: (val) => (val == null || val.trim().length < 8) ? 'Enter valid account number' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: bankCtrl,
                  decoration: const InputDecoration(labelText: 'Bank Name', prefixIcon: Icon(Icons.business_outlined)),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter bank name' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final banking = context.bankingRead;
                final newBen = banking.addBeneficiary(
                  name: nameCtrl.text.trim(),
                  accountNumber: accCtrl.text.trim(),
                  bankName: bankCtrl.text.trim(),
                );
                setState(() {
                  _selectedBeneficiary = newBen;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newBen.name} added to beneficiaries'),
                    backgroundColor: AppColors.successDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedAccount == null || _selectedBeneficiary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select account and beneficiary')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an amount greater than ₹0')),
        );
        return;
      }

      if (amount > _selectedAccount!.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient balance! Max available: ${CurrencyFormatter.format(_selectedAccount!.balance)}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      TransferConfirmDialog.show(
        context,
        fromAccount: _selectedAccount!,
        beneficiary: _selectedBeneficiary!,
        amount: amount,
        note: _noteController.text.trim(),
        onConfirm: () {
          final banking = context.bankingRead;
          final txn = banking.transferMoney(
            fromAccount: _selectedAccount!,
            beneficiary: _selectedBeneficiary!,
            amount: amount,
            note: _noteController.text.trim(),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TransferSuccessScreen(transaction: txn),
            ),
          );
        },
      );
    }
  }

  LinearGradient _getBeneficiaryGradient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('rahul')) {
      return const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]);
    } else if (lower.contains('priya')) {
      return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]);
    } else if (lower.contains('ankit')) {
      return const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF047857)]);
    }
    // Dynamic fallback gradient based on hash
    final hash = name.hashCode.abs();
    final gradients = [
      const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
      const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFBE185D)]),
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
      const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF047857)]),
      const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
    ];
    return gradients[hash % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final accounts = banking.accounts;
    final beneficiaries = banking.beneficiaries;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transfer Funds'),
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
                  // Signature Luxury Available Balance Preview Card
                  if (_selectedAccount != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.luxuryCardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            blurRadius: 28,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.18),
                                  Colors.white.withValues(alpha: 0.08),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.electricCyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available in ${_selectedAccount!.accountType}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(_selectedAccount!.balance),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // From Account Dropdown
                  const Text(
                    'Debit From Account',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Account>(
                    initialValue: accounts.any((a) => a.accountId == _selectedAccount?.accountId)
                        ? accounts.firstWhere((a) => a.accountId == _selectedAccount?.accountId)
                        : (accounts.isNotEmpty ? accounts.first : null),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem<Account>(
                        value: acc,
                        child: Text('${acc.accountType} (${acc.maskedNumber})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedAccount = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select source account' : null,
                  ),

                  const SizedBox(height: 22),

                  // Beneficiaries Header & Carousel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Beneficiary',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddBeneficiaryDialog,
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 16, color: AppColors.accentBlue),
                            SizedBox(width: 4),
                            Text(
                              'Add New',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Beneficiary Avatar Carousel with vibrant avatars
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: beneficiaries.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == beneficiaries.length) {
                          // Add New Beneficiary tile
                          return InkWell(
                            onTap: _showAddBeneficiaryDialog,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 86,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accentBlue.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.softBlueBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: AppColors.accentBlue, size: 22),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add New',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final ben = beneficiaries[index];
                        final isSelected = _selectedBeneficiary?.id == ben.id;
                        final avatarGradient = _getBeneficiaryGradient(ben.name);

                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedBeneficiary = ben);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 88,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.softBlueBg : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.accentBlue : AppColors.cardBorder,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accentBlue.withValues(alpha: 0.22),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
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
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: avatarGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      ben.initials,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ben.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ben.maskedNumber,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount Input
                  const Text(
                    'Amount to Transfer (₹)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '0.00',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter transfer amount';
                      }
                      final amt = double.tryParse(value.trim());
                      if (amt == null || amt <= 0) {
                        return 'Enter an amount greater than ₹0';
                      }
                      if (_selectedAccount != null && amt > _selectedAccount!.balance) {
                        return 'Amount exceeds available balance (${CurrencyFormatter.format(_selectedAccount!.balance)})';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Quick Amount Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [500, 1000, 2000, 5000].map((amt) {
                      final isCurrent = _amountController.text == amt.toString();
                      return ActionChip(
                        label: Text('+₹$amt'),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _amountController.text = amt.toString();
                          });
                        },
                        backgroundColor: isCurrent ? AppColors.softBlueBg : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isCurrent ? AppColors.accentBlue : AppColors.cardBorder,
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AppColors.accentBlue : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Transfer Note (Optional)
                  const Text(
                    'Transfer Note (Optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Project fee, Rent, Dinner',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Continue to Review Button
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
                      onPressed: _onContinue,
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
                            'Continue to Review',
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
