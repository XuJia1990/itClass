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
  List<StudentProfile> _allStudentsFromApi = const [];
  List<CodeReviewItem> _codeReviewsFromApi = const [];
  bool _loading = false;
  bool _replySending = false;
  String? _apiError;
  StreamSubscription<ChatMessage>? _chatMessageSubscription;

  final List<TeacherRequest> _requests = [];

  List<StudentProfile> get _teacherStudents => _studentsFromApi;

  List<CodeReviewItem> get _teacherCodeReviews => _codeReviewsFromApi;

  @override
  void initState() {
    super.initState();
    _chatMessageSubscription = SchoolChatRealtime.instance.messages.listen(
      _handleRealtimeChatMessage,
    );
    unawaited(_loadTeacherData());
  }

  @override
  void dispose() {
    unawaited(_chatMessageSubscription?.cancel());
    _replyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveShell(
      title: _teacherTitle(_section),
      subtitle: '先生画面：質問対応、成績確認、学習資料管理、ユーザー管理',
      profileName: '${ItClassSession.current?.displayName ?? ''}（先生）',
      profileRole: '先生',
      activeIndex: TeacherSection.values.indexOf(_section),
      items: _teacherMenu,
      onSelect: (index) {
        setState(() => _section = TeacherSection.values[index]);
        if (_section == TeacherSection.studentMessages) {
          unawaited(_reloadChatStudents());
        }
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
          title: '学生のAI質問',
          actionLabel: '${_requests.where((e) => !e.answered).length}件未対応',
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
                title: '未回答の質問はありません',
                message: '学生からの質問はここに表示されます。',
              ),
            for (var i = 0; i < _requests.length; i++)
              _CompactListCard(
                selected: _selectedRequest == i,
                title: _requests[i].student,
                subtitle: _requests[i].category,
                detail: _requests[i].question,
                badge: _requests[i].answered ? '先生回答済み' : '先生未回答',
                onTap: () => setState(() => _selectedRequest = i),
              ),
          ],
        );
      case TeacherSection.studentMessages:
        return _HistoryPanel(
          title: '学生（直接チャット）',
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loading ? null : _reloadChatStudents,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('会話一覧を更新'),
              ),
            ),
            if (_teacherStudents.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '会話はありません',
                message: '学生からの相談はここに表示されます。',
              ),
            for (var i = 0; i < _teacherStudents.length; i++)
              _CompactListCard(
                selected: _selectedStudent == i,
                title: _teacherStudents[i].name,
                subtitle: _teacherStudents[i].status,
                detail: _teacherStudents[i].lastQuestion,
                showNotificationDot: _teacherStudents[i].unreadCount > 0,
                onTap: () => _selectChatStudent(i),
              ),
          ],
        );
      case TeacherSection.codeScoring:
        return _HistoryPanel(
          title: '管理メニュー',
          children: [
            _CompactListCard(
              selected: true,
              title: '成績確認',
              subtitle: '${_teacherCodeReviews.length}件',
              detail: '学生の提出履歴と採点状況を確認します。',
              onTap: () => unawaited(_loadTeacherData()),
            ),
            _CompactListCard(
              title: '学習資料アップロード',
              subtitle: '共通教材',
              detail: '動画、文書教材、テスト',
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
              selected: _systemSection == SystemManagementSection.allStudents,
              title: '全学生',
              subtitle: 'アカウント一覧',
              detail: '全学生のアカウント、メール、連絡先を確認します。',
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
          title: '教材管理',
          children: [
            _CompactListCard(
              selected: _uploadType == UploadMaterialType.video,
              title: '動画アップロード',
              subtitle: '共通の授業動画',
              detail: '登録・編集・担当講師',
              onTap: () =>
                  setState(() => _uploadType = UploadMaterialType.video),
            ),
            _CompactListCard(
              selected: _uploadType == UploadMaterialType.pdf,
              title: '文書教材アップロード',
              subtitle: '文書教材',
              detail: 'PDF、PowerPoint、Word をアップロードし、文書学習に反映します。',
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
              message: '学生が AI に質問した履歴のうち、先生が未回答の質問がここに表示されます。',
            ),
          );
        }
        return _TeacherRequestWorkspace(
          request: _requests[_selectedRequest.clamp(0, _requests.length - 1)],
          controller: _replyInput,
          sending: _replySending,
          onSubmit: () => unawaited(_answerRequest()),
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
              message: '学生からの相談はここに表示されます。',
            ),
          );
        }
        return _TeacherChatWorkspace(
          onRead: (conversationId) {
            if (!mounted) return;
            setState(
              () => _studentsFromApi = _studentsFromApi
                  .map(
                    (student) => student.conversationId == conversationId
                        ? student.copyWith(unreadCount: 0)
                        : student,
                  )
                  .toList(),
            );
          },
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
          allStudents: _allStudentsFromApi,
          onChanged: _loadTeacherData,
        );
      case TeacherSection.settings:
        return _ProfileSettingsWorkspace(
          roleTitle: '先生設定',
          roleSubtitle: 'プロフィール、アイコン、連絡先、パスワードを変更できます。',
          initialRealName: ItClassSession.current?.realName ?? '',
          initialNickname: ItClassSession.current?.nickname ?? '',
          initialEmail: ItClassSession.current?.email ?? '',
          initialPhone: ItClassSession.current?.mobile ?? '',
          initialAvatar: ItClassSession.current?.avatar ?? '',
          initialBasicInfo: ItClassSession.current?.programmingLanguage ?? '',
          section: _settingSection,
          onProfileChanged: (profile) {
            setState(() => ItClassSession.updateProfile(profile));
          },
        );
    }
  }

  Future<void> _answerRequest() async {
    final text = _replyInput.text.trim();
    if (text.isEmpty || _replySending || _requests.isEmpty) return;
    final request = _requests[_selectedRequest];
    setState(() => _replySending = true);
    try {
      if (request.questionId == null) {
        throw const ApiException('質問を選択してください。');
      }
      await ItClassApi.instance.replyAiQuestion(
        questionId: request.questionId!,
        answer: text,
      );
      if (!mounted) return;
      setState(() {
        final index = _requests.indexWhere(
          (item) => item.questionId == request.questionId,
        );
        if (index >= 0) {
          _requests[index] = _requests[index].copyWith(
            answered: true,
            teacherAnswer: text,
            teacherReplies: [..._requests[index].teacherReplies, text],
          );
        }
        if (_requests[_selectedRequest].questionId == request.questionId &&
            _replyInput.text.trim() == text) {
          _replyInput.clear();
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('学生への回答を保存しました。')));
      // Refresh after a successful write without resending it if the read fails.
      try {
        final updated = await ItClassApi.instance.teacherAiQuestion(
          request.questionId!,
        );
        if (!mounted) return;
        final index = _requests.indexWhere(
          (item) => item.questionId == request.questionId,
        );
        if (index >= 0) setState(() => _requests[index] = updated);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '回答は保存されました。履歴の更新に失敗しました：${userFacingError(error)}',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('回答を保存できませんでした：${userFacingError(error)}')),
      );
    } finally {
      if (mounted) setState(() => _replySending = false);
    }
  }

  Future<void> _loadTeacherData() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _apiError = null;
    });
    final errors = <String>[];
    Future<void> load<T>(
      String label,
      Future<T> Function() fetch,
      void Function(T) apply,
    ) async {
      try {
        final data = await fetch();
        if (mounted) setState(() => apply(data));
      } catch (error) {
        errors.add('$label：${userFacingError(error)}');
      }
    }

    await Future.wait([
      load(
        '教室',
        ItClassApi.instance.myClassrooms,
        (value) => _classrooms = value,
      ),
      load('AI質問', () => ItClassApi.instance.teacherAiQuestions(), (value) {
        _requests
          ..clear()
          ..addAll(value.list);
        _selectedRequest = 0;
      }),
      load(
        '学生',
        ItClassApi.instance.simpleStudents,
        (value) => _allStudentsFromApi = value,
      ),
      load('会話', () => ItClassApi.instance.chatContacts(), (value) {
        final selected = _selectedChatConversationId;
        _studentsFromApi = value;
        _selectedStudent = _indexOfConversation(value, selected);
      }),
      load(
        '成績',
        ItClassApi.instance.examAttempts,
        (value) => _codeReviewsFromApi = value.list,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _apiError = errors.isEmpty
          ? null
          : '一部のデータを読み込めませんでした。\n${errors.join('\n')}';
    });
  }

  int? get _selectedChatConversationId {
    if (_studentsFromApi.isEmpty) return null;
    return _studentsFromApi[_selectedStudent.clamp(
          0,
          _studentsFromApi.length - 1,
        )]
        .conversationId;
  }

  int _indexOfConversation(List<StudentProfile> students, int? conversationId) {
    if (students.isEmpty || conversationId == null) return 0;
    final index = students.indexWhere(
      (student) => student.conversationId == conversationId,
    );
    return index < 0 ? 0 : index;
  }

  void _selectChatStudent(int index) {
    setState(() {
      _selectedStudent = index;
    });
  }

  void _handleRealtimeChatMessage(ChatMessage message) {
    if (!mounted || message.author != MessageAuthor.student) return;
    final selectedConversationId = _selectedChatConversationId;
    final index = _studentsFromApi.indexWhere(
      (student) => student.conversationId == message.conversationId,
    );
    if (index < 0) {
      unawaited(_reloadChatStudents());
      return;
    }
    final current = _studentsFromApi[index];
    final updated = current.copyWith(
      lastQuestion: message.text,
      unreadCount: current.unreadCount + 1,
      lastMessageTime: DateTime.now(),
    );
    final students = List<StudentProfile>.of(_studentsFromApi)
      ..removeAt(index)
      ..insert(0, updated);
    setState(() {
      _studentsFromApi = students;
      _selectedStudent = _indexOfConversation(students, selectedConversationId);
    });
  }

  Future<void> _reloadChatStudents() async {
    try {
      final contacts = await ItClassApi.instance.chatContacts();
      if (!mounted) return;
      final selectedConversationId = _selectedChatConversationId;
      final students = contacts;
      setState(() {
        _studentsFromApi = students;
        _selectedStudent = _indexOfConversation(
          students,
          selectedConversationId,
        );
      });
    } catch (error) {
      debugPrint('[itClass chat] contact refresh failed: $error');
    }
  }

  Future<void> _logout() async {
    await ItClassApi.instance.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
