import 'package:flutter/material.dart';

Widget buildTaskItem(Map taskModel) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      children: [
        CircleAvatar(
          child: Text('${taskModel['time']}'),
          minRadius: 50.0,
        ),
        SizedBox(
          width: 15.0,
        ),
        Column(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
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
        )
      ],
    ),
  );
}
