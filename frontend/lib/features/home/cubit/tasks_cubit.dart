import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/taks_remote_repository.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task.models.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());
  final TaksRemoteRepository taksRemoteRepository = TaksRemoteRepository();
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
      final taskModel = await taksRemoteRepository.createTask(
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
      print(token);
      final tasks = await taksRemoteRepository.getTasks(token: token);
      //print(tasks);
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      print(e.toString());
      emit(TasksError(e.toString()));
    }
  }

  Future<void> syncTasks({
    required String token,
  }) async {
    try {
      // Simulate a network call
      final unsyncedTasks = await taskLocalRepository.getUnsyncedTasks();
      print(unsyncedTasks);

      if (unsyncedTasks.isEmpty) {
        return;
      }

      final isSynced = await taksRemoteRepository.syncTasks(
          token: token, tasks: unsyncedTasks);

      if (isSynced) {
        for (final task in unsyncedTasks) {
          taskLocalRepository.updateRowValue(task.id, 1);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
