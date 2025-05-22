part of 'tasks_cubit.dart';
sealed class TasksState {
  const TasksState();
}

final class TasksInitial extends TasksState{}
final class TasksLoading extends TasksState{}
final class TasksError extends TasksState{
  final String error;
  TasksError(this.error);
}
final class AddNewTaskSuccess extends TasksState{
  final TaskModel taskModel;
  AddNewTaskSuccess(this.taskModel);
}

final class AddNewTaskError extends TasksState{
  final String error;
  AddNewTaskError(this.error);
}
final class GetTasksSuccess extends TasksState{
  final List<TaskModel> tasks;
  GetTasksSuccess(this.tasks);
}
final class GetTasksError extends TasksState{
  final String error;
  GetTasksError(this.error);
}