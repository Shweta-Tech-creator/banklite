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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Balance Preview Card
                  if (_selectedAccount != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: AppColors.electricCyan, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available in ${_selectedAccount!.accountType}',
                                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                CurrencyFormatter.format(_selectedAccount!.balance),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Account>(
                    initialValue: _selectedAccount,
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
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _showAddBeneficiaryDialog,
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 16, color: AppColors.accentBlue),
                            SizedBox(width: 4),
                            Text(
                              'Add New',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Beneficiary Avatar Carousel
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: beneficiaries.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == beneficiaries.length) {
                          // Add New Beneficiary tile
                          return InkWell(
                            onTap: _showAddBeneficiaryDialog,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.softBlueBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: AppColors.accentBlue, size: 22),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add New',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentBlue),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final ben = beneficiaries[index];
                        final isSelected = _selectedBeneficiary?.id == ben.id;

                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedBeneficiary = ben);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 84,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.softBlueBg : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.accentBlue : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accentBlue.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected ? AppColors.accentBlue : AppColors.primaryNavy,
                                  child: Text(
                                    ben.initials,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ben.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ben.maskedNumber,
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Amount Input
                  const Text(
                    'Amount to Transfer (₹)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          '₹',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '0.00',
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
                    children: [500, 1000, 2000, 5000].map((amt) {
                      return ActionChip(
                        label: Text('+₹$amt'),
                        onPressed: () {
                          setState(() {
                            _amountController.text = amt.toString();
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Transfer Note (Optional)
                  const Text(
                    'Transfer Note (Optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Project fee, Rent, Dinner',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Continue Button
                  ElevatedButton(
                    onPressed: _onContinue,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue to Review'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
