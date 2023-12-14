import 'package:equatable/equatable.dart';

class Setting extends Equatable {
  final int? id;
  final String key;
  final String value;

  const Setting({
    this.id,
    required this.key,
    required this.value,
  });

  static String get tableRepr {
    return '''CREATE TABLE settings(
      `id` INTEGER PRIMARY KEY,
      `key` TEXT,
      `value` TEXT
    )''';
  }

  Setting copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return Setting(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  /// Convert a [Setting] into Map.
  /// The keys must correspond to the names of the
  /// columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() => 'Setting { id: $id, key: $key value: $value }';

  @override
  List<Object?> get props => [
        id,
        key,
        value,
      ];
}
