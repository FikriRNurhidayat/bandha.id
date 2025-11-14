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
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillEditView extends StatefulWidget {
  final Bill? bill;
  const BillEditView({super.key, this.bill});

  @override
  State<BillEditView> createState() => _BillEditViewState();
}

class _BillEditViewState extends State<BillEditView> {
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();

    if (widget.bill != null) {
      _data = widget.bill!.toMap();
      _data["billedAt"] = When(WhenOption.specific, _data["billedAt"]);
    }
  }

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final billProvider = context.read<BillProvider>();

    try {
      if (_form.currentState!.validate()) {
        if (_data["id"] == null) {
          await billProvider.create(
            note: _data["note"],
            amount: _data["amount"],
            cycle: _data["cycle"],
            status: _data["status"],
            categoryId: _data["categoryId"],
            accountId: _data["accountId"],
            billedAt: _data["billedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }

        if (_data["id"] != null) {
          await billProvider.update(
            id: _data["id"],
            note: _data["note"],
            amount: _data["amount"],
            cycle: _data["cycle"],
            status: _data["status"],
            categoryId: _data["categoryId"],
            accountId: _data["accountId"],
            billedAt: _data["billedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }
        navigator.pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit bill details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _form.currentState!.save();
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
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      initialValue: _data["note"],
                      decoration: InputStyles.field(
                        hintText: "Enter note...",
                        labelText: "Note",
                      ),
                      onSaved: (value) => _data["note"] = value,
                      validator: (value) =>
                          value == null ? "Note is required" : null,
                    ),
                    AmountFormField(
                      initialValue: _data["amount"],
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      onSaved: (value) => _data["amount"] = value,
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    SelectFormField<BillCycle>(
                      onSaved: (value) => _data["cycle"] = value,
                      initialValue: _data["cycle"] ?? BillCycle.oneTime,
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
                      onSaved: (value) => _data["status"] = value,
                      initialValue: _data["status"] ?? BillStatus.active,
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
                    WhenFormField(
                      options: WhenOption.min,
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
                      initialValue: _data["billedAt"],
                      onSaved: (value) => _data["billedAt"] = value,
                      validator: (value) => value == null
                          ? "Billing timestamp is required"
                          : null,
                    ),
                    SelectFormField<String>(
                      initialValue: _data["categoryId"],
                      onSaved: (value) => _data["categoryId"] = value,
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
                      initialValue: _data["accountId"],
                      onSaved: (value) => _data["accountId"] = value,
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
                      initialValue: _data["labelIds"] ?? [],
                      onSaved: (value) => _data["labelIds"] = value,
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
