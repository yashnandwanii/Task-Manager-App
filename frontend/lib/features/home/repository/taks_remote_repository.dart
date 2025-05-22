import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/task.models.dart';
import 'package:http/http.dart' as http;

class TaksRemoteRepository {
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueAt,
    required String token,
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
      rethrow;
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
        throw Exception("Failed to get the tasks");
      }
      final listOfTasks = jsonDecode(res.body);
      final List<TaskModel> tasks = [];

      for (var elem in listOfTasks) {
        tasks.add(TaskModel.fromMap(elem));
      }

      return tasks;
    } catch (e) {
      rethrow;
    }
  }
}
