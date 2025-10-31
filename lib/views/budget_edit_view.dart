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
import 'package:banda/widgets/timestamp_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetEditView extends StatefulWidget {
  final Budget? budget;
  const BudgetEditView({super.key, this.budget});

  @override
  State<BudgetEditView> createState() => _BudgetEditViewState();
}

class _BudgetEditViewState extends State<BudgetEditView> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _formData = widget.budget!.toMap();
    }
  }

  void _submit() async {
    _formKey.currentState!.save();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final budgetProvider = context.read<BudgetProvider>();

    try {
      if (_formKey.currentState!.validate()) {
        if (_formData["id"] == null) {
          await budgetProvider.create(
            note: _formData["note"],
            limit: _formData["limit"],
            cycle: _formData["cycle"],
            categoryId: _formData["categoryId"],
            expiredAt: _formData["expiredAt"],
            labelIds: _formData["labelIds"],
          );
        }

        if (_formData["id"] != null) {
          await budgetProvider.update(
            id: _formData["id"],
            note: _formData["note"],
            limit: _formData["limit"],
            cycle: _formData["cycle"],
            categoryId: _formData["categoryId"],
            expiredAt: _formData["expiredAt"],
            labelIds: _formData["labelIds"],
          );
        }
        navigator.pop();
      }
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);

      messenger.showSnackBar(
        SnackBar(content: Text("Edit budget details failed")),
      );
    }
  }

  redirect(WidgetBuilder builder) {
    _formKey.currentState!.save();
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  validateExpires(DateTime? value) {
    if (_formData["cycle"] != BudgetCycle.indefinite && value == null) {
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
                      initialValue: _formData["limit"],
                      decoration: InputStyles.field(
                        hintText: "Enter limit...",
                        labelText: "Limit",
                      ),
                      onSaved: (value) => _formData["limit"] = value,
                      validator: (value) =>
                          value == null ? "Limit is required" : null,
                    ),
                    SelectFormField<BudgetCycle>(
                      onSaved: (value) => _formData["cycle"] = value,
                      onChanged: (value) => _formData["cycle"] = value,
                      initialValue:
                          _formData["cycle"] ?? BudgetCycle.indefinite,
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
                    TimestampFormField(
                      decoration: InputStyles.field(
                        labelText: "Expires at",
                        hintText: "Select expiration date & time...",
                      ),
                      dateInputDecoration: InputStyles.field(
                        labelText: "Expiration date",
                        hintText: "Select expiration date...",
                      ),
                      timeInputDecoration: InputStyles.field(
                        labelText: "Expiration time",
                        hintText: "Select expiration time...",
                      ),
                      initialValue: _formData["expiredAt"],
                      onSaved: (value) => _formData["expiredAt"] = value,
                      validator: (value) => validateExpires(value),
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
