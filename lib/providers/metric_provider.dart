import 'package:banda/helpers/money_helper.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:flutter/material.dart';

class MetricProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  final AccountRepository accountRepository;
  final EntryRepository entryRepository;

  MetricProvider({
    required this.categoryRepository,
    required this.entryRepository,
    required this.accountRepository,
  });

  Future<List<Map>> compute(Map? spec) async {
    try {
      List<Map> metrics = [];

      final entriesCount = await entryRepository.count(spec);
      metrics.add({"name": "Total entries", "value": entriesCount.toString()});

      final balance = await entryRepository.sum(spec);
      metrics.add({"name": "Balance", "value": MoneyHelper.normalize(balance)});

      final income = await entryRepository.sum({...?spec, "amount_gt": 0.0});
      metrics.add({"name": "Income", "value": MoneyHelper.normalize(income)});

      final expense = await entryRepository.sum({...?spec, "amount_lt": 0.0});
      metrics.add({"name": "Expense", "value": MoneyHelper.normalize(expense)});

      return metrics;
    } catch (error, stack) {
      print(error);
      print(stack);
      rethrow;
    }
  }
}
