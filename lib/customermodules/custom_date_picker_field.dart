import 'package:flutter/material.dart';
import 'custom_date_picker.dart';

class CustomDatePickerField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const CustomDatePickerField({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomDatePickerFieldState createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Affiche le DatePicker et récupère la date sélectionnée
        DateTime? selectedDate = await CustomDatePicker.show(
          context,
          initialDate: DateTime.now(),
        );
        if (selectedDate != null) {
          // Mettre à jour le contrôleur avec la date formatée
          widget.controller.text =
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: widget.controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
