import 'package:flutter_test/flutter_test.dart';

import 'package:hz_xg_pad/main.dart';

void main() {
  testWidgets('login page navigates to home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('仓储作业登录'), findsOneWidget);
    expect(find.text('请输入用户名和密码后进入系统'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);

    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('主页'), findsOneWidget);
    expect(find.text('这里是主页'), findsOneWidget);
  });
}
