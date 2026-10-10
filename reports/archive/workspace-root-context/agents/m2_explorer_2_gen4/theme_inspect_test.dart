import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  test('Inspect FSidebarStyle', () {
    final theme = FTheme.neutral.light.touch;
    print('sidebarStyle: ${theme.sidebarStyle}');
    print('sidebarStyle.groupStyle: ${theme.sidebarStyle.groupStyle}');
  });
}
