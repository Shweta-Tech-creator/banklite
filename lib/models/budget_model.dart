class BudgetCategory {
  final String name;
  final double spent;
  final double allocated;
  final int colorValue;

  BudgetCategory({
    required this.name,
    required this.spent,
    required this.allocated,
    required this.colorValue,
  });

  double get percentage => allocated > 0 ? ((spent / allocated) * 100).clamp(0.0, 100.0) : 0.0;
}

class Budget {
  double monthlyBudget;
  double totalSpent;
  Map<String, double> categorySpending;

  Budget({
    required this.monthlyBudget,
    required this.totalSpent,
    required this.categorySpending,
  });

  double get remaining => (monthlyBudget - totalSpent).clamp(0.0, double.infinity);

  double get percentageUsed {
    if (monthlyBudget <= 0) return 0.0;
    return ((totalSpent / monthlyBudget) * 100).clamp(0.0, 100.0);
  }

  bool get isOverBudget => totalSpent > monthlyBudget;

  Map<String, dynamic> toMap() {
    return {
      'monthlyBudget': monthlyBudget,
      'totalSpent': totalSpent,
      'categorySpending': categorySpending,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    Map<String, double> spending = {};
    if (map['categorySpending'] != null && map['categorySpending'] is Map) {
      final rawMap = map['categorySpending'] as Map;
      rawMap.forEach((key, value) {
        spending[key.toString()] = (value as num).toDouble();
      });
    }

    return Budget(
      monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 30000.0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      categorySpending: spending.isNotEmpty
          ? spending
          : {
              'Food': 6000.0,
              'Shopping': 5000.0,
              'Bills': 7500.0,
              'Travel': 3000.0,
            },
    );
  }
}
