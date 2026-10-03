import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasirekap/main.dart';

void main() {
  testWidgets('Beranda menampilkan judul region', (WidgetTester tester) async {
    await tester.pumpWidget(const RekapFlApp());

    expect(find.text('Pemenuhan FL Region 04'), findsOneWidget);
  });
}
