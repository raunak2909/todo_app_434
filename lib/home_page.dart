import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_434/add_todo.dart';
import 'package:todo_app_434/cubit/db_cubit.dart';
import 'package:todo_app_434/cubit/db_state.dart';
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

  ///1. filter todo's on the basis on priority low/medium/high
  ///2. Complete Quiz App using DB

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

  pendingTask() async {
    mTodo = await dbHelper!.getAllTodo(taskFlag: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: BlocBuilder<DbCubit, DbState>(
        builder: (context, state) {
          mTodo = state.mData;
          return mTodo.isNotEmpty
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            mTodo = await dbHelper!.getAllTodo(taskFlag: 0);
                            setState(() {});
                          },
                          child: Text('Pending'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            mTodo = await dbHelper!.getAllTodo(taskFlag: 1);
                            setState(() {});
                          },
                          child: Text('Completed'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            mTodo = await dbHelper!.getAllTodo();
                            setState(() {});
                          },
                          child: Text('All'),
                        ),
                      ],
                    ),
                    SizedBox(height: 11),
                    Expanded(
                      child: ListView.builder(
                        itemCount: mTodo.length,
                        itemBuilder: (_, index) {
                          Color bgColor = Colors.white;

                          if (mTodo[index][DBHelper.columnTodoPriority] == 1) {
                            bgColor = Colors.blue.shade200;
                          } else if (mTodo[index][DBHelper
                                  .columnTodoPriority] ==
                              2) {
                            bgColor = Colors.orange.shade200;
                          } else {
                            bgColor = Colors.red.shade200;
                          }

                          return Card(
                            color: bgColor,
                            child: ListTile(
                              leading: Checkbox(
                                value:
                                    mTodo[index][DBHelper
                                        .columnTodoIsCompleted] ==
                                    1,
                                onChanged: (value) async {
                                  context.read<DbCubit>().completeTask(
                                    id: mTodo[index][DBHelper.columnTodoId],
                                    isCompleted: value ?? false,
                                  );
                                  /*bool isUpdated = await dbHelper!.completeTodo(
                                    id: mTodo[index][DBHelper.columnTodoId],
                                    isComplete: value ?? false,
                                  );

                                  if (isUpdated) {
                                    loadData();
                                  }*/
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      titleController.text =
                                          mTodo[index][DBHelper
                                              .columnTodoTitle];
                                      descController.text =
                                          mTodo[index][DBHelper.columnTodoDesc];
                                      int priority =
                                          mTodo[index][DBHelper
                                              .columnTodoPriority];
                                      if (priority == 1) {
                                        selectedPriority = "Low";
                                      } else if (priority == 2) {
                                        selectedPriority = "Medium";
                                      } else {
                                        selectedPriority = "High";
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddUpdateTodo(
                                            isUpdate: true,
                                            id:
                                                mTodo[index][DBHelper
                                                    .columnTodoId],
                                            title:
                                                mTodo[index][DBHelper
                                                    .columnTodoTitle],
                                            desc:
                                                mTodo[index][DBHelper
                                                    .columnTodoDesc],
                                            priority: selectedPriority,
                                          ),
                                        ),
                                      );

                                      /*showModalBottomSheet(
                                        context: context,
                                        builder: (context) => myBottomSheetUI(isUpdate: true, id: mTodo[index][DBHelper.columnTodoId]),
                                      );*/
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool
                                      isDeleted = await dbHelper!.deleteTodo(
                                        id: mTodo[index][DBHelper.columnTodoId],
                                      );
                                      if (isDeleted) {
                                        loadData();
                                      }
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                              title: Text(
                                mTodo[index][DBHelper.columnTodoTitle],
                                style: TextStyle(
                                  decoration:
                                      mTodo[index][DBHelper
                                              .columnTodoIsCompleted] ==
                                          1
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                mTodo[index][DBHelper.columnTodoDesc],
                                style: TextStyle(
                                  decoration:
                                      mTodo[index][DBHelper
                                              .columnTodoIsCompleted] ==
                                          1
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Center(child: Text('No Todos yet!!'));
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedPriority = "High";
          titleController.clear();
          descController.clear();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUpdateTodo()),
          );
          /*showModalBottomSheet(
            context: context,
            builder: (_) {
              return myBottomSheetUI();
            },
          );*/
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget myBottomSheetUI({bool isUpdate = false, int id = 0}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${isUpdate ? 'Update' : 'Add'} Todo',
            style: TextStyle(fontSize: 25),
          ),
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

                  if (isUpdate) {
                    isTaskDone = await dbHelper!.updateTodo(
                      title: titleController.text,
                      desc: descController.text,
                      priority: priority,
                      id: id,
                    );
                  } else {
                    isTaskDone = await dbHelper!.addTodo(
                      title: titleController.text,
                      desc: descController.text,
                      priority: priority,
                    );
                  }

                  if (isTaskDone) {
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
  }
}
