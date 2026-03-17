import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A TextFormField wrapper that shows a live character count below the field.
class CharacterCountField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int maxLength;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? hintText;

  const CharacterCountField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLength = 200,
    this.maxLines = 1,
    this.validator,
    this.hintText,
  });

  @override
  State<CharacterCountField> createState() => _CharacterCountFieldState();
}

class _CharacterCountFieldState extends State<CharacterCountField> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = widget.controller.text.length;
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() => _count = widget.controller.text.length);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOver = _count > widget.maxLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            alignLabelWithHint: widget.maxLines > 1,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_count / ${widget.maxLength}',
            style: TextStyle(
              fontSize: 11,
              color: isOver ? AppColors.danger : AppColors.textHint,
              fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
