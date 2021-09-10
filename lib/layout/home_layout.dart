import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';

class HomeLayout extends StatefulWidget {

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
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
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  TextEditingController titleController = new TextEditingController();
  TextEditingController timeController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:scaffoldKey,
      appBar: AppBar(
        title: Text(currentTitle[currentIndex]),
      ),

      body:ConditionalBuilder(
        condition: tasks.length > 0,
        builder: (context)=>currentScreen[currentIndex],
        fallback: (context) => Center(child: CircularProgressIndicator()),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShown){
            if (formKey.currentState.validate())
              {
                insertToDatabase(
                    title: titleController.text,
                    date: dateController.text,
                    time: timeController.text)
                    .then((value) {


                      getDataFromDatabase(database).then((value) {
                        Navigator.pop(context);
                        setState(() {
                          isBottomSheetShown = false;
                          fabIcon = Icons.edit;
                          tasks = value;
                          print (tasks);
                        });
                      });


                      timeController.clear();
                      dateController.clear();
                      titleController.clear();
                });
              }
          }
          else {
            scaffoldKey.currentState.showBottomSheet(
                    (context) =>
                        Container(
                      padding: EdgeInsets.all(20.0),
                      color: Colors.white,
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                                prefix: Icon(Icons.title),
                                controller: titleController,
                                label: 'Task Title',
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "title must not be empty";
                                  }
                                  return null;
                                },
                                type: TextInputType.text
                            ),

                            SizedBox(height: 15.0,),

                            defaultFormField(
                                prefix: Icon(Icons.watch_later_outlined),
                                controller: timeController,
                                label: 'Task Time',
                                onTap: ()
                                {
                                  showTimePicker(context: context,
                                      initialTime: TimeOfDay.now(),
                                  ).then((value){
                                    timeController.text = value.format(context).toString();
                                  });
                                },
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "time must not be empty";
                                  }
                                  return null;
                                },
                                type: TextInputType.text
                            ),

                            SizedBox(height: 15.0,),

                            defaultFormField(
                                prefix: Icon(Icons.calendar_today),
                                controller: dateController,
                                label: 'Task Date',
                                onTap: ()
                                {
                                  showDatePicker(context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2050))
                                      .then((value){
                                        dateController.text = DateFormat.yMMMd().format(value);
                                  });
                                },
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return "date must not be empty";
                                  }
                                  return null;
                                },
                                type: TextInputType.text
                            )
                          ],
                        ),
                      ),
                    ),
              elevation: 20.0,
            ).closed.then((value) {
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
            setState(() {
              fabIcon = Icons.add;
            });
            isBottomSheetShown = true;
          }
        },
        child: Icon(fabIcon),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index)
        {
          setState(() {
            currentIndex = index;
          });

        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu),
            label: "Tasks"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.done_outline_rounded),
              label: "Done"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              label: "Archive"
          ),
        ],
      ),
    );
  }

  void createDatabase() async{
    database = await openDatabase(
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
          setState(() {
            tasks = value;
            print (tasks);
          });
        });
        print("Database opened");
    },
    );
  }

  Future insertToDatabase({
  @required String title,@required String date,@required String time,
  }) async {
    return await database.transaction((txn) {
      txn.rawInsert('INSERT INTO tasks (title, date, time, status) VALUES ("$title", "$date" , "$time" , "new")')
          .then((value) {
            print ("$value inserted successfully");
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

}
