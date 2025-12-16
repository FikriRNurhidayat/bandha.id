import 'package:banda/features/tags/entities/category.dart';
import 'package:banda/features/tags/layouts/tagable_selector.dart';
import 'package:banda/features/tags/providers/category_provider.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return TagableSelector<Category, CategoryProvider>(
      title: "Edit categories",
      deletePromptText: "Are you sure you want to delete this category?",
      deletePromptTitle: "Delete category",
      hintText: "Create new category",
    );
  }
}
