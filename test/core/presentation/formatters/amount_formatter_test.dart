import 'package:bandha/core/presentation/formatters/amount_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue typed(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  final formatter = AmountFormatter();
  TextEditingValue run(String text) =>
      formatter.formatEditUpdate(TextEditingValue.empty, typed(text));

  group("AmountFormatter", () {
    test("groups digits by thousands", () {
      expect(run("1").text, "1");
      expect(run("123").text, "123");
      expect(run("1234").text, "1,234");
      expect(run("1234567").text, "1,234,567");
      expect(run("123456").text, "123,456");
    });

    test("strips non-digits before grouping", () {
      expect(run("1a2.3-4").text, "1,234");
      expect(run("1,2345").text, "12,345");
    });

    test("empty or non-numeric input clears the field", () {
      expect(run("").text, "");
      expect(run("abc").text, "");
    });

    test("moves the cursor to the end after reformatting", () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: "1234",
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, "1,234");
      expect(result.selection, const TextSelection.collapsed(offset: 5));
    });

    test("returns the same value when already formatted", () {
      final value = typed("1,234");
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, value),
        same(value),
      );
    });
  });
}
