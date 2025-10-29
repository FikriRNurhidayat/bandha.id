import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/views/edit_label_screen.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSavingScreen extends StatefulWidget {
  final Saving? saving;
  const EditSavingScreen({super.key, this.saving});

  @override
  State<EditSavingScreen> createState() => _EditSavingScreenState();
}

class _EditSavingScreenState extends State<EditSavingScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _id;
  double? _goal;
  String? _note;
  String? _accountId;
  List<String>? _labelIds;

  @override
  void initState() {
    super.initState();

    if (widget.saving != null) {
      final saving = widget.saving!;

      _id = saving.id;
      _goal = saving.goal;
      _note = saving.note;
      _accountId = saving.accountId;
      _labelIds = saving.labels?.map((i) => i.id).toList() ?? [];
    }
  }

  void _submit() async {
    final navigator = Navigator.of(context);
    final savingProvider = context.read<SavingProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_id == null) {
        await savingProvider.create(
          goal: _goal!,
          accountId: _accountId!,
          labelIds: _labelIds,
          note: _note!,
        );
      }

      if (_id != null) {
        await savingProvider.update(
          id: _id!,
          goal: _goal!,
          labelIds: _labelIds,
          note: _note!,
        );
      }

      navigator.pop();
    }
  }

  _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return "Amount is required";
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return "Amount is incorrect";
    }

    if (amount <= 0) {
      return "Amount MUST be positive.";
    }

    return null;
  }

  redirect(WidgetBuilder builder) {
    _formKey.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.watch<AccountProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter saving details",
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
              final labels = snapshot.data![1] as List<Label>;

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
                    TextFormField(
                      initialValue: _goal?.toInt().toString(),
                      decoration: InputStyles.field(
                        hintText: "Enter goal...",
                        labelText: "Goal",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      onSaved: (value) => _goal = double.tryParse(value!),
                      validator: (value) => _validateAmount(value),
                    ),
                    SelectFormField<String>(
                      onSaved: (value) => _accountId = value,
                      initialValue: _accountId,
                      validator: (value) =>
                          value == null ? "Account is required" : null,
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
                            redirect((_) => EditAccountScreen());
                          },
                        ),
                      ],
                      options: accounts.map((account) {
                        return SelectItem(
                          value: account.id,
                          label: account.displayName(),
                        );
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Account",
                        hintText: "Select account...",
                      ),
                    ),
                    MultiSelectFormField<String>(
                      onSaved: (value) => _labelIds = value,
                      initialValue: _labelIds ?? [],
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
                            redirect((_) => EditLabelScreen());
                          },
                        ),
                      ],
                      options: labels.map((labe) {
                        return MultiSelectItem(
                          value: labe.id,
                          label: labe.name,
                        );
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Labels",
                        hintText: "Select labels...",
                      ),
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
