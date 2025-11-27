import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/providers/entry_provider.dart';
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
  final String savingsId;
  final String? entryId;
  final bool readOnly;

  const SavingEntryEditView({
    super.key,
    required this.savingsId,
    this.entryId,
    this.readOnly = false,
  });

  @override
  State<SavingEntryEditView> createState() => _SavingEntryEditViewState();
}

class _SavingEntryEditViewState extends State<SavingEntryEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final savingsProvider = context.read<SavingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!_form.currentState!.validate()) {
      return;
    }

    try {
      if (widget.entryId == null) {
        await savingsProvider.createEntry(
          savingsId: widget.savingsId,
          amount: _d["amount"],
          type: _d["type"],
          issuedAt: _d["issuedAt"].dateTime,
          labelIds: _d["labelIds"],
        );
      }

      if (widget.entryId != null) {
        await savingsProvider.updateEntry(
          entryId: widget.entryId!,
          savingsId: widget.savingsId,
          amount: _d["amount"],
          type: _d["type"],
          issuedAt: _d["issuedAt"].dateTime,
          labelIds: _d["labelIds"],
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
    final savingsProvider = context.watch<SavingsProvider>();
    final entryProvider = context.watch<EntryProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Entry details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        actions: [
          if (!widget.readOnly)
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
              labelProvider.search(),
              savingsProvider.get(widget.savingsId),
              if (widget.entryId != null) entryProvider.get(widget.entryId!),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final labels = snapshot.data![0] as List<Label>;
              final savings = snapshot.data![1] as Savings;
              final entry = widget.entryId != null
                  ? snapshot.data![2] as Entry
                  : null;

              final readonlyLabelIds = savings.labelIds;

              labels.sort((a, b) {
                final aReadonly = readonlyLabelIds.contains(a.id);
                final bReadonly = readonlyLabelIds.contains(b.id);

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
                      readOnly: widget.readOnly,
                      initialValue: _d["type"] ?? entry?.transactionType,
                      onSaved: (value) => _d["type"] = value,
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
                      readOnly: widget.readOnly,
                      decoration: InputStyles.field(
                        labelText: "Amount",
                        hintText: "Enter amount...",
                      ),
                      initialValue: _d["amount"] ?? entry?.amount.abs(),
                      onSaved: (value) => _d["amount"] = value,
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    WhenFormField(
                      readOnly: widget.readOnly,
                      options: WhenOption.min,
                      initialValue:
                          _d["issuedAt"] ??
                          (entry?.issuedAt != null
                              ? When.fromDateTime(entry!.issuedAt)
                              : When.now()),
                      onSaved: (value) => _d["issuedAt"] = value,
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
                      readOnly: widget.readOnly,
                      decoration: InputStyles.field(
                        labelText: "Labels",
                        hintText: "Select labels...",
                      ),
                      actions: [
                        if (!widget.readOnly)
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
                          _d["labelIds"] ??
                          entry?.labelIds ??
                          readonlyLabelIds ??
                          [],
                      options: labels.map((label) {
                        return MultiSelectItem(
                          value: label.id,
                          label: label.name,
                          enabled: !readonlyLabelIds.contains(label.id),
                        );
                      }).toList(),
                      onSaved: (value) {
                        _d["labelIds"] = value!.toList();
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
