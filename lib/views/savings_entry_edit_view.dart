import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingEntryEditView extends StatefulWidget {
  final Savings savings;
  final Entry? entry;

  const SavingEntryEditView({super.key, required this.savings, this.entry});

  @override
  State<SavingEntryEditView> createState() => _SavingEntryEditViewState();
}

class _SavingEntryEditViewState extends State<SavingEntryEditView> {
  final _form = GlobalKey<FormState>();
  FormData _data = {};
  late List<String> _readonlyLabelIds;

  @override
  void initState() {
    super.initState();

    _readonlyLabelIds = widget.savings.labels.map((label) => label.id).toList();

    if (widget.entry != null) {
      _data = widget.entry!.toMap();
      _data["amount"] = _data["amount"].abs();
      _data["type"] = _data["amount"] >= 0
          ? TransactionType.deposit
          : TransactionType.withdrawal;
    }
  }

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final savingsProvider = context.read<SavingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!_form.currentState!.validate()) {
      return;
    }

    try {
      if (widget.entry == null) {
        await savingsProvider.createEntry(
          savingsId: widget.savings.id,
          amount: _data["amount"],
          type: _data["type"],
          issuedAt: _data["issuedAt"].dateTime,
          labelIds: [
            ..._readonlyLabelIds,
            ..._data["labelIds"].where(
              (labelId) => _readonlyLabelIds.contains(labelId),
            ),
          ],
        );
      }

      if (widget.entry != null) {
        await savingsProvider.updateEntry(
          entryId: widget.entry!.id,
          savingsId: widget.savings.id,
          amount: _data["amount"],
          type: _data["type"],
          issuedAt: _data["issuedAt"].dateTime,
          labelIds: [
            ..._readonlyLabelIds,
            ..._data["labelIds"].where(
              (labelId) => _readonlyLabelIds.contains(labelId),
            ),
          ],
        );
      }

      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit savings entry details failed")),
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
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Saving entry details",
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
            future: labelProvider.search(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final labels = snapshot.data!;
              labels.sort((a, b) {
                final aReadonly = _readonlyLabelIds.contains(a.id);
                final bReadonly = _readonlyLabelIds.contains(b.id);

                if (aReadonly && !bReadonly) return -1;
                if (!aReadonly && bReadonly) return 1;
                return a.name.compareTo(b.name);
              });

              return Form(
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    SelectFormField<TransactionType>(
                      initialValue: _data["type"],
                      onSaved: (value) => _data["type"] = value,
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      options: TransactionType.values.map((c) {
                        return SelectItem(value: c, label: c.label);
                      }).toList(),
                      validator: (value) =>
                          value == null ? "Type is required" : null,
                    ),
                    AmountFormField(
                      decoration: InputStyles.field(
                        labelText: "Amount",
                        hintText: "Enter amount...",
                      ),
                      initialValue: _data["amount"],
                      onSaved: (value) => _data["amount"] = value,
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    WhenFormField(
                      options: WhenOption.min,
                      initialValue: _data["issuedAt"],
                      onSaved: (value) => _data["issuedAt"] = value,
                      validator: (value) => value == null
                          ? "Issue Date & time are required"
                          : null,
                      decoration: InputStyles.field(
                        hintText: "Select issue date & time...",
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
                      initialValue: _data["labelIds"] ?? [],
                      options: labels.map((label) {
                        return MultiSelectItem(
                          value: label.id,
                          label: label.name,
                          enabled: !_readonlyLabelIds.contains(label.id),
                        );
                      }).toList(),
                      onSaved: (value) {
                        _data["labelIds"] = value!.toList();
                      },
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
