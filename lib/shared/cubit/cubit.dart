import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndexValue = 0;

  bool isBottomSheetShown = false;

  late Database database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> bodyScreens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> appBarTitles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    currentIndexValue = index;

    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) => print('table created'))
          .catchError((error) =>
              print('Error when creating table ${error.toString()}'));
    }, onOpen: (database) {
      print('database opened');
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase(
      {required String title,
      required String date,
      required String time}) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("${title}", "${date}", "${time}", "new")')
          .then((value) {
        emit(AppInsertDatabaseState());
        print('${value.toString()} inserted successfully');

        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error when Inserting New Record ${error.toString()}');
      });
    });
  }

  void updateData({required String status, required int id}) {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['${status}', id]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void getDataFromDatabase(database) {

    database.rawQuery('SELECT * FROM tasks').then((value) {

      newTasks = [];
      doneTasks = [];
      archivedTasks = [];

      value.forEach(
        (element)
          {
            if(element['status'] == 'done')
              doneTasks.add(element);

            else if(element['status'] == 'new')
              newTasks.add(element);

            else
              archivedTasks.add(element);
          }
      );

      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({required bool isShow}) {
    isBottomSheetShown = isShow;

    emit(AppChangeBottomSheetState());
  }
}
