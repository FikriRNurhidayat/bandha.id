import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditAccountScreen extends StatefulWidget {
  final Account? account;
  const EditAccountScreen({super.key, this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _id;
  String? _name;
  String? _holderName;
  AccountKind? _kind;

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      final account = widget.account!;
      _id = account.id;
      _name = account.name;
      _holderName = account.holderName;
      _kind = account.kind;
    }
  }

  void _submit() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final accountProvider = context.read<AccountProvider>();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Future(() async {
        if (_id == null) {
          await accountProvider.add(
            name: _name!,
            holderName: _holderName!,
            kind: _kind!,
          );
        } else {
          await accountProvider.update(
            id: _id!,
            name: _name!,
            holderName: _holderName!,
            kind: _kind!,
          );
        }
      }).then((_) => navigator.pop()).catchError((error) {
        print(error);
        messenger.showSnackBar(
          SnackBar(content: Text("Edit account details failed")),
        );
      });
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
                initialValue: _name,
                onSaved: (value) => _name = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                decoration: InputStyles.field(
                  labelText: "Holder",
                  hintText: "Enter holder name...",
                ),
                initialValue: _holderName,
                onSaved: (value) => _holderName = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? "Holder is required"
                    : null,
              ),
              SelectFormField(
                onSaved: (value) => _kind = value,
                initialValue: _kind,
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
