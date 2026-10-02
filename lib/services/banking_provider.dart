import 'package:flutter/material.dart';
import 'banking_service.dart';

class BankingProvider extends InheritedNotifier<BankingService> {
  const BankingProvider({
    super.key,
    required BankingService service,
    required super.child,
  }) : super(notifier: service);

  static BankingService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BankingProvider>();
    assert(provider != null, 'No BankingProvider found in context');
    return provider!.notifier!;
  }

  static BankingService read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<BankingProvider>();
    final provider = element?.widget as BankingProvider?;
    assert(provider != null, 'No BankingProvider found in context');
    return provider!.notifier!;
  }
}

extension BankingExtension on BuildContext {
  BankingService get banking => BankingProvider.of(this);
  BankingService get bankingRead => BankingProvider.read(this);
}
