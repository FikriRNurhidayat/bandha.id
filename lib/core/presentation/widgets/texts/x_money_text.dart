import 'package:flutter/material.dart';

class XMoneyText extends StatelessWidget {
  final double amount;
  final String currency;
  final bool useSymbol;
  final TextStyle? style;

  const XMoneyText(
    this.amount, {
    super.key,
    this.currency = 'IDR',
    this.useSymbol = true,
    this.style,
  });

  String getSign() {
    return amount >= 0 ? "+" : "-";
  }

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
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        children: [
          if (useSymbol) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _XMoneySign(amount),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(width: 8),
            ),
          ],
          TextSpan(text: amountDisplay, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _XMoneySign extends StatelessWidget {
  final double amount;

  const _XMoneySign(this.amount);

  @override
  Widget build(BuildContext context) {
    return Icon(
      amount >= 0 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      size: 16,
    );
  }
}
