// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:duplicates_detector/detector/entities/statement.dart';
import 'package:flutter/foundation.dart';

class Line {
  final String id;
  final List<Statement> statments;

  Line({
    required this.id,
    required this.statments,
  });

  @override
  bool operator ==(covariant Line other) {
    if (identical(this, other)) return true;

    return other.id == id && listEquals(other.statments, statments);
  }

  @override
  String toString() {
    return '\n(\n ${statments.join(" OR \n ")}\n)';
  }

  @override
  int get hashCode => id.hashCode ^ statments.hashCode;
}
