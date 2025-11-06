import 'package:flutter/material.dart';

class CustomTimeFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isDateField;
  final bool isTimeField;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final double? width;
  final String? initialValue; // Nuevo parámetro opcional para valor inicial

  const CustomTimeFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.isDateField = false,
    this.isTimeField = false,
    this.controller,
    this.width,
    this.initialValue, // Se inicializa el nuevo parámetro
  });

  @override
  CustomTimeFormFieldState createState() => CustomTimeFormFieldState();
}

class CustomTimeFormFieldState extends State<CustomTimeFormField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _internalController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = "${pickedDate.toLocal()}".split(' ')[0];
      _internalController.text = formattedDate;
      widget.onChanged?.call(formattedDate);
      setState(() {});
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      final time24Hour = _convertTo24HourFormat(formattedTime);
      _internalController.text = time24Hour;
      widget.onChanged?.call(time24Hour);
      setState(() {});
    }
  }

  String _convertTo24HourFormat(String time12Hour) {
    final timeParts = time12Hour.split(' ');
    final time = timeParts[0];
    final period = timeParts[1];

    final hourMinute = time.split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = hourMinute[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  void _handleTap() {
    if (widget.isDateField) {
      _selectDate(context);
    } else if (widget.isTimeField) {
      _selectTime(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _internalController.text.isEmpty
                      ? (widget.hint ?? 'Seleccionar')
                      : _internalController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: _internalController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
