import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task.models.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());
  final TaksRemoteRepository taskRemoteRepository = TaksRemoteRepository();
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required DateTime dueAt,
    required Color color,
    required String uid,
    required String token,
    required TimeOfDay dueTime,
  }) async {
    try {
      emit(TasksLoading());
      // Simulate a network call
      final taskModel = await taskRemoteRepository.createTask(
        title: title,
        uid: uid,
        description: description,
        dueAt: dueAt,
        token: token,
        hexColor: rgbToHex(color),
        dueTime: dueTime,
      );
      await taskLocalRepository.insertTask(taskModel);

      //print(taskModel);
      emit(AddNewTaskSuccess(taskModel));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> getAllTasks({
    required String token,
  }) async {
    try {
      emit(TasksLoading());
      // Simulate a network call
      //print("Line 51 from tasks_cubit.dart: ");
      final tasks = await taskRemoteRepository.getTasks(token: token);
      //print('line 53: ${tasks}');
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      //print("Line 56 from tasks_cubit.dart: " + e.toString());
      emit(TasksError(e.toString()));
    }
  }

  Future<void> syncTasks({
    required String token,
  }) async {
    try {
      // Simulate a network call
      //print("Line 66 from task_cubit.dart : ");
      final unsyncedTasks = await taskLocalRepository.getUnsyncedTasks();
      //print("Line 67 from task_cubit.dart : ");
      //print(unsyncedTasks);

      if (unsyncedTasks.isEmpty) {
        return;
      }

      final isSynced = await taskRemoteRepository.syncTasks(
          token: token, tasks: unsyncedTasks);

      if (isSynced) {
        for (final task in unsyncedTasks) {
          taskLocalRepository.updateRowValue(task.id, 1);
        }
      }
    } catch (e) {
      rethrow;
      //print("Line 83 from task_cubit.dart : " + e.toString());
    }
  }
}
