import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/views/edit_label_view.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingEntryEditView extends StatefulWidget {
  final Saving saving;
  final Entry? entry;

  const SavingEntryEditView({super.key, required this.saving, this.entry});

  @override
  State<SavingEntryEditView> createState() => _SavingEntryEditViewState();
}

class _SavingEntryEditViewState extends State<SavingEntryEditView> {
  final _formKey = GlobalKey<FormState>();
  FormData _formData = {};
  late List<String> _readonlyLabelIds;

  @override
  void initState() {
    super.initState();

    _readonlyLabelIds =
        widget.saving.labels?.map((label) => label.id).toList() ?? [];

    if (widget.entry != null) {
      _formData = widget.entry!.toMap();
    }
  }

  void _submit() async {
    _formKey.currentState!.save();

    final navigator = Navigator.of(context);
    final savingProvider = context.read<SavingProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (widget.entry == null) {
        await savingProvider.createEntry(
          savingId: widget.saving.id,
          amount: _formData["amount"],
          type: _formData["type"],
          issuedAt: _formData["issuedAt"],
          labelIds: [
            ..._readonlyLabelIds,
            ..._formData["labelIds"].where(
              (labelId) => _readonlyLabelIds.contains(labelId),
            ),
          ],
        );
      }

      if (widget.entry != null) {
        await savingProvider.updateEntry(
          entryId: widget.entry!.id,
          savingId: widget.saving.id,
          amount: _formData["amount"],
          type: _formData["type"],
          issuedAt: _formData["issuedAt"],
          labelIds: [
            ..._readonlyLabelIds,
            ..._formData["labelIds"].where(
              (labelId) => _readonlyLabelIds.contains(labelId),
            ),
          ],
        );
      }

      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit saving entry details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _formKey.currentState!.save();
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
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    SelectFormField<TransactionType>(
                      initialValue: _formData["type"],
                      onSaved: (value) => _formData["type"] = value,
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      options: TransactionType.values.map((c) {
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
                      options: labels.map((label) {
                        return MultiSelectItem(
                          value: label.id,
                          label: label.name,
                          enabled: !_readonlyLabelIds.contains(label.id),
                        );
                      }).toList(),
                      onSaved: (value) {
                        _formData["labelIds"] = value!.toList();
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
