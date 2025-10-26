import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/loan_filter_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterLoanScreen extends StatefulWidget {
  final Map? specs;

  const FilterLoanScreen({super.key, this.specs});

  @override
  State<StatefulWidget> createState() {
    return _FilterLoanScreenState();
  }
}

class _FilterLoanScreenState extends State<FilterLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueDateController = TextEditingController();

  List<String>? _accountIdIn;
  List<String>? _partyIdIn;
  List<LoanStatus>? _statusIn;
  List<LoanKind>? _kindIn;
  DateTimeRange? _issuedBetween;

  @override
  void initState() {
    super.initState();

    if (widget.specs != null) {
      if (widget.specs!.containsKey("account_in")) {
        _accountIdIn = widget.specs!["account_in"];
      }

      if (widget.specs!.containsKey("status_in")) {
        _statusIn = widget.specs!["status_in"];
      }

      if (widget.specs!.containsKey("issued_between")) {
        final value = widget.specs!["issued_between"];
        _issuedBetween = DateTimeRange(start: value[0], end: value[1]);
        _issueDateController.text = DateHelper.formatDateRange(_issuedBetween!);
      }
    }
  }

  @override
  void dispose() {
    _issueDateController.dispose();
    super.dispose();
  }

  void _submit() async {
    final Map query = {};

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_kindIn != null && _kindIn!.isNotEmpty) {
        query["kind_in"] = _kindIn;
      }

      if (_statusIn != null && _statusIn!.isNotEmpty) {
        query["status_in"] = _statusIn;
      }

      if (_accountIdIn != null && _accountIdIn!.isNotEmpty) {
        query["account_in"] = _accountIdIn;
      }

      if (_partyIdIn != null && _partyIdIn!.isNotEmpty) {
        query["party_in"] = _partyIdIn;
      }

      if (_issuedBetween != null) {
        query["issued_between"] = [_issuedBetween!.start, _issuedBetween!.end];
      }

      context.read<LoanFilterProvider>().set(query);
      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final DateTimeRange? choosenDateRange = await showDateRangePicker(
      context: context,
      initialDateRange:
          _issuedBetween ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || choosenDateRange == null) return;

    _issuedBetween = choosenDateRange;
    _issueDateController.text = DateHelper.formatDateRange(choosenDateRange);
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final partyProvider = context.watch<PartyProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Filter loans",
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
              partyProvider.search(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts = snapshot.data![0] as List<Account>;
              final parties = snapshot.data![1] as List<Party>;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: _issueDateController,
                      onTap: () => _pickDate(),
                      decoration: InputStyles.field(
                        labelText: "Date",
                        hintText: "Select date...",
                      ),
                    ),
                    MultiSelectFormField<LoanKind>(
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      initialValue: _kindIn ?? [],
                      options: LoanKind.values
                          .map((i) => MultiSelectItem(value: i, label: i.label))
                          .toList(),
                      onSaved: (value) => _kindIn = value,
                    ),
                    MultiSelectFormField<LoanStatus>(
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      initialValue: _statusIn ?? [],
                      options: LoanStatus.values
                          .map((i) => MultiSelectItem(value: i, label: i.label))
                          .toList(),
                      onSaved: (value) => _statusIn = value,
                    ),
                    if (parties.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Parties",
                          hintText: "Select parties...",
                        ),
                        initialValue: _partyIdIn ?? [],
                        options: parties
                            .map(
                              (i) =>
                                  MultiSelectItem(value: i.id, label: i.name),
                            )
                            .toList(),
                        onSaved: (value) => _partyIdIn = value,
                      ),
                    if (accounts.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Accounts",
                          hintText: "Select accounts...",
                        ),
                        initialValue: _accountIdIn ?? [],
                        options: accounts
                            .map(
                              (i) => MultiSelectItem(
                                value: i.id,
                                label: i.displayName(),
                              ),
                            )
                            .toList(),
                        onSaved: (value) => _accountIdIn = value,
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
