import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/helpers/type_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferEditorView extends StatefulWidget {
  final String? id;
  final bool readOnly;

  const TransferEditorView({super.key, this.id, this.readOnly = false});

  @override
  State<TransferEditorView> createState() => _TransferEditorViewState();
}

class _TransferEditorViewState extends State<TransferEditorView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final transferProvider = context.read<TransferProvider>();

    try {
      if (_form.currentState!.validate()) {
        _form.currentState!.save();

        if (isNull(widget.id)) {
          await transferProvider.create(
            amount: _d["amount"],
            fee: _d["fee"],
            issuedAt: _d["issuedAt"].dateTime,
            debitAccountId: _d["debitAccountId"],
            creditAccountId: _d["creditAccountId"],
          );
        }

        if (!isNull(widget.id)) {
          await transferProvider.update(
            id: widget.id!,
            amount: _d["amount"],
            fee: _d["fee"],
            issuedAt: _d["issuedAt"].dateTime,
            debitAccountId: _d["debitAccountId"],
            creditAccountId: _d["creditAccountId"],
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

  @override
  void dispose() {
    super.dispose();
  }

  redirect(WidgetBuilder builder) {
    _form.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.watch<AccountProvider>();
    final transferProvider = context.read<TransferProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          !widget.readOnly ? "Enter transfer details" : "Transfer details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          if (!widget.readOnly)
            IconButton(onPressed: _submit, icon: Icon(Icons.check)),
        ],
        actionsPadding: EdgeInsets.all(8),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: Future.wait([
              accountProvider.search(),
              if (widget.id != null) transferProvider.get(widget.id!),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts = snapshot.data![0] as List<Account>;
              final transfer = widget.id != null
                  ? snapshot.data![1] as Transfer
                  : null;

              return Form(
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    AmountFormField(
                      readOnly: widget.readOnly,
                      initialValue: _d["amount"] ?? transfer?.amount,
                      onSaved: (value) => _d["amount"] = value,
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    AmountFormField(
                      readOnly: widget.readOnly,
                      initialValue: _d["fee"] ?? transfer?.fee,
                      onSaved: (value) => _d["fee"] = value,
                      decoration: InputStyles.field(
                        hintText: "Enter fee...",
                        labelText: "Fee",
                      ),
                    ),
                    WhenFormField(
                      readOnly: widget.readOnly,
                      options: WhenOption.notEmpty,
                      initialValue:
                          _d["issuedAt"] ??
                          (transfer?.issuedAt != null
                              ? When.specificTime(transfer!.issuedAt)
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
                    SelectFormField(
                      readOnly: widget.readOnly,
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
                      initialValue:
                          _d["creditAccountId"] ?? transfer?.creditAccountId,
                      onSaved: (value) => _d["creditAccountId"] = value ?? '',
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
                      readOnly: widget.readOnly,
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
                      initialValue:
                          _d["debitAccountId"] ?? transfer?.debitAccountId,
                      onSaved: (value) => _d["debitAccountId"] = value ?? '',
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
