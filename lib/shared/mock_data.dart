part of '../main.dart';

const _studentMenu = [
  MenuItem(Icons.forum_rounded, '質問・AI回答', Color(0xFF38BDF8)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.menu_book_rounded, 'AI教室', Color(0xFFF59E0B)),
  MenuItem(Icons.quiz_rounded, 'テスト', Color(0xFFEF4444)),
  MenuItem(Icons.support_agent_rounded, '先生に質問', Color(0xFFF97316)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _teacherMenu = [
  MenuItem(Icons.mark_chat_unread_rounded, 'AI回答不能（先生対応）', Color(0xFFF97316)),
  MenuItem(Icons.verified_rounded, '成績確認', Color(0xFF84CC16)),
  MenuItem(Icons.chat_rounded, '学生チャット', Color(0xFF38BDF8)),
  MenuItem(Icons.cloud_upload_rounded, '教材・テストアップロード', Color(0xFF8B5CF6)),
  MenuItem(Icons.admin_panel_settings_rounded, 'システム管理', Color(0xFF22C55E)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _defaultCode = '''
import java.util.*;

class Solution {
  public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> indexByValue = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
      int need = target - nums[i];
      if (indexByValue.containsKey(need)) {
        return new int[] { indexByValue.get(need), i };
      }
      indexByValue.put(nums[i], i);
    }
    return new int[] {};
  }
}
''';

String _teacherTitle(TeacherSection section) {
  switch (section) {
    case TeacherSection.pendingAi:
      return 'AI回答不能（先生対応）';
    case TeacherSection.codeScoring:
      return '成績確認';
    case TeacherSection.studentMessages:
      return '学生チャット';
    case TeacherSection.relearning:
      return '教材・テストアップロード';
    case TeacherSection.system:
      return 'システム管理';
    case TeacherSection.settings:
      return '設定';
  }
}
