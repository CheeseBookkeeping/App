import 'package:flutter_test/flutter_test.dart';
import 'package:cheesebookkeeping/main.dart';

void main() {
  testWidgets('起司记账应用冒烟测试', (WidgetTester tester) async {
    await tester.pumpWidget(const CheeseBookApp());
    // 验证 App 能正常启动、首页渲染
    expect(find.text('起司记账'), findsOneWidget);
  });
}
