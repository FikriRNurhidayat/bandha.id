import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FundTile extends StatelessWidget {
  final Item<Fund> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onTap;
  final AsyncCallback? onLongPress;

  const FundTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

  factory FundTile.builder(
    Item<Fund> item, {
    AsyncCallback? onLongPress,
    AsyncCallback? onTap,
    bool? readOnly,
    bool? minified,
  }) {
    return FundTile(
      item,
      onTap: onTap,
      onLongPress: onLongPress,
      readOnly: readOnly ?? false,
      minified: minified ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tile(
      selected: item.isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [],
        ),
      ),
    );
  }
}
