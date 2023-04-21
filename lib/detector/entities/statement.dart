// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:duplicates_detector/detector/entities/attribute.dart';
import 'package:flutter/foundation.dart';

class Statement {
  final List<Attribute> attributes;

  Statement({
    required this.attributes,
  });

  @override
  bool operator ==(covariant Statement other) {
    if (identical(this, other)) return true;

    return listEquals(other.attributes, attributes);
  }

  @override
  String toString() {
    return '( ${attributes.join(" AND ")} )';
  }

  @override
  int get hashCode => attributes.hashCode;
}
