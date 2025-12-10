import 'package:banda/entity/entry.dart';
import 'package:banda/entity/fund.dart';
import 'package:banda/helpers/money_helper.dart';
import 'package:banda/providers/fund_provider.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:banda/widgets/fund_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundEntriesView extends StatelessWidget {
  final String fundId;
  const FundEntriesView({super.key, required this.fundId});

  handleAddTap(BuildContext context) {
    Navigator.pushNamed(context, "/funds/$fundId/transactions/new");
  }

  handleMoreTap(BuildContext context) {
    Navigator.of(context).pushNamed("/funds/$fundId/menu");
  }

  handleTap(BuildContext context) {
    Navigator.of(context).pushNamed("/funds/$fundId/detail");
  }

  detailBuilder(BuildContext context, Fund fund) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fund.account.displayName(), style: theme.textTheme.bodySmall),
        labelsBuilder(context, fund),
      ],
    );
  }

  labelsBuilder(BuildContext context, Fund fund) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 8,
      children: [
        ...fund.labels
            .take(2)
            .map(
              (label) => Text(
                label.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
        if (fund.labels.length > 2)
          Icon(Icons.more_horiz, size: 8, color: theme.colorScheme.primary),
      ],
    );
  }

  progressBuilder(BuildContext context, Fund fund) {
    final theme = Theme.of(context);

    return Column(
      spacing: 8,
      children: [
        SizedBox(
          height: 8,
          child: LinearProgressIndicator(
            value: fund.getProgress(),
            backgroundColor: theme.colorScheme.surfaceContainer,
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MoneyText(
              fund.balance,
              useSymbol: false,
              style: theme.textTheme.labelSmall,
            ),
            MoneyText(
              fund.goal,
              useSymbol: false,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  progressLabelBuilder(BuildContext context, Fund fund) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(MoneyHelper.normalize(fund.balance), style: theme.textTheme.bodyLarge),
            Text("/", style: theme.textTheme.bodySmall),
            Text(MoneyHelper.normalize(fund.goal), style: theme.textTheme.bodyLarge),
          ],
        ),
        Badge(
          padding: EdgeInsets.all(0),
          label: Text(fund.status.label, style: theme.textTheme.bodySmall),
          textColor: theme.colorScheme.onSurface,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  fundBuilder(BuildContext context, Fund fund) {
    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          handleTap(context);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(fund.note), detailBuilder(context, fund)],
                  ),
                  progressLabelBuilder(context, fund),
                ],
              ),
              progressBuilder(context, fund),
            ],
          ),
        ),
      ),
    );
  }

  appBarBuilder(BuildContext context, Fund fund) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Fund transactions",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            handleMoreTap(context);
          },
          icon: Icon(Icons.more_horiz),
        ),
      ],
      actionsPadding: EdgeInsets.all(8.0),
    );
  }

  fabBuilder(BuildContext context, Fund fund) {
    if (!fund.canGrow()) return null;

    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        handleAddTap(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fundProvider = context.watch<FundProvider>();

    return FutureBuilder(
      future: fundProvider.get(fundId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("...")));
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: theme.textTheme.displayLarge!.fontSize,
              ),
            ),
          );
        }

        final fund = snapshot.data!;

        return Scaffold(
          appBar: appBarBuilder(context, fund),
          floatingActionButton: fabBuilder(context, fund),
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                fundBuilder(context, fund),
                FutureBuilder(
                  future: fundProvider.searchTransactions(fundId: fund.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("..."));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Icon(
                            Icons.dashboard_customize_outlined,
                            size: theme.textTheme.displayLarge!.fontSize,
                          ),
                        ),
                      );
                    }

                    final entries = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Entry entry = entries[index];
                          return FundTransactionTile(fund, entry);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
