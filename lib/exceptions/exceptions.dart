sealed class TodoException implements Exception {
  final String message;

  const TodoException(this.message);

  @override
  String toString() => message;
}

class TodoNotFound extends TodoException {
  final int? id;
  const TodoNotFound({
    this.id,
  }) : super('Todo with id $id could not be found');
}

class TodoStringMalformed extends TodoException {
  const TodoStringMalformed() : super('Todo string is malformed');
}

class TodoInvalidProjectTag extends TodoException {
  final String tag;
  const TodoInvalidProjectTag({
    required this.tag,
  }) : super('Invalid project tag: $tag');
}

class TodoInvalidContextTag extends TodoException {
  final String tag;
  const TodoInvalidContextTag({
    required this.tag,
  }) : super('Invalid context tag: $tag');
}

class TodoInvalidKeyValueTag extends TodoException {
  final String tag;
  const TodoInvalidKeyValueTag({
    required this.tag,
  }) : super('Invalid key value tag: $tag');
}

class TodoMissingDescription extends TodoException {
  const TodoMissingDescription() : super('Description is mandatory');
}

class TodoForbiddenCompletionDate extends TodoException {
  const TodoForbiddenCompletionDate()
      : super('Completion date is forbidden if todo is incompleted');
}

class TodoMissingCompletionDate extends TodoException {
  const TodoMissingCompletionDate()
      : super('Completed todo requires a completion date');
}
