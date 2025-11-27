import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsEditView extends StatefulWidget {
  final String? id;
  const SavingsEditView({super.key, this.id});

  @override
  State<SavingsEditView> createState() => _SavingsEditViewState();
}

class _SavingsEditViewState extends State<SavingsEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final savingsProvider = context.read<SavingsProvider>();

    try {
      if (_form.currentState!.validate()) {
        _form.currentState!.save();

        if (widget.id == null) {
          await savingsProvider.create(
            goal: _d["goal"],
            accountId: _d["accountId"],
            labelIds: _d["labelIds"],
            note: _d["note"],
          );
        }

        if (widget.id != null) {
          await savingsProvider.update(
            id: widget.id!,
            goal: _d["goal"],
            labelIds: _d["labelIds"],
            note: _d["note"],
          );
        }

        navigator.pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit savings details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _form.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingsProvider = context.read<SavingsProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter savings details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
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
              if (widget.id != null) savingsProvider.get(widget.id!),
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
              final savings = widget.id != null ? (snapshot.data![2] as Savings) : null;

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
                      initialValue: _d["note"] ?? savings?.note,
                      onSaved: (value) => _d["note"] = value ?? '',
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter note" : null,
                    ),
                    AmountFormField(
                      initialValue: _d["goal"] ?? savings?.goal,
                      onSaved: (value) => _d["goal"] = value,
                      decoration: InputStyles.field(
                        hintText: "Enter goal...",
                        labelText: "Goal",
                      ),
                      validator: (value) =>
                          value == null ? "Goal is required" : null,
                    ),
                    SelectFormField<String>(
                      initialValue: _d["accountId"] ?? savings?.accountId,
                      onSaved: (value) => _d["accountId"] = value,
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
                            redirect((_) => AccountEditView());
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
                      initialValue: _d["labelIds"] ?? savings?.labelIds ?? [],
                      onSaved: (value) => _d["labelIds"] = value,
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
