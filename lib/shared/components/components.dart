import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChange,
  Function onTap,
  bool isClickable = true,
  @required Function validator,
  @required String label,
  @required Icon prefix,
})
{

  return TextFormField(
    controller: controller,
    keyboardType: type,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
    validator: validator,
    onTap: onTap,
    enabled: isClickable,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: prefix,
      border: OutlineInputBorder()
    ),
  );
}


Widget buildTaskItem(Map model, context)
=>Padding(
  padding: const EdgeInsets.all(20.0),
  child: Slidable(
    actionPane: SlidableDrawerActionPane(),
    actionExtentRatio: 0.5,
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text(
            "${model['time']}",
          ),
        ),

        SizedBox(
          width: 20.0,
        ),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${model['title']}",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                ),
              ),

              Text(
                "${model['date']}",
                style: TextStyle(
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 20.0,
        ),

        IconButton(
          icon:Icon(Icons.check_box, color: Colors.green,),
          onPressed: (){
            AppCubit.get(context).updateData(status: "done", id: model['id']);
            },
        ),

        IconButton(
          icon:Icon(Icons.archive, color: Colors.black54,),
          onPressed: (){
            AppCubit.get(context).updateData(status: "archive", id: model['id']);
          },
        ),
      ],
    ),

    secondaryActions: <Widget> [
      IconSlideAction(
        caption: "Delete",
        icon: Icons.delete_rounded,
        onTap: (){
          AppCubit.get(context).deleteFromData(id: model['id']);
        },
        color: Colors.red,
      )
    ],
  ),
);



Widget taskBuilder({@required tasks})
{
  return ConditionalBuilder(
    condition: tasks.length>0,

    builder: (context)=> ListView.separated(
        itemBuilder: (context,index)=>buildTaskItem(tasks[index], context),
        separatorBuilder: (context,index)=>Divider(height: 1.0,),
        itemCount: tasks.length
    ),

    fallback:(context)=> Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 100.0,
            color: Colors.grey,
          ),
          Text(
            "No Tasks Yet, Please Add Some Tasks",
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey
            ),
          )
        ],
      ),
    ),
  );
}