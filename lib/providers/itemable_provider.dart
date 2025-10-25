import 'package:banda/entity/itemable.dart';
import 'package:flutter/material.dart';

abstract class ItemableProvider<I extends Itemable> extends ChangeNotifier {
  Future<List<I>> search();
  Future<void> add({required String name});
  Future<void> update({required String id, required String name});
  Future<void> remove(String id);
}
