import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/views/edit_party_screen.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditLoanScreen extends StatefulWidget {
  final Loan? loan;
  const EditLoanScreen({super.key, this.loan});

  @override
  State<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends State<EditLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settleDateController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final ValueNotifier<bool> _useCurrentTime = ValueNotifier(true);

  String? _id;
  double? _amount;
  double? _fee;
  LoanKind? _kind;
  LoanStatus? _status;
  String? _partyId;
  String? _accountId;
  DateTime? _settleDate;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _settleDateController.dispose();
    super.dispose();
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

  void _pickSettleDate() async {
    final now = DateTime.now();
    final DateTime? choosenDate = await showDatePicker(
      context: context,
      initialDate: _settleDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || choosenDate == null) return;

    _settleDate = choosenDate;
    _settleDateController.text = DateHelper.formatDate(choosenDate);
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

  void _submit() {
    final loanProvider = context.read<LoanProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final settledAt = DateTime(
        _settleDate!.year,
        _settleDate!.month,
        _settleDate!.day,
      );

      final timestamp = _useCurrentTime.value
          ? DateTime.now()
          : DateTime(
              _date!.year,
              _date!.month,
              _date!.day,
              _time!.hour,
              _time!.minute,
            );

      if (_id == null) {
        loanProvider.add(
          amount: _amount!,
          fee: _fee,
          timestamp: timestamp,
          settledAt: settledAt,
          kind: _kind!,
          status: _status!,
          partyId: _partyId!,
          accountId: _accountId!,
        );
      }

      if (_id != null) {
        loanProvider.update(
          id: _id!,
          amount: _amount!,
          fee: _fee,
          timestamp: timestamp,
          settledAt: settledAt,
          kind: _kind!,
          status: _status!,
          partyId: _partyId!,
          accountId: _accountId!,
        );
      }

      Navigator.pop(context);
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
    final partyProvider = context.watch<PartyProvider>();
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter loan details",
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
              partyProvider.search(),
              accountProvider.search(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final parties = snapshot.data![0] as List<Party>;
              final accounts = snapshot.data![1] as List<Account>;

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
                    SelectFormField<LoanKind>(
                      onSaved: (value) => _kind = value,
                      initialValue: _kind ?? LoanKind.receiveable,
                      validator: (value) =>
                          value == null ? "Type is required" : null,
                      options: LoanKind.values.map((v) {
                        return SelectItem(value: v, label: v.label);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select loan type...",
                      ),
                    ),
                    SelectFormField<LoanStatus>(
                      onSaved: (value) => _status = value,
                      initialValue: _status ?? LoanStatus.active,
                      validator: (value) =>
                          value == null ? "Status is required" : null,
                      options: LoanStatus.values.map((v) {
                        return SelectItem(value: v, label: v.label);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status type...",
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _useCurrentTime,
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
                                      _useCurrentTime.value = true;
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text("Custom"),
                                    selected: !useCurrentTime,
                                    onSelected: (bool selected) {
                                      _useCurrentTime.value = false;
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
                    TextFormField(
                      readOnly: true,
                      controller: _settleDateController,
                      onTap: () => _pickSettleDate(),
                      decoration: InputStyles.field(
                        labelText: "Settle date",
                        hintText: "Select settle date...",
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Select settle date"
                          : null,
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
                    SelectFormField<String>(
                      onSaved: (value) => _partyId = value,
                      initialValue: _partyId,
                      validator: (value) =>
                          value == null ? "Party is required" : null,
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New party",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            redirect((_) => EditPartyScreen());
                          },
                        ),
                      ],
                      options: parties.map((party) {
                        return SelectItem(value: party.id, label: party.name);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Party",
                        hintText: "Select party...",
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
