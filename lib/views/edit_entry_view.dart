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
import 'package:banda/views/edit_account_view.dart';
import 'package:banda/views/edit_category_view.dart';
import 'package:banda/views/edit_label_view.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEntryView extends StatefulWidget {
  final Entry? entry;

  const EditEntryView({super.key, this.entry});

  @override
  State<EditEntryView> createState() => _EditEntryViewState();
}

class _EditEntryViewState extends State<EditEntryView> {
  final _formKey = GlobalKey<FormState>();
  FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.entry != null) {
      _formData = widget.entry!.toMap();
    }
  }

  void _submit() async {
    _formKey.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final entryProvider = context.read<EntryProvider>();

    if (_formKey.currentState!.validate()) {
      try {
        if (_formData["id"] == null) {
          await entryProvider.create(
            note: _formData["note"],
            amount: _formData["amount"],
            type: _formData["type"],
            status: _formData["status"],
            categoryId: _formData["categoryId"],
            accountId: _formData["accountId"],
            issuedAt: _formData["issuedAt"],
            labelIds: _formData["labelIds"],
          );
        }

        if (_formData["id"] != null) {
          await entryProvider.update(
            id: _formData["id"],
            note: _formData["note"],
            amount: _formData["amount"],
            type: _formData["type"],
            status: _formData["status"],
            categoryId: _formData["categoryId"],
            accountId: _formData["accountId"],
            issuedAt: _formData["issuedAt"],
            labelIds: _formData["labelIds"],
          );
        }

        navigator.pop();
      } catch (error, stackTrace) {
        print(error);
        print(stackTrace);

        messenger.showSnackBar(
          SnackBar(content: Text("Edit entry details failed!")),
        );
      }
    }
  }

  redirect(WidgetBuilder builder) {
    _formKey.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
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

              if (snapshot.hasError) {
                return const Center(child: Text("..."));
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
                      initialValue: _formData["note"],
                      onSaved: (value) => _formData["note"] = value ?? '',
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter note" : null,
                    ),
                    SelectFormField<EntryType>(
                      initialValue: _formData["type"],
                      onSaved: (value) => _formData["type"] = value ?? '',
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      options: EntryType.values.map((c) {
                        return SelectItem(value: c, label: c.label);
                      }).toList(),
                    ),
                    TextFormField(
                      decoration: InputStyles.field(
                        labelText: "Amount",
                        hintText: "Enter amount...",
                      ),
                      initialValue: _formData["amount"]?.toInt().toString(),
                      onSaved: (value) =>
                          _formData["amount"] = double.tryParse(value ?? ''),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter amount"
                          : null,
                    ),
                    TimestampFormField(
                      initialValue: _formData["issuedAt"],
                      onSaved: (value) => _formData["issuedAt"] = value,
                      validator: (value) => value == null
                          ? "Issue date & time are required"
                          : null,
                      decoration: InputStyles.field(
                        hintText: "Select issue date & time...",
                        labelText: "Issued At",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Issue date",
                        hintText: "Select issue date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Issue time",
                        hintText: "Select issue time...",
                      ),
                    ),
                    SelectFormField<EntryStatus>(
                      initialValue: _formData["status"] ?? EntryStatus.done,
                      onSaved: (value) => _formData["status"] = value,
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
                      initialValue: _formData["categoryId"],
                      onSaved: (value) => _formData["categoryId"] = value,
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
                            redirect((_) => EditCategoryView());
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
                            redirect((_) => EditAccountView());
                          },
                        ),
                      ],
                      options: accounts.map((i) {
                        return SelectItem(
                          value: i.id,
                          label: "${i.name} — ${i.holderName}",
                        );
                      }).toList(),
                      initialValue: _formData["accountId"],
                      onSaved: (value) => _formData["accountId"] = value,
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
                            redirect((_) => EditLabelView());
                          },
                        ),
                      ],
                      initialValue: _formData["labelIds"] ?? [],
                      onSaved: (value) => _formData["labelIds"] = value,
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
