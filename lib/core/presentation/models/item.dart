import 'package:bandha/core/domain/entity.dart';

class Item<E extends Entity> {
  final E entity;
  bool isSelected = false;

  Item(this.entity);

  Item<E> selected(bool isSelected) {
    this.isSelected = isSelected;
    return this;
  }
}

typedef ItemBuilder<E extends Entity> = Item<E> Function(E);
