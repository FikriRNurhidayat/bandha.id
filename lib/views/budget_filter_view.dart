import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/budget.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/budget_filter_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/widgets/date_time_range_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetFilterView extends StatefulWidget {
  final Specification? specs;

  const BudgetFilterView({super.key, this.specs});

  @override
  State<StatefulWidget> createState() {
    return _BudgetFilterViewState();
  }
}

class _BudgetFilterViewState extends State<BudgetFilterView> {
  final _formKey = GlobalKey<FormState>();
  final FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.specs != null) {
      if (widget.specs!.containsKey("category_in")) {
        _formData["category_in"] = widget.specs!["category_in"];
      }

      if (widget.specs!.containsKey("cycle_in")) {
        _formData["cycle_in"] = widget.specs!["cycle_in"];
      }

      if (widget.specs!.containsKey("created_between")) {
        _formData["created_between"] = widget.specs!["created_between"];
      }

      if (widget.specs!.containsKey("expired_between")) {
        _formData["expired_between"] = widget.specs!["expired_between"];
      }
    }
  }

  void _submit() async {
    final Specification query = {};

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData["cycle_in"] != null && _formData["cycle_in"]!.isNotEmpty) {
        query["cycle_in"] = _formData["cycle_in"];
      }

      if (_formData["category_in"] != null &&
          _formData["category_in"]!.isNotEmpty) {
        query["category_in"] = _formData["category_in"];
      }

      if (_formData["expired_between"] != null) {
        query["expired_between"] = _formData["expired_between"];
      }

      if (_formData["created_between"] != null) {
        query["created_between"] = _formData["created_between"];
      }

      context.read<BudgetFilterProvider>().set(query);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Filter budgets",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: _submit, icon: Icon(Icons.check)),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: Future.wait([
              categoryProvider.search(),
              labelProvider.search(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final [categories as List<Category>, labels as List<Label>] =
                  snapshot.data!;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    MultiSelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Cycles",
                        hintText: "Select cycles...",
                      ),
                      initialValue: _formData["cycle_in"],
                      onSaved: (value) => _formData["cycle_in"] = value,
                      options: BudgetCycle.values
                          .map((s) => MultiSelectItem(value: s, label: s.label))
                          .toList(),
                    ),
                    MultiSelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Categories",
                        hintText: "Select categories...",
                      ),
                      initialValue: _formData["category_in"],
                      onSaved: (value) => _formData["category_in"] = value,
                      options: categories
                          .map(
                            (c) => MultiSelectItem(value: c.id, label: c.name),
                          )
                          .toList(),
                    ),
                    MultiSelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Labels",
                        hintText: "Select labels...",
                      ),
                      initialValue: _formData["label_in"],
                      onSaved: (value) => _formData["label_in"] = value,
                      options: labels
                          .map(
                            (c) => MultiSelectItem(value: c.id, label: c.name),
                          )
                          .toList(),
                    ),
                    DateTimeRangeFormField(
                      decoration: InputStyles.field(
                        labelText: "Created between",
                        hintText: "Select date range...",
                      ),
                      initialValue: _formData["created_between"],
                      onSaved: (value) => _formData["created_between"] = value,
                    ),
                    DateTimeRangeFormField(
                      decoration: InputStyles.field(
                        labelText: "Expires between",
                        hintText: "Select date range...",
                      ),
                      initialValue: _formData["expired_between"],
                      onSaved: (value) => _formData["expired_between"] = value,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
