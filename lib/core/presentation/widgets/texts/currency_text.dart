import 'package:flutter/material.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.amount, {
    super.key,
    this.currency,
    this.style,
    this.withDelta = false,
  });

  final bool withDelta;
  final double amount;
  final String? currency;
  final TextStyle? style;

  String amountString(double value, [int precision = 3]) {
    final s = value.toString();
    final parts = s.split('.');

    if (parts.length == 1) return s;

    final decimals = parts[1].substring(
      0,
      parts[1].length < precision ? parts[1].length : precision,
    );

    final result = "${parts[0]}.$decimals".replaceFirst(RegExp(r'\.?0+$'), '');

    return result;
  }

  String get amountDisplay {
    final n = amount.abs();

    if (n >= 1e9) {
      return '${amountString(n / 1e9)}B';
    }
    if (n >= 1e6) {
      return '${amountString(n / 1e6)}M';
    }

    if (n >= 1e3) {
      return '${amountString(n / 1e3)}K';
    }

    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (withDelta)
            WidgetSpan(
              child: _CurrencySignIcon(amount, style: style),
              alignment: PlaceholderAlignment.middle,
              style: style,
            ),
          TextSpan(text: amountDisplay, style: style),
        ],
      ),
    );
  }
}

class _CurrencySignIcon extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const _CurrencySignIcon(this.amount, {this.style});

  @override
  Widget build(BuildContext context) {
    return Icon(
      amount >= 0 ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined,
      size: (style?.fontSize ?? 16) / 1.75,
    );
  }
}
