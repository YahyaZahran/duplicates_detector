import 'package:duplicates_detector/detector/entities/attribute.dart';
import 'package:duplicates_detector/detector/entities/line.dart';
import 'package:duplicates_detector/detector/entities/statement.dart';
import 'package:duplicates_detector/detector/parser.dart';
import 'package:test/test.dart';

void main() {
  late StringToDetectorInputParser parser;
  setUp(() {
    parser = StringToDetectorInputParser();
  });
  group("Test parsing attributes", () {
    test("parsing attribute of type DXD(22)", () {
      expect(
        Attribute(name: "DXD", value: "22"),
        parser.parseAttribute("DXD(22)"),
      );
    });
    test("parsing attribute of type NOT DXD(22)", () {
      expect(
        Attribute(name: "DXD!", value: "22"),
        parser.parseAttribute("NOT DXD(22)"),
      );
    });
    test("parsing attribute of type DXD_22", () {
      expect(
        Attribute(name: "DXD", value: "22"),
        parser.parseAttribute("DXD_22"),
      );
    });
  });

  group("test parsing statements", () {
    test("normal statement parsing", () {
      expect(
        Statement(
          attributes: [
            Attribute(name: "DXD", value: "22"),
            Attribute(name: "XYZ", value: "12"),
            Attribute(name: "YAHYA", value: "99"),
          ],
        ),
        parser.parseStatement("DXD(22) AND XYZ(12) AND YAHYA(99)"),
      );
    });
  });

  group("test parsing lines", () {
    test("test normal line", () {
      expect(
        Line(
          id: "#1",
          statments: [
            Statement(
              attributes: [
                Attribute(name: "DXD", value: "22"),
                Attribute(name: "XYZ", value: "12"),
                Attribute(name: "YAHYA", value: "99"),
              ],
            ),
            Statement(
              attributes: [
                Attribute(name: "DXD", value: "22"),
                Attribute(name: "XYZ", value: "12"),
              ],
            ),
          ],
        ),
        parser.parseLine(
          "#1",
          "(DXD(22) AND XYZ(12) AND YAHYA(99)) OR (DXD(22) AND XYZ(12))",
        ),
      );
    });
  });
}
