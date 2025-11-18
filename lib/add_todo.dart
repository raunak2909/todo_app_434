import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_434/cubit/db_cubit.dart';
import 'package:todo_app_434/db_helper.dart';

class AddUpdateTodo extends StatelessWidget {
  bool isUpdate;
  int id;
  var titleController = TextEditingController();
  var descController = TextEditingController();
  String selectedPriority = "High";
  String  title, desc;
  String priority;
  DBHelper? dbHelper;
  List<String> priorities = ["Low", "Medium", "High"];

  AddUpdateTodo({
    this.isUpdate = false,
    this.id = 0,
    this.title = "",
    this.desc = "",
    this.priority = ""
});

  @override
  Widget build(BuildContext context) {

    dbHelper = DBHelper.getInstance();

    if(isUpdate){
      titleController.text = title;
      descController.text = desc;
      selectedPriority = priority;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${isUpdate ? 'Update' : 'Add'} Todo'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 11),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                hintText: 'Enter your title here',
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 11),
            TextField(
              maxLines: 4,
              controller: descController,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                labelText: 'Description',
                hintText: 'Enter your description here..',
              ),
            ),
            SizedBox(height: 11),
            StatefulBuilder(
              builder: (context, ss) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: priorities.map((priority) {
                    return RadioMenuButton(
                      value: priority,
                      groupValue: selectedPriority,
                      onChanged: (value) {
                        selectedPriority = value!;
                        ss(() {});
                      },
                      child: Text(priority),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    int priority;
                    if (selectedPriority == "Low") {
                      priority = 1;
                    } else if (selectedPriority == "Medium") {
                      priority = 2;
                    } else {
                      priority = 3;
                    }

                    bool isTaskDone = false;

                    if(isUpdate){
                      isTaskDone = await dbHelper!.updateTodo(
                          title: titleController.text,
                          desc: descController.text,
                          priority: priority,
                          id: id
                      );
                    } else {
                      /*isTaskDone = await dbHelper!.addTodo(
                        title: titleController.text,
                        desc: descController.text,
                        priority: priority,
                      );*/
                      context.read<DbCubit>().addTodo(title: titleController.text, desc: descController.text, priority: priority);
                      Navigator.pop(context);
                    }

                    if (isTaskDone) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 11),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
