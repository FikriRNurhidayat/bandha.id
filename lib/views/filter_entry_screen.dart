import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_filter_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterEntryScreen extends StatefulWidget {
  final Map? specs;

  const FilterEntryScreen({super.key, this.specs});

  @override
  State<StatefulWidget> createState() {
    return _FilterEntryScreenState();
  }
}

class _FilterEntryScreenState extends State<FilterEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  String? _noteRegex;
  List<String>? _labelIdIn;
  List<String>? _categoryIdIn;
  List<String>? _accountIdIn;
  DateTimeRange? _timestampBetween;
  List<EntryStatus>? _statusIn;

  @override
  void initState() {
    super.initState();

    if (widget.specs != null) {
      if (widget.specs!.containsKey("category_in")) {
        _categoryIdIn = widget.specs!["category_in"];
      }

      if (widget.specs!.containsKey("account_in")) {
        _accountIdIn = widget.specs!["account_in"];
      }

      if (widget.specs!.containsKey("label_in")) {
        _labelIdIn = widget.specs!["label_in"];
      }

      if (widget.specs!.containsKey("note_regex")) {
        _noteRegex = widget.specs!["note_regex"];
      }

      if (widget.specs!.containsKey("status_in")) {
        _statusIn = widget.specs!["status_in"];
      }

      if (widget.specs!.containsKey("timestamp_between")) {
        final value = widget.specs!["timestamp_between"];
        _timestampBetween = DateTimeRange(start: value[0], end: value[1]);
        _dateController.text = DateHelper.formatDateRange(_timestampBetween!);
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _submit() async {
    final Map query = {};

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_noteRegex != null && _noteRegex!.isNotEmpty) {
        query["note_regex"] = _noteRegex;
      }

      if (_labelIdIn != null && _labelIdIn!.isNotEmpty) {
        query["label_in"] = _labelIdIn;
      }

      if (_statusIn != null && _statusIn!.isNotEmpty) {
        query["status_in"] = _statusIn;
      }

      if (_categoryIdIn != null && _categoryIdIn!.isNotEmpty) {
        query["category_in"] = _categoryIdIn;
      }

      if (_accountIdIn != null && _accountIdIn!.isNotEmpty) {
        query["account_in"] = _accountIdIn;
      }

      if (_timestampBetween != null) {
        query["timestamp_between"] = [
          _timestampBetween!.start,
          _timestampBetween!.end,
        ];
      }

      context.read<EntryFilterProvider>().set(query);
      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final DateTimeRange? choosenDateRange = await showDateRangePicker(
      context: context,
      initialDateRange:
          _timestampBetween ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || choosenDateRange == null) return;

    _timestampBetween = choosenDateRange;
    _dateController.text = DateHelper.formatDateRange(choosenDateRange);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Filter entries",
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
              accountProvider.search(),
              labelProvider.search(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data![0] as List<Category>;
              final accounts = snapshot.data![1] as List<Account>;
              final labels = snapshot.data![2] as List<Label>;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      initialValue: _noteRegex,
                      decoration: InputStyles.field(
                        labelText: "Note",
                        hintText: "Search note...",
                      ),
                      onSaved: (value) => _noteRegex = value,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      onTap: () => _pickDate(),
                      decoration: InputStyles.field(
                        labelText: "Date",
                        hintText: "Select date...",
                      ),
                    ),
                    MultiSelectFormField<EntryStatus>(
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      initialValue: _statusIn ?? [],
                      options: EntryStatus.values
                          .map((i) => MultiSelectItem(value: i, label: i.label))
                          .toList(),
                      onSaved: (value) => _statusIn = value,
                    ),
                    MultiSelectFormField<String>(
                      decoration: InputStyles.field(
                        labelText: "Categories",
                        hintText: "Select categories...",
                      ),
                      initialValue: _categoryIdIn ?? [],
                      options: categories
                          .map(
                            (i) => MultiSelectItem(value: i.id, label: i.name),
                          )
                          .toList(),
                      onSaved: (value) => _categoryIdIn = value,
                    ),
                    if (accounts.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Accounts",
                          hintText: "Select accounts...",
                        ),
                        initialValue: _accountIdIn ?? [],
                        options: accounts
                            .map(
                              (i) => MultiSelectItem(
                                value: i.id,
                                label: "${i.name} — ${i.holderName}",
                              ),
                            )
                            .toList(),
                        onSaved: (value) => _accountIdIn = value,
                      ),
                    if (labels.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Labels",
                          hintText: "Select labels...",
                        ),
                        initialValue: _labelIdIn ?? [],
                        options: labels
                            .map(
                              (i) =>
                                  MultiSelectItem(value: i.id, label: i.name),
                            )
                            .toList(),
                        onSaved: (value) => _labelIdIn = value,
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
