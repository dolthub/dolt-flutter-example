import 'package:flutter/material.dart';

// Show snack bar with error details
handleError(BuildContext context, dynamic error, String action) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Failed to $action: $error"),
    backgroundColor: const Color.fromARGB(255, 235, 108, 108),
  ));
}

// Show snack bar with success details
handleSuccess(BuildContext context, String action) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("$action successfully"),
    backgroundColor: const Color.fromARGB(255, 4, 160, 74),
  ));
}
