import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/entity/bill.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/types/form_data.dart';
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
  final String? id;
  final bool readOnly;

  const BillEditView({super.key, this.id, this.readOnly = false});

  @override
  State<BillEditView> createState() => _BillEditViewState();
}

class _BillEditViewState extends State<BillEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void handleSubmit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final billProvider = context.read<BillProvider>();

    try {
      if (_form.currentState!.validate()) {
        if (widget.id == null) {
          await billProvider.create(
            note: _d["note"],
            amount: _d["amount"],
            cycle: _d["cycle"],
            status: _d["status"],
            categoryId: _d["categoryId"],
            accountId: _d["accountId"],
            billedAt: _d["billedAt"].dateTime,
            labelIds: _d["labelIds"],
          );
        } else {
          await billProvider.update(
            id: widget.id!,
            note: _d["note"],
            amount: _d["amount"],
            cycle: _d["cycle"],
            status: _d["status"],
            categoryId: _d["categoryId"],
            accountId: _d["accountId"],
            billedAt: _d["billedAt"].dateTime,
            labelIds: _d["labelIds"],
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

  void handleMoreTap(BuildContext context) async {
    Navigator.pushNamed(context, "/bills/${widget.id!}/menu");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billProvider = context.read<BillProvider>();
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
        title: Text(
          !widget.readOnly ? "Enter bill details" : "Bill details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  handleSubmit();
                },
                icon: Icon(Icons.check),
              ),
            ),
          if (widget.readOnly)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  handleMoreTap(context);
                },
                icon: Icon(Icons.more_horiz),
              ),
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
              if (widget.id != null) billProvider.get(widget.id!),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts = snapshot.data![0] as List<Account>;
              final categories = snapshot.data![1] as List<Category>;
              final labels = snapshot.data![2] as List<Label>;
              final bill = widget.id != null
                  ? (snapshot.data![3] as Bill)
                  : null;

              return Form(
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      readOnly: widget.readOnly,
                      initialValue: _d["note"] ?? bill?.note,
                      decoration: InputStyles.field(
                        hintText: "Enter note...",
                        labelText: "Note",
                      ),
                      onSaved: (value) => _d["note"] = value,
                      validator: (value) =>
                          value == null ? "Note is required" : null,
                    ),
                    AmountFormField(
                      readOnly: widget.readOnly,
                      initialValue: _d["amount"] ?? bill?.amount,
                      decoration: InputStyles.field(
                        hintText: "Enter amount...",
                        labelText: "Amount",
                      ),
                      onSaved: (value) => _d["amount"] = value,
                      validator: (value) =>
                          value == null ? "Amount is required" : null,
                    ),
                    SelectFormField<BillCycle>(
                      readOnly: widget.readOnly,
                      onSaved: (value) => _d["cycle"] = value,
                      initialValue:
                          _d["cycle"] ?? bill?.cycle ?? BillCycle.oneTime,
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
                      readOnly: widget.readOnly,
                      onSaved: (value) => _d["status"] = value,
                      initialValue:
                          _d["status"] ?? bill?.status ?? BillStatus.active,
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
                      readOnly: widget.readOnly,
                      options: WhenOption.min,
                      decoration: InputStyles.field(
                        labelText: "Billed",
                        hintText: "Select date & time...",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Date",
                        hintText: "Select date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Time",
                        hintText: "Select time...",
                      ),
                      initialValue:
                          _d["billedAt"] ??
                          (bill?.billedAt != null
                              ? When.fromDateTime(bill!.billedAt)
                              : When.now()),
                      onSaved: (value) => _d["billedAt"] = value,
                      validator: (value) =>
                          value == null ? "Timestamp is required" : null,
                    ),
                    SelectFormField<String>(
                      readOnly: widget.readOnly,
                      initialValue: _d["categoryId"] ?? bill?.categoryId,
                      onSaved: (value) => _d["categoryId"] = value,
                      validator: (value) =>
                          value == null ? "Category is required" : null,
                      actions: [
                        if (!widget.readOnly)
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
                      readOnly: widget.readOnly,
                      initialValue: _d["accountId"] ?? bill?.accountId,
                      onSaved: (value) => _d["accountId"] = value,
                      validator: (value) =>
                          value == null ? "Account is required" : null,
                      actions: [
                        if (!widget.readOnly)
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
                      readOnly: widget.readOnly,
                      initialValue: _d["labelIds"] ?? bill?.labelIds ?? [],
                      onSaved: (value) => _d["labelIds"] = value,
                      actions: [
                        if (!widget.readOnly)
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
