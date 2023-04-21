// ignore_for_file: public_member_api_docs, sort_constructors_first
class Attribute {
  final String name;
  final String value;

  Attribute({
    required this.name,
    required this.value,
  });

  @override
  String toString() {
    return "$name($value)";
  }

  @override
  bool operator ==(covariant Attribute other) {
    if (identical(this, other)) return true;

    return other.name == name && other.value == value;
  }

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
