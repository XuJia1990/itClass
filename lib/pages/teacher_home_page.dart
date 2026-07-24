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
  UploadMaterialType _uploadType = UploadMaterialType.video;
  ProfileSettingSection _settingSection = ProfileSettingSection.profile;
  SystemManagementSection _systemSection =
      SystemManagementSection.createStudent;
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
      subtitle: '先生画面：質問対応、成績確認、学習資料管理、ユーザー管理',
      profileName: 'Admin（先生）',
      profileRole: '先生',
      activeIndex: TeacherSection.values.indexOf(_section),
      items: _teacherMenu,
      onSelect: (index) {
        setState(() => _section = TeacherSection.values[index]);
      },
      onLogout: _logout,
      middle: _teacherMiddlePanel(),
      content: _teacherContent(),
      topActions: const [],
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
      case TeacherSection.codeScoring:
        return _HistoryPanel(
          title: '管理メニュー',
          children: [
            _CompactListCard(
              title: '成績確認待ち',
              subtitle: '6件',
              detail: '配列、Map、例外処理の課題',
              onTap: () {},
            ),
            _CompactListCard(
              title: '学習資料アップロード',
              subtitle: '12件',
              detail: '教材、解説、サンプルコードを AI 学習用に登録',
              onTap: () {},
            ),
          ],
        );
      case TeacherSection.system:
        return _HistoryPanel(
          title: '学生管理',
          children: [
            _CompactListCard(
              selected: _systemSection == SystemManagementSection.createStudent,
              title: '新規学生作成',
              subtitle: 'アカウントとパスワード',
              detail: 'ここで学生名、メール、初期パスワード、連絡先を入力します。',
              onTap: () => setState(
                () => _systemSection = SystemManagementSection.createStudent,
              ),
            ),
            _CompactListCard(
              selected: _systemSection == SystemManagementSection.addExisting,
              title: '既存学生を追加',
              subtitle: '学生一覧から追加',
              detail: '既存学生を選択して現在のクラスに追加します。',
              onTap: () => setState(
                () => _systemSection = SystemManagementSection.addExisting,
              ),
            ),
            _CompactListCard(
              selected: _systemSection == SystemManagementSection.allStudents,
              title: '全学生',
              subtitle: 'アカウント一覧',
              detail: '全学生のメール、連絡先、初期パスワードを確認します。',
              onTap: () => setState(
                () => _systemSection = SystemManagementSection.allStudents,
              ),
            ),
          ],
        );
      case TeacherSection.settings:
        return _settingsMiddlePanel(
          selected: _settingSection,
          onSelect: (section) => setState(() => _settingSection = section),
        );
      case TeacherSection.relearning:
        return _HistoryPanel(
          title: 'アップロード機能',
          children: [
            _CompactListCard(
              selected: _uploadType == UploadMaterialType.video,
              title: '動画アップロード',
              subtitle: '授業録画',
              detail: '先生が録画した授業動画だけをアップロードします。',
              onTap: () =>
                  setState(() => _uploadType = UploadMaterialType.video),
            ),
            _CompactListCard(
              selected: _uploadType == UploadMaterialType.pdf,
              title: 'PDFアップロード',
              subtitle: '文書教材',
              detail: 'PDF教材だけをアップロードし、文書学習に反映します。',
              onTap: () => setState(() => _uploadType = UploadMaterialType.pdf),
            ),
            _CompactListCard(
              selected: _uploadType == UploadMaterialType.test,
              title: 'テストアップロード',
              subtitle: '選択問題',
              detail: 'AI生成・先生確認・編集後にテストをアップロードします。',
              onTap: () =>
                  setState(() => _uploadType = UploadMaterialType.test),
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
      case TeacherSection.studentMessages:
        return _TeacherChatWorkspace(student: _students[_selectedStudent]);
      case TeacherSection.relearning:
        return _LearningUploadWorkspace(type: _uploadType);
      case TeacherSection.system:
        return _UserRoleManagementWorkspace(section: _systemSection);
      case TeacherSection.settings:
        return _ProfileSettingsWorkspace(
          roleTitle: '先生設定',
          roleSubtitle: '名前、パスワード、アイコン、連絡先、メール、基本情報を変更できます。',
          initialName: 'Admin',
          initialEmail: 'teacher@example.com',
          initialPhone: '080-9999-0000',
          initialAvatar: 'teacher-avatar.png',
          initialBasicInfo: 'Java と Web API の授業を担当。学生の質問対応とテスト作成を管理します。',
          section: _settingSection,
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
