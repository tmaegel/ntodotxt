import 'package:equatable/equatable.dart';

class Setting extends Equatable {
  final String key;
  final String value;

  const Setting({
    required this.key,
    required this.value,
  });

  Setting.fromMap(Map<dynamic, dynamic> map)
      : key = map['key'] as String,
        value = map['value'] as String;

  static String get tableRepr {
    return '''CREATE TABLE settings(
      `id` INTEGER PRIMARY KEY,
      `key` TEXT NOT NULL UNIQUE,
      `value` TEXT NOT NULL
    )''';
  }

  Setting copyWith({
    String? key,
    String? value,
  }) {
    return Setting(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  /// Convert a [Setting] into Map.
  /// The keys must correspond to the names of the
  /// columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() => 'Setting { key: $key value: $value }';

  @override
  List<Object?> get props => [
        key,
        value,
      ];
}
