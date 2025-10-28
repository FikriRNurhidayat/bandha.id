import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTransferScreen extends StatefulWidget {
  final Transfer? transfer;

  const EditTransferScreen({super.key, this.transfer});

  @override
  State<EditTransferScreen> createState() => _EditTransferScreenState();
}

class _EditTransferScreenState extends State<EditTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final ValueNotifier<bool> _isNow = ValueNotifier(true);

  String? _id;
  double? _amount;
  double? _fee;
  String? _fromId;
  String? _toId;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();

    if (widget.transfer != null) {
      final transfer = widget.transfer!;

      _isNow.value = false;

      _id = transfer.id;
      _amount = transfer.amount;
      _fee = transfer.fee;
      _fromId = transfer.creditAccountId;
      _toId = transfer.debitAccountId;
      _date = DateTime(
        transfer.issuedAt.year,
        transfer.issuedAt.month,
        transfer.issuedAt.day,
      );
      _time = TimeOfDay.fromDateTime(transfer.issuedAt);

      _dateController.text = DateHelper.formatDate(_date!);
      _timeController.text = DateHelper.formatTime(_time!);
    }
  }

  void _submit() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final transferProvider = context.read<TransferProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final timestamp = _isNow.value
          ? DateTime.now()
          : DateTime(
              _date!.year,
              _date!.month,
              _date!.day,
              _time!.hour,
              _time!.minute,
            );

      Future(() async {
        if (_id == null) {
          await transferProvider.create(
            amount: _amount!,
            fee: _fee,
            issuedAt: timestamp,
            debitAccountId: _toId!,
            creditAccountId: _fromId!,
          );
        }

        if (_id != null) {
          await transferProvider.update(
            id: _id!,
            amount: _amount!,
            fee: _fee,
            issuedAt: timestamp,
            debitAccountId: _toId!,
            creditAccountId: _fromId!,
          );
        }
      }).then((_) => navigator.pop()).catchError((_) {
        messenger.showSnackBar(
          SnackBar(content: Text("Edit transfer details failed")),
        );
      });
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

  _validateAccount(String? sourceId, String? targetId) {
    if (sourceId == null || sourceId.isEmpty) {
      return "You need to specify on which accounts you want to transfer.";
    }

    if (sourceId == targetId) {
      return "You can't transfer to the same account.";
    }

    return null;
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
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter transfer details",
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
            future: accountProvider.search(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts = snapshot.data!;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      initialValue: _amount?.toInt().toString(),
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      onSaved: (value) => _amount = double.tryParse(value!),
                      validator: (value) => _validateAmount(value),
                    ),
                    TextFormField(
                      initialValue: _fee?.toInt().toString(),
                      decoration: InputStyles.field(
                        hintText: "Enter fee...",
                        labelText: "Fee",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      onSaved: (value) => _fee = double.tryParse(value!),
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
                    SelectFormField(
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
                      initialValue: _fromId,
                      decoration: InputStyles.field(
                        labelText: "From",
                        hintText: "Select source account...",
                      ),
                      options: accounts.map((i) {
                        return SelectItem(value: i.id, label: i.displayName());
                      }).toList(),
                      validator: (value) => _validateAccount(value, _toId),
                      onSaved: (value) => _fromId = value ?? '',
                    ),
                    SelectFormField(
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
                      initialValue: _toId,
                      decoration: InputStyles.field(
                        labelText: "To",
                        hintText: "Select target account...",
                      ),
                      validator: (value) => _validateAccount(value, _fromId),
                      options: accounts.map((i) {
                        return SelectItem(value: i.id, label: i.displayName());
                      }).toList(),
                      onSaved: (value) => _toId = value ?? '',
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
