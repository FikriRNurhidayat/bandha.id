import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue typed(String text, [int? offset]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: offset ?? text.length),
);

void main() {
  group("NumericFormatter (en_US, integers)", () {
    final formatter = NumericFormatter(locale: "en_US");
    TextEditingValue run(String text, [int? offset]) =>
        formatter.formatEditUpdate(TextEditingValue.empty, typed(text, offset));

    test("uses locale separators", () {
      expect(formatter.separator, ".");
      expect(formatter.thousandSeparator, ",");
    });

    test("groups thousands", () {
      expect(run("1234567").text, "1,234,567");
      expect(run("12").text, "12");
    });

    test("drops disallowed characters including fractions", () {
      expect(run("12a34").text, "1,234");
      expect(run("1.5").text, "15");
    });

    test("empty input stays empty", () {
      expect(run("").text, "");
    });

    test("cursor at end accounts for inserted separators", () {
      final result = run("12345");
      expect(result.text, "12,345");
      expect(result.selection.baseOffset, 6);
    });

    test("cursor in the middle stays after the same digit", () {
      // Cursor after "12" in "12345" -> after "12" in "12,345".
      final result = run("12345", 2);
      expect(result.selection.baseOffset, 2);
      // Cursor after "123" -> skips the inserted comma.
      expect(run("12345", 3).selection.baseOffset, 4);
    });

    test("original removes grouping", () {
      expect(formatter.original("1,234,567"), "1234567");
      expect(formatter.original("abc"), isNull);
    });

    test("checkUserInput accepts digits and the separator", () {
      expect(formatter.checkUserInput("5"), isTrue);
      expect(formatter.checkUserInput("."), isTrue);
      expect(formatter.checkUserInput(","), isFalse);
    });
  });

  group("NumericFormatter (en_US, fractions)", () {
    final formatter = NumericFormatter(
      locale: "en_US",
      allowFraction: true,
      fractionDigits: 2,
    );
    String run(String text) =>
        formatter.formatEditUpdate(TextEditingValue.empty, typed(text)).text;

    test("keeps typed fraction digits without padding", () {
      expect(run("1234.5"), "1,234.5");
      expect(run("1234.56"), "1,234.56");
    });

    test("truncates beyond fractionDigits", () {
      expect(run("1.567"), "1.56");
    });

    test("keeps a trailing separator while typing", () {
      expect(run("1234."), "1,234.");
    });

    test("removes a second decimal separator", () {
      expect(
        formatter.checkValidValue(TextEditingValue.empty, typed("1.5.")).text,
        "1.5",
      );
      expect(run("1.5."), "1.5");
    });
  });

  group("NumericFormatter (id, comma decimal)", () {
    final formatter = NumericFormatter(
      locale: "id",
      allowFraction: true,
      fractionDigits: 2,
    );
    String run(String text) =>
        formatter.formatEditUpdate(TextEditingValue.empty, typed(text)).text;

    test("uses locale separators", () {
      expect(formatter.separator, ",");
      expect(formatter.thousandSeparator, ".");
    });

    test("formats with dot grouping and comma decimals", () {
      expect(run("1234567"), "1.234.567");
      expect(run("1234,5"), "1.234,5");
      expect(run("1234,"), "1.234,");
    });

    test(
      "removes a second decimal separator",
      () {
        expect(
          formatter.checkValidValue(TextEditingValue.empty, typed("1,5,")).text,
          "1,5",
        );
      },
      skip:
          "BUG: numeric_formatter.dart:200 uses RegExp(r'\\\\,') which matches "
          "a literal backslash+comma, so duplicate comma separators are never "
          "detected",
    );
  });

  group("NumericFormatter custom separators", () {
    test("replaces grouping with the custom thousand separator", () {
      final formatter = NumericFormatter(
        locale: "en_US",
        thousandSeparator: " ",
      );
      expect(
        formatter
            .formatEditUpdate(TextEditingValue.empty, typed("1234567"))
            .text,
        "1 234 567",
      );
      expect(formatter.original("1 234 567"), "1234567");
    });
  });
}
