import 'package:bandha/core/domain/entity.dart';

class Item<E extends Entity> {
  final E entity;
  bool isEdited = false;
  bool isSelected = false;
  bool readOnly = false;

  @override
  operator ==(Object other) =>
      other is Item<E> &&
      runtimeType == other.runtimeType &&
      entity.id == other.entity.id;

  @override
  int get hashCode => entity.id.hashCode;

  Item(this.entity, {this.readOnly = false});

  Item<E> notSelected(bool isSelected) {
    this.isSelected = !isSelected;
    return this;
  }

  Item<E> selected(bool isSelected) {
    this.isSelected = isSelected;
    return this;
  }

  Item<E> copyWith({bool? isSelected}) {
    final copied = Item<E>(entity);
    copied.isSelected = isSelected ?? copied.isSelected;
    return copied;
  }
}

typedef ItemBuilder<E extends Entity> = Item<E> Function(E);
