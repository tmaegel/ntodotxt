class TodoException implements Exception {
  final String message;

  const TodoException(this.message);

  @override
  String toString() => 'TodoException: $message';
}

class TodoNotFound extends TodoException {
  final int? id;
  const TodoNotFound({
    this.id,
  }) : super('Todo with id $id could not be found');

  @override
  String toString() => 'TodoNotFound: $message';
}

class TodoStringMalformed extends TodoException {
  const TodoStringMalformed() : super('Todo string is malformed');

  @override
  String toString() => 'TodoStringMalformed: $message';
}

class TodoStringForbiddenCompletionDate extends TodoException {
  const TodoStringForbiddenCompletionDate()
      : super('Completion date is forbidden if todo is incompleted');

  @override
  String toString() => 'TodoStringForbiddenCompletionDate: $message';
}

class TodoStringMissingCompletionDate extends TodoException {
  const TodoStringMissingCompletionDate()
      : super('Completed todo requires a completion date');

  @override
  String toString() => 'TodoStringMissingCompletionDate: $message';
}
