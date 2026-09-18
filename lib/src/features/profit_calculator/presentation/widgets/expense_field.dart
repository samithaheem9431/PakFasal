import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric field that keeps local text state while typing.
/// Syncs from [value] only when [syncToken] changes (load/clear).
class ExpenseField extends StatefulWidget {
  const ExpenseField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.syncToken,
    this.prefixText = 'PKR',
    this.keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final int syncToken;
  final String? prefixText;
  final TextInputType keyboardType;

  @override
  State<ExpenseField> createState() => _ExpenseFieldState();
}

class _ExpenseFieldState extends State<ExpenseField> {
  late final TextEditingController _controller;
  int _lastSyncToken = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _lastSyncToken = widget.syncToken;
  }

  @override
  void didUpdateWidget(covariant ExpenseField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncToken != _lastSyncToken) {
      _lastSyncToken = widget.syncToken;
      final next = _format(widget.value);
      if (_controller.text != next) {
        _controller.text = next;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(double value) {
    if (value == 0) return '';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: widget.prefixText == null ? null : '${widget.prefixText} ',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (raw) {
        final parsed = double.tryParse(raw.trim()) ?? 0;
        widget.onChanged(parsed);
      },
    );
  }
}
