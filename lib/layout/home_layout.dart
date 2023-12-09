import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit c = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (c.isBottomSheetShown) {
                    bool? formCurrentState = formKey.currentState?.validate();

                    if ((formCurrentState != null) && (formCurrentState)) {
                      c.insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text,
                      );
                    }
                  } else {
                    c.changeBottomSheetState(isShow: true);
                    scaffoldKey.currentState
                        ?.showBottomSheet((BuildContext context) {
                          return Container(
                            color: Colors.grey[200],
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: titleController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        prefixIcon: Icon(Icons.text_fields),
                                        labelText: 'Task Title',
                                      ),
                                      validator: (String? titleValue) {
                                        if (titleValue != null &&
                                            titleValue.isEmpty) {
                                          return 'Title must not be empty';
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value!.format(context);
                                        });
                                      },
                                      keyboardType: TextInputType.datetime,
                                      controller: timeController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        prefixIcon:
                                            Icon(Icons.watch_later_outlined),
                                        labelText: 'Task Time',
                                      ),
                                      validator: (String? titleValue) {
                                        if (titleValue != null &&
                                            titleValue.isEmpty) {
                                          return 'Time must not be empty';
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2024, 11, 30),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        });
                                      },
                                      keyboardType: TextInputType.datetime,
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        prefixIcon:
                                            Icon(Icons.calendar_month_outlined),
                                        labelText: 'Task Date',
                                      ),
                                      validator: (String? titleValue) {
                                        if (titleValue != null &&
                                            titleValue.isEmpty) {
                                          return 'Date must not be empty';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .closed
                        .then((value) {
                          c.changeBottomSheetState(isShow: false);
                        });
                  }
                },
                child: (c.isBottomSheetShown)
                    ? Icon(Icons.add)
                    : Icon(Icons.edit)),
            bottomNavigationBar: BottomNavigationBar(
                onTap: (value) {
                  c.changeIndex(value);
                },
                currentIndex: c.currentIndexValue,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.check,
                      ),
                      label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.archive,
                      ),
                      label: 'Archived')
                ]),
            appBar: AppBar(
              title: Text(c.appBarTitles[c.currentIndexValue]),
            ),
            body: ConditionalBuilder(
              condition: true,
              builder: (context) => c.bodyScreens[c.currentIndexValue],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
