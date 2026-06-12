import 'package:flutter_test/flutter_test.dart';
import 'package:roommate_app/features/disputes/data/dispute_models.dart';

void main() {
  test('repairs cp1251-style mojibake in dispute summary text', () {
    final item = DisputeItem.fromJson({
      'id': '1',
      'reporterId': 'reporter',
      'reason': 'SAFETY_CONCERN',
      'status': 'RESOLVED',
      'decision': 'ACCEPTED',
      'action': 'TEMPORARY_RESTRICTION',
      'title': 'Test',
      'description': 'Test',
      'createdAt': '2026-06-02T00:00:00.000Z',
      'updatedAt': '2026-06-02T00:00:00.000Z',
      'resultText':
          'Р–Р°Р»РѕР±Р° РїРѕРґС‚РІРµСЂР¶РґРµРЅР°. РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РІСЂРµРјРµРЅРЅРѕ РѕРіСЂР°РЅРёС‡РµРЅ РЅР° 2 РґРЅСЏ.',
    });

    expect(
      item.summaryResult,
      'Жалоба подтверждена. Пользователь временно ограничен на 2 дня.',
    );
  });
}
