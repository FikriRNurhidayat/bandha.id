import 'package:banda/decorations/input_styles.dart';
import 'package:banda/features/accounts/entities/account.dart';
import 'package:banda/entity/bill.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/features/accounts/providers/account_provider.dart';
import 'package:banda/providers/bill_filter_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/widgets/date_time_range_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillFilterView extends StatefulWidget {
  final Filter? specs;

  const BillFilterView({super.key, this.specs});

  @override
  State<StatefulWidget> createState() {
    return _BillFilterViewState();
  }
}

class _BillFilterViewState extends State<BillFilterView> {
  final _formKey = GlobalKey<FormState>();
  final FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.specs != null) {
      if (widget.specs!.containsKey("note_like")) {
        _formData["note_like"] = widget.specs!["note_like"];
      }

      if (widget.specs!.containsKey("account_in")) {
        _formData["account_in"] = widget.specs!["account_in"];
      }

      if (widget.specs!.containsKey("status_in")) {
        _formData["status_in"] = widget.specs!["status_in"];
      }

      if (widget.specs!.containsKey("category_in")) {
        _formData["category_in"] = widget.specs!["category_in"];
      }

      if (widget.specs!.containsKey("cycle_in")) {
        _formData["cycle_in"] = widget.specs!["cycle_in"];
      }

      if (widget.specs!.containsKey("created_between")) {
        _formData["created_between"] = widget.specs!["created_between"];
      }

      if (widget.specs!.containsKey("billed_between")) {
        _formData["billed_between"] = widget.specs!["billed_between"];
      }
    }
  }

  void _submit() async {
    final Filter query = {};

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData["note_like"] != null &&
          _formData["note_like"]!.isNotEmpty) {
        query["note_like"] = _formData["note_like"];
      }

      if (_formData["cycle_in"] != null && _formData["cycle_in"]!.isNotEmpty) {
        query["cycle_in"] = _formData["cycle_in"];
      }

      if (_formData["status_in"] != null &&
          _formData["status_in"]!.isNotEmpty) {
        query["status_in"] = _formData["status_in"];
      }

      if (_formData["account_in"] != null &&
          _formData["account_in"]!.isNotEmpty) {
        query["account_in"] = _formData["account_in"];
      }

      if (_formData["category_in"] != null &&
          _formData["category_in"]!.isNotEmpty) {
        query["category_in"] = _formData["category_in"];
      }

      if (_formData["billed_between"] != null) {
        query["billed_between"] = _formData["billed_between"];
      }

      if (_formData["created_between"] != null) {
        query["created_between"] = _formData["created_between"];
      }

      context.read<BillFilterProvider>().set(query);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
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
          "Filter bills",
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
              accountProvider.search(),
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

              final accounts = snapshot.data![0] as List<Account>;
              final categories = snapshot.data![1] as List<Category>;
              final labels = snapshot.data![2] as List<Label>;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      decoration: InputStyles.field(
                        labelText: "Note",
                        hintText: "Search notes...",
                      ),
                      initialValue: _formData["note_like"],
                      onSaved: (value) => _formData["note_like"] = value,
                    ),
                    MultiSelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      initialValue: _formData["status_in"],
                      onSaved: (value) => _formData["status_in"] = value,
                      options: BillStatus.values
                          .map((s) => MultiSelectItem(value: s, label: s.label))
                          .toList(),
                    ),
                    MultiSelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Cycles",
                        hintText: "Select cycles...",
                      ),
                      initialValue: _formData["cycle_in"],
                      onSaved: (value) => _formData["cycle_in"] = value,
                      options: BillCycle.values
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
                        labelText: "Accounts",
                        hintText: "Select accounts...",
                      ),
                      initialValue: _formData["account_in"],
                      onSaved: (value) => _formData["account_in"] = value,
                      options: accounts
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
                        labelText: "Billed between",
                        hintText: "Select date range...",
                      ),
                      initialValue: _formData["billed_between"],
                      onSaved: (value) => _formData["billed_between"] = value,
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
