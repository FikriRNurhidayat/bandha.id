import 'package:banda/entity/label.dart';
import 'package:banda/providers/label_provider.dart';
import 'package:banda/widgets/edit_item.dart';
import 'package:flutter/material.dart';

class LabelEditView extends StatelessWidget {
  const LabelEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemableEdit<Label, LabelProvider>(
      title: "Edit labels",
      deletePromptText: "Are you sure you want to delete this label?",
      deletePromptTitle: "Delete label",
      hintText: "Create new label",
    );
  }
}
