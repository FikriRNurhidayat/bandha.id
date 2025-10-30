import 'package:banda/entity/category.dart';
import 'package:banda/providers/category_provider.dart';
import 'package:banda/widgets/edit_item.dart';
import 'package:flutter/material.dart';

class CategoryEditView extends StatelessWidget {
  const CategoryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemableEdit<Category, CategoryProvider>(
      title: "Edit categories",
      deletePromptText: "Are you sure you want to delete this category?",
      deletePromptTitle: "Delete category",
      hintText: "Create new category",
    );
  }
}
