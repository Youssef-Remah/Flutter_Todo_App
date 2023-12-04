import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(databaseRecords[index]),
      separatorBuilder: (context, index) => Divider(thickness: 1.5),
      itemCount: databaseRecords.length,
    );
  }
}
