import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/taks_remote_repository.dart';
import 'package:frontend/models/task.models.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());
  final TaksRemoteRepository taksRemoteRepository = TaksRemoteRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required DateTime dueAt,
    required Color color,
    required String token,
    required TimeOfDay dueTime,
  }) async {
    try {
      emit(TasksLoading());
      // Simulate a network call
      final taskModel = await taksRemoteRepository.createTask(
        title: title,
        description: description,
        dueAt: dueAt,
        token: token,
        hexColor: rgbToHex(color),
        dueTime: dueTime,
      );

      print(taskModel);
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
      final tasks = await taksRemoteRepository.getTasks(token: token);
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      //print(e.toString());
      emit(TasksError(e.toString()));
    }
  }
}
