import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/loan_filter_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/widgets/date_time_range_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanFilterView extends StatefulWidget {
  final Specification? specs;

  const LoanFilterView({super.key, this.specs});

  @override
  State<StatefulWidget> createState() {
    return _LoanFilterViewState();
  }
}

class _LoanFilterViewState extends State<LoanFilterView> {
  final _formKey = GlobalKey<FormState>();
  final FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.specs != null) {
      if (widget.specs!.containsKey("debit_account_in")) {
        _formData["debit_account_in"] = widget.specs!["debit_account_in"];
      }

      if (widget.specs!.containsKey("credit_account_in")) {
        _formData["credit_account_in"] = widget.specs!["credit_account_in"];
      }

      if (widget.specs!.containsKey("status_in")) {
        _formData["status_in"] = widget.specs!["status_in"];
      }

      if (widget.specs!.containsKey("kind_in")) {
        _formData["kind_in"] = widget.specs!["kind_in"];
      }

      if (_formData["party_in"] != null && _formData["party_in"]!.isNotEmpty) {
        _formData["party_in"] = widget.specs!["party_in"];
      }

      if (widget.specs!.containsKey("issued_between")) {
        _formData["issued_between"] = widget.specs!["issued_between"];
      }
    }
  }

  void _submit() async {
    final Specification query = {};

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData["kind_in"] != null && _formData["kind_in"]!.isNotEmpty) {
        query["kind_in"] = _formData["kind_in"];
      }

      if (_formData["status_in"] != null &&
          _formData["status_in"]!.isNotEmpty) {
        query["status_in"] = _formData["status_in"];
      }

      if (_formData["debit_account_in"] != null &&
          _formData["debit_account_in"]!.isNotEmpty) {
        query["debit_account_in"] = _formData["debit_account_in"];
      }

      if (_formData["credit_account_in"] != null &&
          _formData["credit_account_in"]!.isNotEmpty) {
        query["credit_account_in"] = _formData["credit_account_in"];
      }

      if (_formData["party_in"] != null && _formData["party_in"]!.isNotEmpty) {
        query["party_in"] = _formData["party_in"];
      }

      if (_formData["issued_between"] != null) {
        query["issued_between"] = _formData["issued_between"];
      }

      context.read<LoanFilterProvider>().set(query);
      Navigator.pop(context);
    }
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
                    DateTimeRangeFormField(
                      decoration: InputStyles.field(
                        labelText: "Date",
                        hintText: "Select date...",
                      ),
                      initialValue: _formData["issued_between"],
                      onSaved: (value) => _formData["issued_between"] = value,
                    ),
                    MultiSelectFormField<LoanType>(
                      decoration: InputStyles.field(
                        labelText: "Type",
                        hintText: "Select type...",
                      ),
                      initialValue: _formData["kind_in"] ?? [],
                      options: LoanType.values
                          .map((i) => MultiSelectItem(value: i, label: i.label))
                          .toList(),
                      onSaved: (value) => _formData["kind_in"] = value,
                    ),
                    MultiSelectFormField<LoanStatus>(
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status...",
                      ),
                      initialValue: _formData["status_in"] ?? [],
                      options: LoanStatus.values
                          .map((i) => MultiSelectItem(value: i, label: i.label))
                          .toList(),
                      onSaved: (value) => _formData["status_in"] = value,
                    ),
                    if (parties.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Parties",
                          hintText: "Select parties...",
                        ),
                        initialValue: _formData["party_in"] ?? [],
                        options: parties
                            .map(
                              (i) =>
                                  MultiSelectItem(value: i.id, label: i.name),
                            )
                            .toList(),
                        onSaved: (value) => _formData["party_in"] = value,
                      ),
                    if (accounts.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Debit accounts",
                          hintText: "Select debit accounts...",
                        ),
                        initialValue: _formData["debit_account_in"] ?? [],
                        options: accounts
                            .map(
                              (i) => MultiSelectItem(
                                value: i.id,
                                label: i.displayName(),
                              ),
                            )
                            .toList(),
                        onSaved: (value) =>
                            _formData["debit_account_in"] = value,
                      ),
                    if (accounts.isNotEmpty)
                      MultiSelectFormField<String>(
                        decoration: InputStyles.field(
                          labelText: "Credit accounts",
                          hintText: "Select credit accounts...",
                        ),
                        initialValue: _formData["credit_account_in"] ?? [],
                        options: accounts
                            .map(
                              (i) => MultiSelectItem(
                                value: i.id,
                                label: i.displayName(),
                              ),
                            )
                            .toList(),
                        onSaved: (value) =>
                            _formData["credit_account_in"] = value,
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
