import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/view_model.dart';

abstract class ListViewModel<T> extends ViewModel {
  bool get isEmpty;
  bool get hasNext;
  bool get hasPrevious;
  List<T> get hits;
  void applyFilter(DataFilter? filter);
  void resetFilter();
  Future<void> query();
  Future<void> next();
  Future<void> previous();
  Future<void> destroy(T model);
}
