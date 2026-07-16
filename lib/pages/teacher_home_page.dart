part of '../main.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  TeacherSection _section = TeacherSection.pendingAi;
  int _selectedRequest = 0;
  int _selectedStudent = 0;
  final _replyInput = TextEditingController();

  final List<TeacherRequest> _requests = List.of(_teacherRequests);

  @override
  void dispose() {
    _replyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveShell(
      title: _teacherTitle(_section),
      subtitle: '先生画面：質問対応、コード採点確認、テスト結果分析',
      profileName: 'Admin（先生）',
      profileRole: '先生',
      activeIndex: TeacherSection.values.indexOf(_section),
      items: _teacherMenu,
      onSelect: (index) {
        setState(() => _section = TeacherSection.values[index]);
        Navigator.of(context).maybePop();
      },
      onLogout: _logout,
      middle: _teacherMiddlePanel(),
      content: _teacherContent(),
      topActions: [
        _SubjectSelector(
          value: '汎用プログラミング',
          values: const ['汎用プログラミング', 'Java', 'Web API'],
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _teacherMiddlePanel() {
    switch (_section) {
      case TeacherSection.pendingAi:
        return _HistoryPanel(
          title: 'AI会話未回答',
          actionLabel: '${_requests.where((e) => !e.answered).length}件',
          children: [
            for (var i = 0; i < _requests.length; i++)
              _CompactListCard(
                selected: _selectedRequest == i,
                title: _requests[i].student,
                subtitle: _requests[i].category,
                detail: _requests[i].question,
                badge: _requests[i].answered ? '回答済み' : '未回答',
                onTap: () => setState(() => _selectedRequest = i),
              ),
          ],
        );
      case TeacherSection.studentMessages:
        return _HistoryPanel(
          title: '学生',
          children: [
            for (var i = 0; i < _students.length; i++)
              _CompactListCard(
                selected: _selectedStudent == i,
                title: _students[i].name,
                subtitle: _students[i].status,
                detail: _students[i].lastQuestion,
                onTap: () => setState(() => _selectedStudent = i),
              ),
          ],
        );
      case TeacherSection.examAnalysis:
        return _HistoryPanel(
          title: 'テスト解答分析',
          children: [
            for (final report in _examReports)
              _CompactListCard(
                title: report.student,
                subtitle: '${report.score}点',
                detail: report.weakness,
                onTap: () {},
              ),
          ],
        );
      case TeacherSection.codeScoring:
      case TeacherSection.relearning:
      case TeacherSection.system:
      case TeacherSection.settings:
        return _HistoryPanel(
          title: '管理メニュー',
          children: [
            _CompactListCard(
              title: '採点待ちコード',
              subtitle: '6件',
              detail: '配列、Map、例外処理の課題',
              onTap: () {},
            ),
            _CompactListCard(
              title: 'AI再学習データ',
              subtitle: '12件',
              detail: '先生の回答を今後の AI 回答に反映予定',
              onTap: () {},
            ),
          ],
        );
    }
  }

  Widget _teacherContent() {
    switch (_section) {
      case TeacherSection.pendingAi:
        return _TeacherRequestWorkspace(
          request: _requests[_selectedRequest],
          controller: _replyInput,
          onSubmit: _answerRequest,
        );
      case TeacherSection.codeScoring:
        return _TeacherCodeReviewWorkspace(requests: _codeReviewItems);
      case TeacherSection.examAnalysis:
        return _ExamAnalysisWorkspace(reports: _examReports);
      case TeacherSection.studentMessages:
        return _TeacherChatWorkspace(student: _students[_selectedStudent]);
      case TeacherSection.relearning:
        return const _SimpleWorkspace(
          icon: Icons.auto_awesome_rounded,
          title: 'AI再学習',
          body:
              '先生が回答した内容は再学習用データとして整理されます。バックエンド API 接続後は、質の高い回答をナレッジベースへ送信できます。',
        );
      case TeacherSection.system:
        return const _SettingsWorkspace(
          role: 'システム管理',
          rows: [
            ('問題データ', 'Mock データ、API 接続待ち'),
            ('ユーザー管理', '学生・先生ロール'),
            ('確認フロー', 'AI が回答できない場合は先生へ連携'),
            ('対応プラットフォーム', 'Web / iOS / Android'),
          ],
        );
      case TeacherSection.settings:
        return const _SettingsWorkspace(
          role: '先生画面設定',
          rows: [
            ('通知', '未回答質問を通知'),
            ('デフォルト科目', '汎用プログラミング'),
            ('言語', '日本語'),
            ('テーマ', 'Light'),
          ],
        );
    }
  }

  void _answerRequest() {
    final text = _replyInput.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _requests[_selectedRequest] = _requests[_selectedRequest].copyWith(
        answered: true,
        teacherAnswer: text,
      );
      _replyInput.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('学生へ送信し、AI再学習資料として保存しました。')));
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }
}
