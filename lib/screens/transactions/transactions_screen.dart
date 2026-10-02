import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/banking_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Income', 'Expense', 'Bills'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final filteredList = banking.filteredTransactions;
    final currentFilter = banking.selectedTransactionFilter;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Activity & History'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // SearchBar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        banking.setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by merchant, note, or ID...',
                        prefixIcon: const Icon(Icons.search, size: 22, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  banking.setSearchQuery('');
                                },
                              )
                            : null,
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Luxury High-Contrast Segmented Filter Bar
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = filter == currentFilter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                banking.setTransactionFilter(filter);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.12),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Transactions List
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.softBlueBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Transactions Found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try searching for a different keyword or resetting your filter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final txn = filteredList[index];
                          return TransactionTile(
                            transaction: txn,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TransactionDetailsScreen(transaction: txn),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
