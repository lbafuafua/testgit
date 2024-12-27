import 'package:flutter/material.dart';

class CustomDatePicker {
  static Future<DateTime?> show(BuildContext context,
      {DateTime? initialDate}) async {
    DateTime selectedDate = initialDate ?? DateTime.now();
    DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Date de naissance"),
          content: SizedBox(
            height: 250, // Ajustez la hauteur pour contenir le DatePicker
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime date) {
                      selectedDate = date;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(null); // Retourne null si annulation
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context)
                    .pop(selectedDate); // Retourne la date choisie
              },
            ),
          ],
        );
      },
    );
    return pickedDate;
  }
}
