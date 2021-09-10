import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get (context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<String> currentTitle = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks"
  ];

  List<Widget> currentScreen = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  Database database;
  List<Map> tasks = [];

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeIndex (int index)
  {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version){

        print("Database created");

        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value) {
          print ('table created');
        }).catchError((error){
          print ('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database){
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print (tasks);
          emit(AppGetDatabaseState());
        });
        print("Database opened");
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future insertToDatabase({
    @required String title,@required String date,@required String time,
  }) async {
    return await database.transaction((txn) {
      txn.rawInsert('INSERT INTO tasks (title, date, time, status) VALUES ("$title", "$date" , "$time" , "new")')
          .then((value) {
        print ("$value inserted successfully");
        emit(AppInsertDatabaseState());
      }).catchError((error){
        print ('Error While Inserting New Record ${error.toString()}');
      });

      return null;
    });
  }


  Future<List<Map>> getDataFromDatabase (database) async
  {
    return await database.rawQuery('SELECT * FROM tasks');
  }

  void changeBottomSheetState (
      {@required bool isShown, @required IconData icon})
  {
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

}