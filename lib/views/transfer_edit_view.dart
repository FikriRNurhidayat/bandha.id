import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferEditView extends StatefulWidget {
  final Transfer? transfer;

  const TransferEditView({super.key, this.transfer});

  @override
  State<TransferEditView> createState() => _TransferEditViewState();
}

class _TransferEditViewState extends State<TransferEditView> {
  final _formKey = GlobalKey<FormState>();
  FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.transfer != null) {
      final transfer = widget.transfer!;
      _formData = transfer.toMap();
    }
  }

  void _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final transferProvider = context.read<TransferProvider>();

    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (_formData["id"] == null) {
          await transferProvider.create(
            amount: _formData["amount"],
            fee: _formData["fee"],
            issuedAt: _formData["issuedAt"],
            debitAccountId: _formData["debitAccountId"],
            creditAccountId: _formData["creditAccountId"],
          );
        }

        if (_formData["id"] != null) {
          await transferProvider.update(
            id: _formData["id"],
            amount: _formData["amount"],
            fee: _formData["fee"],
            issuedAt: _formData["issuedAt"],
            debitAccountId: _formData["debitAccountId"],
            creditAccountId: _formData["creditAccountId"],
          );
        }

        navigator.pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit transfer details failed")),
      );
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

  @override
  void dispose() {
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
                      initialValue: _formData["amount"]?.toInt().toString(),
                      onSaved: (value) =>
                          _formData["amount"] = double.tryParse(value ?? ''),
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      validator: (value) => _validateAmount(value),
                    ),
                    TextFormField(
                      initialValue: _formData["fee"]?.toInt().toString(),
                      onSaved: (value) =>
                          _formData["fee"] = double.tryParse(value ?? ''),
                      decoration: InputStyles.field(
                        hintText: "Enter fee...",
                        labelText: "Fee",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
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
                            redirect((_) => AccountEditView());
                          },
                        ),
                      ],
                      initialValue: _formData["creditAccountId"] as String?,
                      onSaved: (value) => _formData["creditAccountId"] = value ?? '',
                      validator: (_) => null,
                      decoration: InputStyles.field(
                        labelText: "From",
                        hintText: "Select source account...",
                      ),
                      options: accounts.map((i) {
                        return SelectItem(value: i.id, label: i.displayName());
                      }).toList(),
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
                            redirect((_) => AccountEditView());
                          },
                        ),
                      ],
                      initialValue: _formData["debitAccountId"] as String?,
                      onSaved: (value) => _formData["debitAccountId"] = value ?? '',
                      validator: (_) => null,
                      decoration: InputStyles.field(
                        labelText: "To",
                        hintText: "Select target account...",
                      ),
                      options: accounts.map((i) {
                        return SelectItem(value: i.id, label: i.displayName());
                      }).toList(),
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
