import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/bill.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillEditView extends StatefulWidget {
  final Bill? bill;
  const BillEditView({super.key, this.bill});

  @override
  State<BillEditView> createState() => _BillEditViewState();
}

class _BillEditViewState extends State<BillEditView> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.bill != null) {
      _formData = widget.bill!.toMap();
    }
  }

  void _submit() async {
    _formKey.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final billProvider = context.read<BillProvider>();

    try {
      if (_formKey.currentState!.validate()) {
        if (_formData["id"] == null) {
          await billProvider.create(
            note: _formData["note"],
            amount: _formData["amount"],
            cycle: _formData["cycle"],
            status: _formData["status"],
            categoryId: _formData["categoryId"],
            accountId: _formData["accountId"],
            billedAt: _formData["billedAt"],
            labelIds: _formData["labelIds"],
          );
        }

        if (_formData["id"] != null) {
          await billProvider.update(
            id: _formData["id"],
            note: _formData["note"],
            amount: _formData["amount"],
            cycle: _formData["cycle"],
            status: _formData["status"],
            categoryId: _formData["categoryId"],
            accountId: _formData["accountId"],
            billedAt: _formData["billedAt"],
            labelIds: _formData["labelIds"],
          );
        }
        navigator.pop();
      }
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      messenger.showSnackBar(
        SnackBar(content: Text("Edit bill details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _formKey.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final labelProvider = context.watch<LabelProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Enter bill details",
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
              categoryProvider.search(),
              labelProvider.search(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final [
                accounts as List<Account>,
                categories as List<Category>,
                labels as List<Label>,
              ] = snapshot.data!;

              return Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      initialValue: _formData["note"],
                      decoration: InputStyles.field(
                        hintText: "Enter note...",
                        labelText: "Note",
                      ),
                      onSaved: (value) => _formData["note"] = value,
                      validator: (value) =>
                          value == null ? "Note is required" : null,
                    ),
                    AmountFormField(
                      initialValue: _formData["amount"],
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      onSaved: (value) => _formData["amount"] = value,
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    SelectFormField<BillCycle>(
                      onSaved: (value) => _formData["cycle"] = value,
                      initialValue: _formData["cycle"] ?? BillCycle.oneTime,
                      validator: (value) =>
                          value == null ? "Cycle is required" : null,
                      options: BillCycle.values.map((v) {
                        return SelectItem(value: v, label: v.label);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Cycle",
                        hintText: "Select billing cycle...",
                      ),
                    ),
                    SelectFormField<BillStatus>(
                      onSaved: (value) => _formData["status"] = value,
                      initialValue: _formData["status"] ?? BillStatus.active,
                      validator: (value) =>
                          value == null ? "Status is required" : null,
                      options: BillStatus.values.map((v) {
                        return SelectItem(value: v, label: v.label);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Status",
                        hintText: "Select status type...",
                      ),
                    ),
                    TimestampFormField(
                      decoration: InputStyles.field(
                        labelText: "Billed at",
                        hintText: "Select billing date & time...",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Billing date",
                        hintText: "Select billing date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Billing time",
                        hintText: "Select billing time...",
                      ),
                      initialValue: _formData["billedAt"],
                      onSaved: (value) => _formData["billedAt"] = value,
                      validator: (value) => value == null
                          ? "Billing timestamp is required"
                          : null,
                    ),
                    SelectFormField<String>(
                      initialValue: _formData["categoryId"],
                      onSaved: (value) => _formData["categoryId"] = value,
                      validator: (value) =>
                          value == null ? "Category is required" : null,
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New category",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            redirect((_) => CategoryEditView());
                          },
                        ),
                      ],
                      options: categories
                          .where((category) => !category.readonly)
                          .map((category) {
                            return SelectItem(
                              value: category.id,
                              label: category.name,
                            );
                          })
                          .toList(),
                      decoration: InputStyles.field(
                        labelText: "Category",
                        hintText: "Select category...",
                      ),
                    ),
                    SelectFormField<String>(
                      initialValue: _formData["accountId"],
                      onSaved: (value) => _formData["accountId"] = value,
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
                        labelText: "Account",
                        hintText: "Select account...",
                      ),
                    ),
                    MultiSelectFormField<String>(
                      initialValue: _formData["labelIds"] ?? [],
                      onSaved: (value) => _formData["labelIds"] = value,
                      actions: [
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            color: theme.colorScheme.outline,
                          ),
                          label: Text(
                            "New labels",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          onPressed: () {
                            redirect((_) => LabelEditView());
                          },
                        ),
                      ],
                      options: labels.map((label) {
                        return MultiSelectItem(
                          value: label.id,
                          label: label.name,
                        );
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Labels",
                        hintText: "Select labels...",
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
