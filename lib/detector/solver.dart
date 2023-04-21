import 'package:duplicates_detector/detector/entities/attribute.dart';
import 'package:duplicates_detector/detector/entities/line.dart';
import 'package:duplicates_detector/detector/entities/statement.dart';

class Duplicate {
  final Line firstLine;
  final Line secondLine;

  Duplicate({
    required this.firstLine,
    required this.secondLine,
  });
}

class WarningEntry {
  final Line line;
  final List<Attribute> attributes;

  WarningEntry({required this.line, required this.attributes});
}

class ErrorEntry {
  final Line line;
  final List<Attribute> attributes;

  ErrorEntry({required this.line, required this.attributes});
}

class Solver {
  List<Duplicate> solve(
    List<Line> creation,
    List<Line> already, {
    bool skipSameLineIds = false,
  }) {
    final ret = <Duplicate>[];
    for (final creationLine in creation) {
      for (final existLine in already) {
        if (skipSameLineIds && creationLine.id == existLine.id) continue;
        var isThereDuplicate = false;
        for (final creationStm in creationLine.statments) {
          for (final existStm in existLine.statments) {
            if (!isThereDifference(creationStm, existStm)) {
              isThereDuplicate = true;
            }
          }
        }
        if (isThereDuplicate) {
          ret.add(
            Duplicate(firstLine: creationLine, secondLine: existLine),
          );
        }
      }
    }
    return ret;
  }

  List<WarningEntry> getAllWarnings(
    List<Line> creation,
    List<Line> already, {
    bool skipSameLineIds = false,
  }) {
    final ret = <WarningEntry>[];

    for (final creationLine in creation) {
      final attributesSet = <Attribute>{};
      for (final existLine in already) {
        if (skipSameLineIds && creationLine.id == existLine.id) continue;
        for (final creationStm in creationLine.statments) {
          for (final existStm in existLine.statments) {
            attributesSet.addAll(findNotCases(creationStm, existStm));
          }
        }
      }
      if (attributesSet.isNotEmpty) {
        ret.add(
          WarningEntry(line: creationLine, attributes: attributesSet.toList()),
        );
      }
    }

    return ret;
  }

  List<ErrorEntry> findErrors(List<Line> lines) {
    final ret = <ErrorEntry>[];
    for (final line in lines) {
      final errors = <Attribute>{};
      for (final statement in line.statments) {
        final frq = <String, int>{};
        for (final attribute in statement.attributes) {
          frq[attribute.name] = (frq[attribute.name] ?? 0) + 1;
        }
        final toAdd = frq.entries.where((element) => element.value > 1).map(
              (e) => Attribute(name: e.key, value: "not_important"),
            );
        errors.addAll(toAdd);
      }
      if (errors.isNotEmpty) {
        ret.add(ErrorEntry(line: line, attributes: errors.toList()));
      }
    }
    return ret;
  }

  List<Attribute> findNotCases(Statement s1, Statement s2) {
    final ret = <Attribute>{};
    final attrs = Map.fromEntries(
      s1.attributes.map((e) => MapEntry(e.name, e.value)),
    );
    for (final x in s2.attributes) {
      if (attrs.containsKey(x.name) &&
          x.value != attrs[x.name] &&
          x.value.endsWith("!") &&
          attrs[x.name]!.endsWith("!")) {
        ret.add(x);
      }
    }
    return ret.toList();
  }

  bool isThereDifference(Statement s1, Statement s2) {
    final attrs = {};
    for (final attribute in s1.attributes) {
      attrs[attribute.name] = attribute.value;
    }
    for (final attribute in s2.attributes) {
      if (attrs.containsKey(attribute.name) &&
          attrs[attribute.name] != attribute.value) return true;
    }
    return false;
  }
}
