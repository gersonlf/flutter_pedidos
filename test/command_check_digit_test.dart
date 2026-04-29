import 'package:flutter_pedidos/core/utils/command_check_digit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseCommandCode removes last digit when check digit is enabled', () {
    final commandCode = parseCommandCode('12345', checkDigitEnabled: true);

    expect(commandCode, 1234);
  });

  test('parseCommandCode keeps full code when check digit is disabled', () {
    final commandCode = parseCommandCode('12345', checkDigitEnabled: false);

    expect(commandCode, 12345);
  });

  test('parseCommandCode ignores non-digit characters from barcode input', () {
    final commandCode = parseCommandCode('CMD-12345', checkDigitEnabled: true);

    expect(commandCode, 1234);
  });

  test('parseCommandCode rejects single digit when check digit is enabled', () {
    final commandCode = parseCommandCode('5', checkDigitEnabled: true);

    expect(commandCode, isNull);
  });

  test('parseCommandCode rejects empty command input', () {
    final commandCode = parseCommandCode('', checkDigitEnabled: false);

    expect(commandCode, isNull);
  });
}
