import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget buildTaskItem(Map taskModel, context) {
  return Dismissible(
    key: Key(taskModel['id'].toString()),
    onDismissed: (direction){
      AppCubit.get(context).deleteData(id: taskModel['id']);
    },
    child: Padding(
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
    ),
  );
}

Widget buildTasksList ({required List<Map> tasks}) {

  return ConditionalBuilder(
    condition: tasks.length > 0,
    builder: (BuildContext context) {
      return ListView.separated(
        itemBuilder: (context, index) =>
            buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Divider(thickness: 1.5),
        itemCount: tasks.length,
      );
    },
    fallback: (BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            Icon(Icons.menu,size: 100.0, color: Colors.grey,),
            Text('No Tasks Yet, Please Add Some Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.grey),),
          ],
        ),
      );
    },

  );

}
