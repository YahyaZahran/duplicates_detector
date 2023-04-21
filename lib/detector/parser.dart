import 'package:duplicates_detector/detector/entities/index.dart';
import 'package:excel/excel.dart';

class StringToDetectorInputParser {
  Attribute parseAttribute(String input) {
    final patterns = [
      "([A-z,0-9]*)\\(([A-z,0-9]*)\\)",
      "([A-z,0-9]*)\\_([A-z,0-9]*)"
    ];
    for (final pattern in patterns) {
      final reg = RegExp(pattern);
      final matches = reg.firstMatch(input);
      if (matches == null) continue;
      final state = input.contains("NOT") ? "!" : "";
      return Attribute(
        name: matches.group(1)!,
        value: matches.group(2)! + state,
      );
    }

    throw Exception("Syntax Error");
  }

  Statement parseStatement(String raw) {
    final portions = raw.split("AND");
    return Statement(
      attributes: portions.map((e) => parseAttribute(e)).toList(),
    );
  }

  Line parseLine(String id, String raw) {
    final input = raw.substring(1, raw.length - 1);
    final portions = input.split("OR");
    return Line(
      id: id,
      statments: portions.map((e) => parseStatement(e)).toList(),
    );
  }

  List<Line> parseSheet(Sheet sheet) {
    var rows = sheet.rows.skip(1).toList();

    return rows
        .map(
          (row) => parseLine(
            row.first!.value.toString().startsWith(RegExp("[0-9]"))
                ? row.first!.rowIndex.toString()
                : row.first!.value.toString(),
            row.last!.value.toString(),
          ),
        )
        .toList();
  }
}
