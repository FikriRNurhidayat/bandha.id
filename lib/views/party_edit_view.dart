import 'package:banda/entity/party.dart';
import 'package:banda/providers/party_provider.dart';
import 'package:banda/widgets/edit_item.dart';
import 'package:flutter/material.dart';

class PartyEditView extends StatelessWidget {
  const PartyEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemableEdit<Party, PartyProvider>(
      title: "Edit parties",
      deletePromptText: "Are you sure you want to delete this party?",
      deletePromptTitle: "Delete party",
      hintText: "Create new party",
      tileIcon: Icons.person,
    );
  }
}
