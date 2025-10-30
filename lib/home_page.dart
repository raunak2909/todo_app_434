import 'package:flutter/material.dart';
import 'package:todo_app_434/db_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> mTodo = [];
  DBHelper? dbHelper;
  var titleController = TextEditingController();
  var descController = TextEditingController();
  String selectedPriority = "High";

  ///1. update todo using bottomSheet
  ///2. delete todo
  ///3. filter todo's on the basis on completed/pending/all
  ///4. filter todo's on the basis on priority low/medium/high

  List<String> priorities = ["Low", "Medium", "High"];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper.getInstance();
    loadData();
  }

  loadData() async {
    mTodo = await dbHelper!.getAllTodo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: mTodo.isNotEmpty
          ? ListView.builder(
              itemCount: mTodo.length,
              itemBuilder: (_, index) {
                Color bgColor = Colors.white;

                if(mTodo[index][DBHelper.columnTodoPriority]==1){
                  bgColor = Colors.blue.shade200;
                } else if(mTodo[index][DBHelper.columnTodoPriority]==2){
                  bgColor = Colors.orange.shade200;
                } else {
                  bgColor = Colors.red.shade200;
                }


                return Card(
                  color: bgColor,
                  child: ListTile(
                    leading: Checkbox(
                      value: mTodo[index][DBHelper.columnTodoIsCompleted] == 1,
                      onChanged: (value) async {
                        bool isUpdated = await dbHelper!.completeTodo(
                          id: mTodo[index][DBHelper.columnTodoId],
                          isComplete: value ?? false,
                        );

                        if (isUpdated) {
                          loadData();
                        }
                      },
                    ),
                    title: Text(
                      mTodo[index][DBHelper.columnTodoTitle],
                      style: TextStyle(
                        decoration:
                            mTodo[index][DBHelper.columnTodoIsCompleted] == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(mTodo[index][DBHelper.columnTodoDesc],
                      style: TextStyle(
                        decoration:
                        mTodo[index][DBHelper.columnTodoIsCompleted] == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(child: Text('No Todos yet!!')),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedPriority = "High";
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Add Todo', style: TextStyle(fontSize: 25)),
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

                            bool isAdded = await dbHelper!.addTodo(
                              title: titleController.text,
                              desc: descController.text,
                              priority: priority,
                            );

                            if (isAdded) {
                              loadData();
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
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
