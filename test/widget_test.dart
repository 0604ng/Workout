import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/main.dart';

void main() {
  testWidgets('Workout App loads successfully', (WidgetTester tester) async {
    // Build the main app widget
    await tester.pumpWidget(const WorkoutApp());

    // Chờ cho widget tree render xong
    await tester.pumpAndSettle();

    // Kiểm tra xem app có hiển thị tiêu đề hoặc widget chính không
    expect(find.textContaining('Workout'), findsWidgets);

    // Kiểm tra xem có AppBar hoặc Scaffold được render
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(AppBar), findsWidgets);

    // In ra log để xác nhận
    debugPrint("✅ Workout App started successfully and main UI rendered.");
  });
}
