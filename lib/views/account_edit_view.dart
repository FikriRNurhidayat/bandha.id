import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountEditView extends StatefulWidget {
  final Account? account;
  const AccountEditView({super.key, this.account});

  @override
  State<AccountEditView> createState() => _AccountEditViewState();
}

class _AccountEditViewState extends State<AccountEditView> {
  final _formKey = GlobalKey<FormState>();
  FormData _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      final account = widget.account!;
      _formData = account.toMap() as FormData;
    }
  }

  void _submit() async {
    final accountProvider = context.read<AccountProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (_formData["id"] == null) {
          await accountProvider.create(
            name: _formData["name"],
            holderName: _formData["holderName"],
            kind: _formData["kind"],
          );
        } else {
          await accountProvider.update(
            id: _formData["id"],
            name: _formData["name"],
            holderName: _formData["holderName"],
            kind: _formData["kind"],
          );
        }
        navigator.pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit account details failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter account details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: _submit, icon: Icon(Icons.check)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                decoration: InputStyles.field(
                  labelText: "Name",
                  hintText: "Enter account name...",
                ),
                initialValue: _formData["name"],
                onSaved: (value) => _formData["name"] = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                decoration: InputStyles.field(
                  labelText: "Holder",
                  hintText: "Enter holder name...",
                ),
                initialValue: _formData["holderName"],
                onSaved: (value) => _formData["holderName"] = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? "Holder is required"
                    : null,
              ),
              SelectFormField(
                initialValue: _formData["kind"],
                onSaved: (value) => _formData["kind"] = value,
                validator: (value) => value == null ? "Type is required" : null,
                options: AccountKind.values.map((v) {
                  return SelectItem(value: v, label: v.label);
                }).toList(),
                decoration: InputStyles.field(
                  labelText: "Type",
                  hintText: "Select account type...",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
