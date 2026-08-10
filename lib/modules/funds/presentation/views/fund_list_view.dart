import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/presentation/widgets/fund_tile.dart';
import 'package:flutter/material.dart';

class FundListView extends StatelessWidget {
  const FundListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Fund>.builder(
      context,
      name: 'Funds',
      tileBuilder: FundTile.builder,
    );
  }
}
