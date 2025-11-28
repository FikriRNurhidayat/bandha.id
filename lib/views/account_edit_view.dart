import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountEditView extends StatefulWidget {
  final String? id;
  final bool readOnly;

  const AccountEditView({super.key, this.id, this.readOnly = false});

  @override
  State<AccountEditView> createState() => _AccountEditViewState();
}

class _AccountEditViewState extends State<AccountEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void _submit() async {
    final accountProvider = context.read<AccountProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_form.currentState!.validate()) {
        _form.currentState!.save();

        if (widget.id == null) {
          await accountProvider.create(
            name: _d["name"],
            holderName: _d["holderName"],
            kind: _d["kind"],
          );
        } else {
          await accountProvider.update(
            id: widget.id!,
            name: _d["name"],
            holderName: _d["holderName"],
            kind: _d["kind"],
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
    final accountProvider = context.read<AccountProvider>();

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
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: _submit, icon: Icon(Icons.check)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          if (widget.id != null) accountProvider.get(widget.id!),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("..."));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = widget.id != null
              ? snapshot.data![0] as Account
              : null;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                spacing: 16,
                children: [
                  TextFormField(
                    decoration: InputStyles.field(
                      labelText: "Name",
                      hintText: "Enter account name...",
                    ),
                    initialValue: _d["name"] ?? account?.name,
                    onSaved: (value) => _d["name"] = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? "Name is required"
                        : null,
                  ),
                  TextFormField(
                    decoration: InputStyles.field(
                      labelText: "Holder",
                      hintText: "Enter holder name...",
                    ),
                    initialValue: _d["holderName"] ?? account?.holderName,
                    onSaved: (value) => _d["holderName"] = value ?? '',
                    validator: (value) => value == null || value.isEmpty
                        ? "Holder is required"
                        : null,
                  ),
                  SelectFormField(
                    initialValue: _d["kind"] ?? account?.kind,
                    onSaved: (value) => _d["kind"] = value,
                    validator: (value) =>
                        value == null ? "Type is required" : null,
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
          );
        },
      ),
    );
  }
}
