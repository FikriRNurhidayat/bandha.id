import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/views/edit_label_screen.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSavingEntryScreen extends StatefulWidget {
  final Saving saving;
  final Entry? entry;

  const EditSavingEntryScreen({super.key, required this.saving, this.entry});

  @override
  State<EditSavingEntryScreen> createState() => _EditSavingEntryScreenState();
}

class _EditSavingEntryScreenState extends State<EditSavingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final ValueNotifier<bool> _isNow = ValueNotifier(true);

  TransactionType? _type;
  double? _amount;
  List<String> _readonlyLabelIds = [];
  List<String> _labelIds = [];
  DateTime? _issueDate;
  TimeOfDay? _issueTime;

  @override
  void initState() {
    super.initState();

    _readonlyLabelIds =
        widget.saving.labels?.map((label) => label.id).toList() ?? [];

    if (widget.entry != null) {
      final entry = widget.entry!;
      _type = entry.amount >= 0
          ? TransactionType.withdrawal
          : TransactionType.deposit;
      _amount = entry.amount.abs();
      _labelIds = [
        ..._readonlyLabelIds,
        ...entry.labels
                ?.where((label) => !_readonlyLabelIds.contains(label.id))
                .map((label) => label.id)
                .toList() ??
            [],
      ];
    }
  }

  void _submit() {
    final navigator = Navigator.of(context);
    final savingProvider = context.read<SavingProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final issuedAt = _isNow.value
          ? DateTime.now()
          : DateTime(
              _issueDate!.year,
              _issueDate!.month,
              _issueDate!.day,
              _issueTime!.hour,
              _issueTime!.minute,
            );

      Future(() async {
        if (widget.entry == null) {
          await savingProvider.createEntry(
            savingId: widget.saving.id,
            amount: _amount!,
            type: _type!,
            issuedAt: issuedAt,
            labelIds: [
              ..._readonlyLabelIds,
              ..._labelIds.where(
                (labelId) => _readonlyLabelIds.contains(labelId),
              ),
            ],
          );
        }

        if (widget.entry != null) {
          await savingProvider.updateEntry(
            entryId: widget.entry!.id,
            savingId: widget.saving.id,
            amount: _amount!,
            type: _type!,
            issuedAt: issuedAt,
            labelIds: _labelIds,
          );
        }
      }).then((_) => navigator.pop()).catchError((_) {
        messenger.showSnackBar(
          SnackBar(content: Text("Edit saving entry details failed")),
        );
      });
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final DateTime? choosenDate = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || choosenDate == null) return;

    _issueDate = choosenDate;
    _dateController.text = DateHelper.formatDate(choosenDate);
  }

  void _pickTime() async {
    final TimeOfDay? choosenTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || choosenTime == null) return;

    _issueTime = choosenTime;
    _timeController.text = DateHelper.formatTime(choosenTime);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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
                      initialValue: _type,
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      onSaved: (value) => _type = value,
                      options: TransactionType.values.map((c) {
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
                    ValueListenableBuilder(
                      valueListenable: _isNow,
                      builder: (context, useCurrentTime, _) {
                        return Column(
                          spacing: 16,
                          children: [
                            InputDecorator(
                              decoration: InputStyles.field(
                                labelText: "Timestamp",
                                hintText: "Select timestamp...",
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: Text("Now"),
                                    selected: useCurrentTime,
                                    onSelected: (bool selected) {
                                      _isNow.value = true;
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text("Specific"),
                                    selected: !useCurrentTime,
                                    onSelected: (bool selected) {
                                      _isNow.value = false;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (!useCurrentTime)
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
                                      validator: (value) =>
                                          value == null || value.isEmpty
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
                                      validator: (value) =>
                                          value == null || value.isEmpty
                                          ? "Select time"
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
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
                            redirect((_) => EditLabelScreen());
                          },
                        ),
                      ],
                      initialValue: _labelIds,
                      options: labels.map((label) {
                        return MultiSelectItem(
                          value: label.id,
                          label: label.name,
                          enabled: !_readonlyLabelIds.contains(label.id),
                        );
                      }).toList(),
                      onSaved: (value) {
                        _labelIds = value!.toList();
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
