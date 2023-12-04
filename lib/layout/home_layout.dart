import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/constants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndexValue = 0;
  bool isBottomSheetShown = false;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  late Database database;

  List<Widget> bodyScreens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> appBarTitles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  @override
  void initState() {
    super.initState();

    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (isBottomSheetShown) {
              bool? formCurrentState = formKey.currentState?.validate();

              if ((formCurrentState != null) && (formCurrentState)) {
                insertToDatabase(
                  title: titleController.text,
                  date: dateController.text,
                  time: timeController.text,
                ).then((value) {
                  setState(() {
                    isBottomSheetShown = false;
                    Navigator.pop(context);
                  });
                });
              }
            } else {
              setState(() {
                isBottomSheetShown = true;
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
                      setState(() {
                        isBottomSheetShown = false;
                      });
                    });
              });
            }
          },
          child: (isBottomSheetShown) ? Icon(Icons.add) : Icon(Icons.edit)),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              currentIndexValue = value;
            });
          },
          currentIndex: currentIndexValue,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Done'),
            BottomNavigationBarItem(
                icon: Icon(Icons.archive), label: 'Archived')
          ]),
      appBar: AppBar(
        title: Text(appBarTitles[currentIndexValue]),
      ),
      body: ConditionalBuilder(
        condition: databaseRecords.length > 0,
        builder: (context) => bodyScreens[currentIndexValue],
        fallback: (context) => Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void createDatabase() async {
    database = await openDatabase('todo.db', version: 1,
        onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) => print('table created'))
          .catchError((error) =>
              print('Error when creating table ${error.toString()}'));
    }, onOpen: (database) {
      print('database opened');
      getDataFromDatabase(database).then((value) {
        print(databaseRecords);
      });
    });
  }

  Future insertToDatabase(
      {required String title,
      required String date,
      required String time}) async {
    return await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("${title}", "${date}", "${time}", "new")')
          .then((value) {
        print('${value.toString()} inserted successfully');
      }).catchError((error) {
        print('Error when Inserting New Record ${error.toString()}');
      });
    });
  }

  Future getDataFromDatabase(database) async {
    databaseRecords = await database.rawQuery('SELECT * FROM tasks');

    return databaseRecords;
  }
}
