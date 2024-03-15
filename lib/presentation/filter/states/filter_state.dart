import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

sealed class FilterState extends Equatable {
  final Filter filter;
  final Filter? origin;

  FilterState({
    required this.filter,
    Filter? origin,
  }) : origin = origin ?? filter.copyWith();

  FilterLoading loading({
    Filter? filter,
  }) {
    return FilterLoading(
      filter: filter ?? this.filter,
      origin: origin,
    );
  }

  FilterChanged update({
    Filter? filter,
  }) {
    return FilterChanged(
      filter: filter ?? this.filter,
      origin: origin,
    );
  }

  FilterSaved save({
    Filter? filter,
  }) {
    return FilterSaved(
      filter: filter ?? this.filter,
    );
  }

  FilterError error({
    required String message,
    Filter? filter,
  }) {
    return FilterError(
      message: message,
      filter: filter ?? this.filter,
      origin: origin,
    );
  }

  bool get changed => origin != filter;

  bool get orderChanged {
    if (origin == null) {
      return true;
    } else {
      return origin!.order != filter.order;
    }
  }

  bool get filterChanged {
    if (origin == null) {
      return true;
    } else {
      return origin!.filter != filter.filter;
    }
  }

  bool get groupChanged {
    if (origin == null) {
      return true;
    } else {
      return origin!.group != filter.group;
    }
  }

  bool get prioritiesChanged {
    if (origin == null) {
      return true;
    } else {
      return !const SetEquality().equals(origin!.priorities, filter.priorities);
    }
  }

  bool get projectsChanged {
    if (origin == null) {
      return true;
    } else {
      return !const SetEquality().equals(origin!.projects, filter.projects);
    }
  }

  bool get contextsChanged {
    if (origin == null) {
      return true;
    } else {
      return !const SetEquality().equals(origin!.contexts, filter.contexts);
    }
  }

  @override
  List<Object?> get props => [
        filter,
        origin,
      ];

  @override
  String toString() => 'FilterState { filter: $filter }';
}

final class FilterLoading extends FilterState {
  FilterLoading({
    required super.filter,
    super.origin,
  });

  FilterLoading copyWith({
    Filter? filter,
  }) =>
      super.loading(filter: filter ?? this.filter);

  @override
  String toString() => 'FilterLoading { filter: $filter }';
}

final class FilterChanged extends FilterState {
  FilterChanged({
    required super.filter,
    super.origin,
  });

  FilterChanged copyWith({
    Filter? filter,
  }) =>
      super.update(filter: filter ?? this.filter);

  @override
  String toString() => 'FilterChanged { filter: $filter }';
}

final class FilterSaved extends FilterState {
  FilterSaved({
    required super.filter,
    super.origin,
  });

  FilterSaved copyWith({
    Filter? filter,
  }) =>
      super.save(filter: filter ?? this.filter);

  @override
  String toString() => 'FilterSaved { filter: $filter }';
}

final class FilterError extends FilterState {
  final String message;

  FilterError({
    required this.message,
    required super.filter,
    super.origin,
  });

  FilterError copyWith({
    String? message,
    Filter? filter,
  }) =>
      super.error(
          message: message ?? this.message, filter: filter ?? this.filter);

  @override
  List<Object?> get props => [
        message,
        filter,
        origin,
      ];

  @override
  String toString() => 'FilterError { message: $message filter: $filter }';
}
