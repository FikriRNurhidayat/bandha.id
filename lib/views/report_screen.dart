import 'package:banda/providers/entry_filter_provider.dart';
import 'package:banda/providers/metric_provider.dart';
import 'package:banda/views/filter_entry_screen.dart';
import 'package:banda/widgets/empty.dart';
import 'package:banda/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  static String title = "Reports";
  static IconData icon = Icons.analytics;

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<EntryFilterProvider>();
    final filter = filterProvider.get();

    return [
      if (filter != null)
        IconButton(
          onPressed: () {
            filterProvider.reset();
          },
          icon: Icon(Icons.close),
        ),
      IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FilterEntryScreen(specification: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.filter_list_alt),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final metricProvider = context.watch<MetricProvider>();
    final filterProvider = context.watch<EntryFilterProvider>();

    return FutureBuilder(
      future: metricProvider.compute(filterProvider.get()),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Empty("No metrics available");
          }
        }

        final metrics = snapshot.data as List<Map>;

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, i) {
            final metric = metrics[i];
            return MetricCard(label: metric["name"], value: metric["value"]);
          },
        );
      },
    );
  }
}
