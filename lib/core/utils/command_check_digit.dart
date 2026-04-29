int? parseCommandCode(String input, {required bool checkDigitEnabled}) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return null;
  }

  final commandDigits = checkDigitEnabled
      ? digits.substring(0, digits.length - 1)
      : digits;

  if (commandDigits.isEmpty) {
    return null;
  }

  final commandCode = int.tryParse(commandDigits);
  if (commandCode == null || commandCode <= 0) {
    return null;
  }

  return commandCode;
}
