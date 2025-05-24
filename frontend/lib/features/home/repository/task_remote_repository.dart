import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task.models.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaksRemoteRepository {
  final TaskLocalRepository taskLocalRepository = TaskLocalRepository();
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueAt,
    required String token,
    required String uid,
    required String hexColor,
    required TimeOfDay dueTime,
  }) async {
    final now = DateTime.now();
    final dueTimeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      dueTime.hour,
      dueTime.minute,
    );
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "dueAt": dueAt.toIso8601String(),
          "hexColor": hexColor,
          "dueTime": dueTimeDateTime.toIso8601String(),
        }),
      );

      if (res.statusCode != 201) {
        throw Exception("Failed to create task");
      }

      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v6(),
          uid: uid,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
          dueTime: dueTime,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTasks({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      //print(res.body);

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfTasks = jsonDecode(res.body);
      List<TaskModel> tasks = [];

      for (var elem in listOfTasks) {
        tasks.add(TaskModel.fromMap(elem));
      }
      //print("Line 95 from task_remote_repository.dart");
      //print(tasks);

      await taskLocalRepository.insertTasks(tasks);
    
      return tasks;
    } catch (e) {
      //print("📴 Offline or failed API. Reason: $e");
      final tasks = await taskLocalRepository.getTasks();
      if (tasks.isNotEmpty) {
        return tasks;
      }
      //print(tasks);
      rethrow;
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = [];
      for (final task in tasks) {
        taskListInMap.add(task.toMap());
      }
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks/sync"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(taskListInMap),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return true;
    } catch (e) {
      //print("syncTasks method : "+e.toString());
      return false;
    }
  }
}
