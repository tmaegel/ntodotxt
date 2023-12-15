import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show ListFilter, ListGroup, ListOrder;

final class DefaultFilterState extends Equatable {
  ///  order.
  /// Defaults to [Order.ascending].
  final ListOrder order;

  ///  filter.
  /// Defaults to [Filter.all].
  final ListFilter filter;

  ///  group.
  /// Defaults to [Group.none].
  final ListGroup group;

  const DefaultFilterState({
    this.order = ListOrder.ascending,
    this.filter = ListFilter.all,
    this.group = ListGroup.none,
  });

  DefaultFilterState copyWith({
    ListOrder? order,
    ListFilter? filter,
    ListGroup? group,
  }) {
    return DefaultFilterState(
      order: order ?? this.order,
      filter: filter ?? this.filter,
      group: group ?? this.group,
    );
  }

  @override
  List<Object> get props => [
        order,
        filter,
        group,
      ];

  @override
  String toString() =>
      'DefaultFilterState { order: ${order.name} filter: ${filter.name} group: ${group.name} }';
}
