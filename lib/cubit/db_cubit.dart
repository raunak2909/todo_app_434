import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_434/cubit/db_state.dart';
import 'package:todo_app_434/db_helper.dart';

class DbCubit extends Cubit<DbState>{
  DBHelper dbHelper;
  DbCubit({required this.dbHelper}) : super(DbState(mData: []));

  void addTodo({required String title, required String desc, required int priority}) async{

    bool isAdded = await dbHelper.addTodo(title: title, desc: desc, priority: priority);
    if(isAdded){
      List<Map<String, dynamic>> allTodo = await dbHelper.getAllTodo();
      emit(DbState(mData: allTodo));
    }

  }

  void completeTask({required int id, required bool isCompleted}) async{
    bool isComplete = await dbHelper.completeTodo(id: id, isComplete: isCompleted);
    if(isComplete){
      List<Map<String, dynamic>> allTodo = await dbHelper.getAllTodo();
      emit(DbState(mData: allTodo));
    }
  }

}