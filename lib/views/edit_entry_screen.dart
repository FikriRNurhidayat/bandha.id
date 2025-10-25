import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/views/edit_category_screen.dart';
import 'package:banda/views/edit_label_screen.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEntryScreen extends StatefulWidget {
  final Entry? entry;

  const EditEntryScreen({super.key, this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String? _id;
  String? _note;
  EntryType? _type;
  EntryStatus? _status;
  double? _amount;
  String? _categoryId;
  String? _accountId;
  List<String>? _labelIds;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();

    if (widget.entry != null) {
      final entry = widget.entry!;
      _id = entry.id;
      _note = entry.note;
      _status = entry.status;
      _categoryId = entry.categoryId;
      _accountId = entry.accountId;
      _amount = entry.amount.abs();
      _type = entry.amount >= 0 ? EntryType.income : EntryType.expense;
      _date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      _time = TimeOfDay.fromDateTime(entry.timestamp);
      _labelIds = entry.labels?.map((i) => i.id).toList() ?? [];

      _dateController.text = DateHelper.formatDate(_date!);
      _timeController.text = DateHelper.formatTime(_time!);
    }
  }

  void _submit() {
    final entryProvider = context.read<EntryProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final sign = _type == EntryType.income ? 1 : -1;

      final timestamp = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );

      if (_id == null) {
        entryProvider.add(
          note: _note!,
          amount: _amount! * sign,
          status: _status!,
          categoryId: _categoryId!,
          accountId: _accountId!,
          timestamp: timestamp,
          labelIds: _labelIds,
        );
      }

      if (_id != null) {
        entryProvider.update(
          id: _id!,
          note: _note!,
          amount: _amount! * sign,
          status: _status!,
          categoryId: _categoryId!,
          accountId: _accountId!,
          timestamp: timestamp,
          labelIds: _labelIds,
        );
      }

      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final DateTime? choosenDate = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || choosenDate == null) return;

    _date = choosenDate;
    _dateController.text = DateHelper.formatDate(choosenDate);
  }

  void _pickTime() async {
    final TimeOfDay? choosenTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || choosenTime == null) return;

    _time = choosenTime;
    _timeController.text = DateHelper.formatTime(choosenTime);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter entry details",
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
                      decoration: InputStyles.field(
                        labelText: "Note",
                        hintText: "Enter note...",
                      ),
                      initialValue: _note,
                      onSaved: (value) => _note = value ?? '',
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter note" : null,
                    ),
                    SelectFormField<EntryType>(
                      initialValue: _type,
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      onSaved: (value) => _type = value,
                      options: EntryType.values.map((c) {
                        return SelectItem(value: c, label: c.label);
                      }).toList(),
                    ),
                    TextFormField(
                      decoration: InputStyles.field(
                        labelText: "Amount",
                        hintText: "Enter amount...",
                      ),
                      initialValue: _amount?.toInt().toString(),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      onSaved: (value) => _amount = double.tryParse(value!),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter amount"
                          : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            onTap: () => _pickDate(),
                            decoration: InputStyles.field(
                              labelText: "Date",
                              hintText: "Select date...",
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Select date"
                                : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _timeController,
                            onTap: () => _pickTime(),
                            decoration: InputStyles.field(
                              labelText: "Time",
                              hintText: "Select time...",
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Select time"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SelectFormField<EntryStatus>(
                      initialValue: _status,
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      onSaved: (value) => _status = value,
                      options: EntryStatus.values
                          .where((c) => c != EntryStatus.unknown)
                          .map((c) {
                            return SelectItem(value: c, label: c.label);
                          })
                          .toList(),
                    ),
                    SelectFormField<String>(
                      initialValue: _categoryId,
                      decoration: InputStyles.field(
                        labelText: "Category",
                        hintText: "Select category...",
                      ),
                      onSaved: (value) => _categoryId = value,
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New category",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditCategoryScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      options: categories.where((c) => !c.readonly).map((c) {
                        return SelectItem(value: c.id, label: c.name);
                      }).toList(),
                    ),
                    SelectFormField(
                      decoration: InputStyles.field(
                        labelText: "Account",
                        hintText: "Select account...",
                      ),
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New account",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditAccountScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      initialValue: _accountId,
                      options: accounts.map((i) {
                        return SelectItem(
                          value: i.id,
                          label: "${i.name} — ${i.holderName}",
                        );
                      }).toList(),
                      onSaved: (value) => _accountId = value ?? '',
                    ),
                    MultiSelectFormField<String>(
                      decoration: InputStyles.field(
                        labelText: "Labels",
                        hintText: "Select labels...",
                      ),
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New label",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditLabelScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      initialValue: _labelIds ?? [],
                      options: labels.map((l) {
                        return MultiSelectItem(value: l.id, label: l.name);
                      }).toList(),
                      onSaved: (value) => _labelIds = value,
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
