import 'package:banda/decorations/input_styles.dart';
import 'package:banda/entity/budget.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/views/category_edit_view.dart';
import 'package:banda/views/label_edit_view.dart';
import 'package:banda/widgets/amount_form_field.dart';
import 'package:banda/widgets/multi_select_form_field.dart';
import 'package:banda/widgets/select_form_field.dart';
import 'package:banda/widgets/when_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetEditView extends StatefulWidget {
  final Budget? budget;
  const BudgetEditView({super.key, this.budget});

  @override
  State<BudgetEditView> createState() => _BudgetEditViewState();
}

class _BudgetEditViewState extends State<BudgetEditView> {
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _data = widget.budget!.toMap();
      _data["issuedAt"] = When.fromDateTime(_data["issuedAt"]);
    }
  }

  void _submit() async {
    _form.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final budgetProvider = context.read<BudgetProvider>();

    try {
      if (_form.currentState!.validate()) {
        if (_data["id"] == null) {
          await budgetProvider.create(
            note: _data["note"],
            limit: _data["limit"],
            cycle: _data["cycle"],
            categoryId: _data["categoryId"],
            issuedAt: _data["issuedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }

        if (_data["id"] != null) {
          await budgetProvider.update(
            id: _data["id"],
            note: _data["note"],
            limit: _data["limit"],
            cycle: _data["cycle"],
            categoryId: _data["categoryId"],
            issuedAt: _data["issuedAt"].dateTime,
            labelIds: _data["labelIds"],
          );
        }
        navigator.pop();
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
    if (_data["cycle"] != BudgetCycle.indefinite && value == null) {
      return "Expiration date & time is required";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final [categories as List<Category>, labels as List<Label>] =
                  snapshot.data!;

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
                      initialValue: _data["limit"],
                      decoration: InputStyles.field(
                        hintText: "Enter limit...",
                        labelText: "Limit",
                      ),
                      onSaved: (value) => _data["limit"] = value,
                      validator: (value) =>
                          value == null ? "Limit is required" : null,
                    ),
                    SelectFormField<BudgetCycle>(
                      onSaved: (value) => _data["cycle"] = value,
                      onChanged: (value) => _data["cycle"] = value,
                      initialValue: _data["cycle"] ?? BudgetCycle.indefinite,
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
                      initialValue: _data["issuedAt"],
                      onSaved: (value) => _data["issuedAt"] = value,
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
