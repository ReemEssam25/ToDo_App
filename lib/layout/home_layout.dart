import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController timeController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state){},
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key:scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.currentTitle[cubit.currentIndex]),
            ),

            body:ConditionalBuilder(
              condition: true,
              builder: (context)=>cubit.currentScreen[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown){
                  if (formKey.currentState.validate())
                  {
                    // insertToDatabase(
                    //     title: titleController.text,
                    //     date: dateController.text,
                    //     time: timeController.text)
                    //     .then((value) {
                    //
                    //
                    //   getDataFromDatabase(database).then((value) {
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //   isBottomSheetShown = false;
                    //     //   fabIcon = Icons.edit;
                    //     //   tasks = value;
                    //     //   print (tasks);
                    //     // });
                    //   });
                    //
                    //
                    //   timeController.clear();
                    //
                    //   dateController.clear();
                    //   titleController.clear();
                    // });
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
                    cubit.changeBottomSheetState(isShown: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShown: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),

            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
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
        },

      ),
    );
  }



}


