import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/edit_party_view.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanEditView extends StatefulWidget {
  final Loan? loan;
  const LoanEditView({super.key, this.loan});

  @override
  State<LoanEditView> createState() => _LoanEditViewState();
}

class _LoanEditViewState extends State<LoanEditView> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.loan != null) {
      _formData = widget.loan!.toMap();
    }
  }

  void _submit() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final loanProvider = context.read<LoanProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Future(() async {
        if (_formData["id"] == null) {
          await loanProvider.create(
            amount: _formData["amount"],
            issuedAt: _formData["issuedAt"],
            settledAt: _formData["settledAt"],
            kind: _formData["kind"],
            status: _formData["status"],
            partyId: _formData["partyId"],
            debitAccountId: _formData["debitAccountId"],
            creditAccountId: _formData["creditAccountId"],
          );
        }

        if (_formData["id"] != null) {
          await loanProvider.update(
            id: _formData["id"],
            amount: _formData["amount"],
            issuedAt: _formData["issuedAt"],
            settledAt: _formData["settledAt"],
            kind: _formData["kind"],
            status: _formData["status"],
            partyId: _formData["partyId"],
            debitAccountId: _formData["debitAccountId"],
            creditAccountId: _formData["creditAccountId"],
          );
        }
      }).then((_) => navigator.pop()).catchError((_) {
        messenger.showSnackBar(
          SnackBar(content: Text("Edit loan details failed")),
        );
      });
    }
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
        centerTitle: true,
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
                      initialValue: _formData["amount"]?.toInt().toString(),
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      onSaved: (value) =>
                          _formData["amount"] = double.tryParse(value!),
                    ),
                    SelectFormField<LoanKind>(
                      onSaved: (value) => _formData["kind"] = value,
                      initialValue: _formData["kind"] ?? LoanKind.receiveable,
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
                      onSaved: (value) => _formData["status"] = value,
                      initialValue: _formData["status"] ?? LoanStatus.active,
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
                    TimestampFormField(
                      decoration: InputStyles.field(
                        labelText: "Issued",
                        hintText: "Select issue date & time...",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Issue date",
                        hintText: "Select issue date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Issue time",
                        hintText: "Select issue time...",
                      ),
                      initialValue: _formData["issuedAt"],
                      onSaved: (value) => _formData["issuedAt"] = value,
                      validator: (value) =>
                          value == null ? "Issued timestamp is required" : null,
                    ),
                    TimestampFormField(
                      decoration: InputStyles.field(
                        labelText: "Settled",
                        hintText: "Select settle date & time...",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Settle date",
                        hintText: "Select settle date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Settle time",
                        hintText: "Select settle time...",
                      ),
                      initialValue: _formData["settledAt"],
                      onSaved: (value) => _formData["settledAt"] = value,
                      validator: (value) => value == null
                          ? "Settled timestamp is required"
                          : null,
                    ),
                    SelectFormField<String>(
                      initialValue: _formData["debitAccountId"],
                      onSaved: (value) => _formData["debitAccountId"] = value,
                      validator: (value) =>
                          value == null ? "Debit account is required" : null,
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
                        labelText: "Debit account",
                        hintText: "Select debit account...",
                      ),
                    ),
                    SelectFormField<String>(
                      initialValue: _formData["creditAccountId"],
                      onSaved: (value) => _formData["creditAccountId"] = value,
                      validator: (value) =>
                          value == null ? "Credit account is required" : null,
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
                        labelText: "Credit account",
                        hintText: "Select credit account...",
                      ),
                    ),
                    SelectFormField<String>(
                      initialValue: _formData["partyId"],
                      onSaved: (value) => _formData["partyId"] = value,
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
                            redirect((_) => EditPartyView());
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
