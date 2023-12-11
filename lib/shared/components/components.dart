import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget buildTaskItem(Map taskModel, context) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      children: [
        CircleAvatar(
          minRadius: 50.0,
          child: Text('${taskModel['time']}'),
        ),
        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${taskModel['title']}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${taskModel['date']}',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: ()
                {
                  AppCubit.get(context).updateData(status: 'done', id: taskModel['id']);
                  
                },
                icon: Icon(Icons.check),
                color: Colors.green,
            ),
            IconButton(
              onPressed: ()
              {
                AppCubit.get(context).updateData(status: 'archive', id: taskModel['id']);

              },
                icon: Icon(Icons.archive),
                color: Colors.black26,
            )
          ],
        ),
      ],
    ),
  );
}
