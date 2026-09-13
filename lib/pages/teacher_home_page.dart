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
  List<SchoolClassroom> _classrooms = const [];
  List<StudentProfile> _studentsFromApi = const [];
  List<CodeReviewItem> _codeReviewsFromApi = const [];
  bool _loading = false;
  String? _apiError;

  final List<TeacherRequest> _requests = [];

  List<StudentProfile> get _teacherStudents => _studentsFromApi;

  List<CodeReviewItem> get _teacherCodeReviews => _codeReviewsFromApi;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTeacherData());
  }

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
      profileName: '${ItClassSession.current?.realName ?? ''}（先生）',
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
            if (_apiError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _apiError!,
                  style: const TextStyle(color: _AppPalette.coral),
                ),
              ),
            if (_requests.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '未回答データがありません',
                message: 'バックエンドから先生対応が必要な AI 質問が返っていません。',
              ),
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
            if (_teacherStudents.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '学生データがありません',
                message: 'バックエンドに担当学生が登録されていません。',
              ),
            for (var i = 0; i < _teacherStudents.length; i++)
              _CompactListCard(
                selected: _selectedStudent == i,
                title: _teacherStudents[i].name,
                subtitle: _teacherStudents[i].status,
                detail: _teacherStudents[i].lastQuestion,
                onTap: () => setState(() => _selectedStudent = i),
              ),
          ],
        );
      case TeacherSection.codeScoring:
        return _HistoryPanel(
          title: '管理メニュー',
          children: [
            _CompactListCard(
              title: '成績確認',
              subtitle: '${_teacherCodeReviews.length}件',
              detail: 'バックエンドの提出履歴から採点状況を表示します。',
              onTap: () {},
            ),
            _CompactListCard(
              title: '学習資料アップロード',
              subtitle: '${_classrooms.length}クラス',
              detail: '担当クラスに動画、PDF、テストを登録します。',
              onTap: () => setState(() => _section = TeacherSection.relearning),
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
        if (_loading && _requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_requests.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: '未回答データがありません',
              message: '学生が AI に質問すると、先生対応が必要な質問がここに表示されます。',
            ),
          );
        }
        return _TeacherRequestWorkspace(
          request: _requests[_selectedRequest.clamp(0, _requests.length - 1)],
          controller: _replyInput,
          onSubmit: _answerRequest,
        );
      case TeacherSection.codeScoring:
        if (_loading && _codeReviewsFromApi.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _TeacherCodeReviewWorkspace(requests: _teacherCodeReviews);
      case TeacherSection.studentMessages:
        if (_loading && _teacherStudents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_teacherStudents.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: '学生データがありません',
              message: 'バックエンドに担当学生が登録されていません。',
            ),
          );
        }
        return _TeacherChatWorkspace(
          student:
              _teacherStudents[_selectedStudent.clamp(
                0,
                _teacherStudents.length - 1,
              )],
        );
      case TeacherSection.relearning:
        return _LearningUploadWorkspace(
          type: _uploadType,
          classrooms: _classrooms,
        );
      case TeacherSection.system:
        return _UserRoleManagementWorkspace(
          section: _systemSection,
          classrooms: _classrooms,
          initialStudents: _teacherStudents,
        );
      case TeacherSection.settings:
        return _ProfileSettingsWorkspace(
          roleTitle: '先生設定',
          roleSubtitle: '名前、パスワード、アイコン、連絡先、メール、基本情報を変更できます。',
          initialName: ItClassSession.current?.realName ?? '',
          initialEmail: ItClassSession.current?.email ?? '',
          initialPhone: ItClassSession.current?.mobile ?? '',
          initialAvatar: '',
          initialBasicInfo: '',
          section: _settingSection,
        );
    }
  }

  void _answerRequest() {
    final text = _replyInput.text.trim();
    if (text.isEmpty) return;
    final request = _requests[_selectedRequest];

    setState(() {
      _requests[_selectedRequest] = request.copyWith(
        answered: true,
        teacherAnswer: text,
      );
      _replyInput.clear();
    });

    if (request.questionId != null) {
      unawaited(_replyAiQuestion(request.questionId!, text));
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('学生へ送信し、AI再学習資料として保存しました。')));
  }

  Future<void> _replyAiQuestion(int questionId, String text) async {
    try {
      await ItClassApi.instance.replyAiQuestion(
        questionId: questionId,
        answer: text,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('API保存に失敗しました：$error')));
    }
  }

  Future<void> _loadTeacherData() async {
    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final classrooms = await ItClassApi.instance.myClassrooms();
      final classroomId = classrooms.isNotEmpty ? classrooms.first.id : null;
      final questions = await ItClassApi.instance.teacherAiQuestions(
        classroomId: classroomId,
      );
      final students = await ItClassApi.instance.simpleStudents();
      final contacts = await ItClassApi.instance.chatContacts(
        classroomId: classroomId,
      );
      final codeReviews = await ItClassApi.instance.examAttempts();
      if (!mounted) return;
      setState(() {
        _classrooms = classrooms;
        _requests
          ..clear()
          ..addAll(questions.list);
        _selectedRequest = 0;
        _studentsFromApi = contacts.isNotEmpty ? contacts : students;
        _codeReviewsFromApi = codeReviews.list;
        _selectedStudent = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _apiError = 'APIデータ取得に失敗しました：$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ItClassApi.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }
}
