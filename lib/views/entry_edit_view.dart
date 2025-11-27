import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryEditView extends StatefulWidget {
  final String? id;

  const EntryEditView({super.key, this.id});

  @override
  State<EntryEditView> createState() => _EntryEditViewState();
}

class _EntryEditViewState extends State<EntryEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _data = {};

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final entryProvider = context.read<EntryProvider>();

    if (_form.currentState!.validate()) {
      try {
        if (widget.id == null) {
          await entryProvider.create(
            note: _data["note"],
            amount: _data["amount"],
            type: _data["type"],
            status: _data["status"],
            categoryId: _data["categoryId"],
            accountId: _data["accountId"],
            issuedAt: _data["issuedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }

        if (widget.id != null) {
          await entryProvider.update(
            id: widget.id!,
            note: _data["note"],
            amount: _data["amount"],
            type: _data["type"],
            status: _data["status"],
            categoryId: _data["categoryId"],
            accountId: _data["accountId"],
            issuedAt: _data["issuedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }

        navigator.pop();
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text("Edit entry details failed!")),
        );
      }
    }
  }

  redirect(WidgetBuilder builder) {
    _form.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryProvider = context.read<EntryProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
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
              if (widget.id != null) entryProvider.get(widget.id!),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("..."));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data![0] as List<Category>;
              final accounts = snapshot.data![1] as List<Account>;
              final labels = snapshot.data![2] as List<Label>;
              final entry = widget.id != null
                  ? snapshot.data![3] as Entry
                  : null;

              return Form(
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      decoration: InputStyles.field(
                        labelText: "Note",
                        hintText: "Enter note...",
                      ),
                      initialValue: _data["note"] ?? entry?.note,
                      onSaved: (value) => _data["note"] = value ?? '',
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter note" : null,
                    ),
                    SelectFormField<EntryType>(
                      initialValue: _data["type"] ?? entry?.entryType,
                      onSaved: (value) => _data["type"] = value,
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      options: EntryType.values.map((c) {
                        return SelectItem(value: c, label: c.label);
                      }).toList(),
                    ),
                    AmountFormField(
                      decoration: InputStyles.field(
                        labelText: "Amount",
                        hintText: "Enter amount...",
                      ),
                      initialValue:
                          _data["amount"]?.abs() ?? entry?.amount.abs(),
                      onSaved: (value) => _data["amount"] = value,
                      validator: (value) =>
                          value == null ? "Enter amount" : null,
                    ),
                    WhenFormField(
                      options: WhenOption.min,
                      initialValue:
                          _data["issuedAt"] ??
                          (entry?.issuedAt != null
                              ? When.fromDateTime(entry!.issuedAt)
                              : When.now()),
                      onSaved: (value) => _data["issuedAt"] = value,
                      validator: (value) =>
                          value == null ? "Date & time are required" : null,
                      decoration: InputStyles.field(
                        hintText: "Select date & time...",
                        labelText: "Date & Time",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Date",
                        hintText: "Select date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Time",
                        hintText: "Select time...",
                      ),
                    ),
                    SelectFormField<EntryStatus>(
                      initialValue:
                          _data["status"] ?? entry?.status ?? EntryStatus.done,
                      onSaved: (value) => _data["status"] = value,
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      options: EntryStatus.values
                          .where((c) => c != EntryStatus.unknown)
                          .map((c) {
                            return SelectItem(value: c, label: c.label);
                          })
                          .toList(),
                    ),
                    SelectFormField<String>(
                      initialValue: _data["categoryId"] ?? entry?.categoryId,
                      onSaved: (value) => _data["categoryId"] = value,
                      decoration: InputStyles.field(
                        labelText: "Category",
                        hintText: "Select category...",
                      ),
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
                            redirect((_) => CategoryEditView());
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
                            redirect((_) => AccountEditView());
                          },
                        ),
                      ],
                      options: accounts.map((i) {
                        return SelectItem(
                          value: i.id,
                          label: "${i.name} — ${i.holderName}",
                        );
                      }).toList(),
                      initialValue: _data["accountId"] ?? entry?.accountId,
                      onSaved: (value) => _data["accountId"] = value,
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
                            redirect((_) => LabelEditView());
                          },
                        ),
                      ],
                      initialValue:
                          _data["labelIds"] ?? entry?.labelIds ?? [],
                      onSaved: (value) => _data["labelIds"] = value,
                      options: labels.map((l) {
                        return MultiSelectItem(value: l.id, label: l.name);
                      }).toList(),
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
