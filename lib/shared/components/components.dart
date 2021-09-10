import 'package:flutter/material.dart';

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


Widget buildTaskItem(Map model)
=>Padding(
  padding: const EdgeInsets.all(20.0),
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
      Column(
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
      )
    ],
  ),
);