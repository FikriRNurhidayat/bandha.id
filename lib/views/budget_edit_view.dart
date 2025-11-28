import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/budget.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/types/form_data.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetEditView extends StatefulWidget {
  final String? id;
  final bool readOnly;
  const BudgetEditView({super.key, this.id, this.readOnly = false});

  @override
  State<BudgetEditView> createState() => _BudgetEditViewState();
}

class _BudgetEditViewState extends State<BudgetEditView> {
  final _form = GlobalKey<FormState>();
  final FormData _d = {};

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final budgetProvider = context.read<BudgetProvider>();

    try {
      if (_form.currentState!.validate()) {
        if (widget.id == null) {
          await budgetProvider.create(
            note: _d["note"],
            limit: _d["limit"],
            cycle: _d["cycle"],
            categoryId: _d["categoryId"],
            issuedAt: _d["issuedAt"].dateTime,
            labelIds: _d["labelIds"],
          );
        }

        if (widget.id != null) {
          await budgetProvider.update(
            id: widget.id!,
            note: _d["note"],
            limit: _d["limit"],
            cycle: _d["cycle"],
            categoryId: _d["categoryId"],
            issuedAt: _d["issuedAt"].dateTime,
            labelIds: _d["labelIds"],
          );
        }

        navigator.pop();
      } else {
        messenger.showSnackBar(SnackBar(content: Text("Validation Error")));
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text("Edit budget details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _form.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  validateExpires(DateTime? value) {
    if (_d["cycle"] != BudgetCycle.indefinite && value == null) {
      return "Expiration date & time is required";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetProvider = context.read<BudgetProvider>();
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
          "Enter budget details",
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
              categoryProvider.search(),
              labelProvider.search(),
              if (widget.id != null) budgetProvider.get(widget.id!),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data![0] as List<Category>;
              final labels = snapshot.data![1] as List<Label>;
              final budget = widget.id != null
                  ? snapshot.data![2] as Budget
                  : null;

              return Form(
                key: _form,
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      initialValue: _d["note"] ?? budget?.note,
                      decoration: InputStyles.field(
                        hintText: "Enter note...",
                        labelText: "Note",
                      ),
                      onSaved: (value) => _d["note"] = value,
                      validator: (value) =>
                          value == null ? "Note is required" : null,
                    ),
                    AmountFormField(
                      initialValue: _d["limit"] ?? budget?.limit,
                      decoration: InputStyles.field(
                        hintText: "Enter limit...",
                        labelText: "Limit",
                      ),
                      onSaved: (value) => _d["limit"] = value,
                      validator: (value) =>
                          value == null ? "Limit is required" : null,
                    ),
                    SelectFormField<BudgetCycle>(
                      onSaved: (value) => _d["cycle"] = value,
                      onChanged: (value) => _d["cycle"] = value,
                      initialValue:
                          _d["cycle"] ??
                          budget?.cycle ??
                          BudgetCycle.indefinite,
                      validator: (value) =>
                          value == null ? "Cycle is required" : null,
                      options: BudgetCycle.values.map((v) {
                        return SelectItem(value: v, label: v.label);
                      }).toList(),
                      decoration: InputStyles.field(
                        labelText: "Cycle",
                        hintText: "Select budgeting cycle...",
                      ),
                    ),
                    WhenFormField(
                      options: WhenOption.min,
                      decoration: InputStyles.field(
                        labelText: "Date & Time",
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
                          _d["issuedAt"] ??
                          (budget?.issuedAt != null
                              ? When.fromDateTime(budget!.issuedAt)
                              : When.now()),
                      onSaved: (value) => _d["issuedAt"] = value,
                    ),
                    SelectFormField<String>(
                      initialValue: _d["categoryId"] ?? budget?.categoryId,
                      onSaved: (value) => _d["categoryId"] = value,
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
                    MultiSelectFormField<String>(
                      initialValue: _d["labelIds"] ?? budget?.labelIds ?? [],
                      onSaved: (value) => _d["labelIds"] = value,
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
