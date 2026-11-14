part of '../main.dart';

enum _TeacherMaterialKind {
  video('course-video', 'video', '動画'),
  document('course-document', 'document', '文書教材');

  const _TeacherMaterialKind(this.path, this.filePrefix, this.label);
  final String path;
  final String filePrefix;
  final String label;
  bool get isVideo => this == video;
  String get urlField => '${filePrefix}Url';
  String get pathField => '${filePrefix}Path';
}

extension TeacherSharedResourceApi on ItClassApi {
  Future<List<ResourceTeacher>> simpleResourceTeachers() async {
    final data = await _get<List<dynamic>>(
      '/school/account/teacher/list-simple',
    );
    return data
        .map((item) => ResourceTeacher.fromJson(_asMap(item)))
        .where((teacher) => teacher.accountId > 0 && teacher.status == 0)
        .toList();
  }

  Future<ApiPage<Map<String, dynamic>>> _teacherMaterials(
    _TeacherMaterialKind kind, {
    int pageNo = 1,
    String title = '',
    int? status,
    List<String>? languages,
  }) async {
    if (languages != null && languages.isEmpty) {
      return const ApiPage(list: [], total: 0);
    }
    final data = await _get<Map<String, dynamic>>(
      '/school/${kind.path}/teacher-page',
      query: {
        'pageNo': '$pageNo',
        'pageSize': '20',
        if (title.isNotEmpty) 'title': title,
        if (status != null) 'status': '$status',
        if (languages != null) 'programmingLanguages': languages.join(','),
      },
    );
    return _page(data, (item) => item);
  }

  Future<Map<String, dynamic>> _teacherMaterial(
    _TeacherMaterialKind kind,
    int id,
  ) => _get<Map<String, dynamic>>(
    '/school/${kind.path}/teacher-get',
    query: {'id': '$id'},
  );

  Future<void> _saveTeacherMaterial(
    _TeacherMaterialKind kind,
    Map<String, dynamic> payload, {
    required bool creating,
  }) async {
    if (creating) {
      await _post<dynamic>(
        '/school/${kind.path}/teacher-create',
        body: payload,
      );
    } else {
      await _put<dynamic>('/school/${kind.path}/teacher-update', body: payload);
    }
  }
}

Set<int> _currentResponsibleTeacherIds() {
  final id = ItClassSession.current?.schoolAccountId;
  return {if (id != null && id > 0) id};
}

List<ResourceTeacher> _currentResponsibleTeachers() {
  final session = ItClassSession.current;
  return [
    if (session != null && session.schoolAccountId > 0)
      ResourceTeacher(
        accountId: session.schoolAccountId,
        realName: session.displayName,
      ),
  ];
}

String _responsibleTeacherLabel(ResourceTeacher teacher) {
  final name = teacher.realName.trim();
  final account = teacher.accountNo.trim();
  return [
    if (name.isNotEmpty) name,
    if (account.isNotEmpty) account,
    if (name.isEmpty && account.isEmpty) '担当講師',
  ].join(' · ');
}

/// Uses school-account IDs, never member user IDs or login names.
class _ResponsibleTeacherPicker extends StatefulWidget {
  const _ResponsibleTeacherPicker({
    required this.selectedIds,
    required this.onChanged,
    this.existingTeachers = const [],
    this.enabled = true,
  });

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onChanged;
  final List<ResourceTeacher> existingTeachers;
  final bool enabled;

  @override
  State<_ResponsibleTeacherPicker> createState() =>
      _ResponsibleTeacherPickerState();
}

class _ResponsibleTeacherPickerState extends State<_ResponsibleTeacherPicker> {
  List<ResourceTeacher> _teachers = const [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final teachers = await ItClassApi.instance.simpleResourceTeachers();
      if (!mounted) return;
      setState(() => _teachers = teachers);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '講師一覧を取得できませんでした：${userFacingError(error)}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final known = {
      for (final teacher in widget.existingTeachers) teacher.accountId: teacher,
      for (final teacher in _teachers) teacher.accountId: teacher,
    };
    final choices = _teachers
        .where(
          (teacher) => _responsibleTeacherLabel(
            teacher,
          ).toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '担当講師（1名以上・複数選択可）',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final id in widget.selectedIds)
              InputChip(
                label: Text(
                  known[id] == null
                      ? '担当講師（詳細未取得）'
                      : _responsibleTeacherLabel(known[id]!),
                ),
                onDeleted: widget.enabled
                    ? () =>
                          widget.onChanged({...widget.selectedIds}..remove(id))
                    : null,
              ),
          ],
        ),
        if (widget.selectedIds.isEmpty)
          const Text('担当講師を選択してください。', style: TextStyle(color: Colors.red)),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        else if (_error != null) ...[
          Text('$_error\n選択済みの担当講師は保持されています。'),
          TextButton.icon(
            onPressed: widget.enabled ? _load : null,
            icon: const Icon(Icons.refresh),
            label: const Text('講師一覧を再取得'),
          ),
        ] else if (_teachers.isEmpty)
          const Text('選択できる有効な講師がいません。')
        else ...[
          const SizedBox(height: 8),
          TextField(
            enabled: widget.enabled,
            decoration: const InputDecoration(
              labelText: '講師名・アカウントで検索',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 190),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final teacher in choices)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_responsibleTeacherLabel(teacher)),
                    value: widget.selectedIds.contains(teacher.accountId),
                    onChanged: widget.enabled
                        ? (selected) {
                            final ids = {...widget.selectedIds};
                            if (selected == true) {
                              if (ids.length >= 100) return;
                              ids.add(teacher.accountId);
                            } else {
                              ids.remove(teacher.accountId);
                            }
                            widget.onChanged(ids);
                          }
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TeacherMaterialManagement extends StatefulWidget {
  const _TeacherMaterialManagement({
    super.key,
    required this.kind,
    required this.classrooms,
    required this.languages,
  });
  final _TeacherMaterialKind kind;
  final List<SchoolClassroom> classrooms;
  final List<String> languages;

  @override
  State<_TeacherMaterialManagement> createState() =>
      _TeacherMaterialManagementState();
}

class _TeacherMaterialManagementState
    extends State<_TeacherMaterialManagement> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = const [];
  int _page = 1;
  int _total = 0;
  int? _status;
  bool _loading = true;
  String? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _TeacherMaterialManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languages.join(',') != widget.languages.join(',')) {
      unawaited(_load(page: 1));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    final request = ++_request;
    setState(() {
      _page = page ?? _page;
      _loading = true;
      _error = null;
    });
    try {
      final result = await ItClassApi.instance._teacherMaterials(
        widget.kind,
        pageNo: _page,
        title: _search.text.trim(),
        status: _status,
        languages: widget.languages,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _items = result.list;
        _total = result.total;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() => _error = userFacingError(error));
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<bool> _edit({int? id, PlatformFile? file}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TeacherMaterialEditor(
        kind: widget.kind,
        id: id,
        newFile: file,
        classrooms: widget.classrooms,
      ),
    );
    if (saved != true) return false;
    if (mounted) await _load(page: id == null ? 1 : _page);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.kind.isVideo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UploadDropZone(
          icon: video ? Icons.video_file_rounded : Icons.description_rounded,
          title: '${widget.kind.label}をアップロード',
          subtitle: video
              ? 'MP4 / MOV を登録します。教室の所属に関係なく学生が閲覧できます。'
              : 'PDF / PPT / PPTX / DOC / DOCX を登録します。教室の指定は任意です。',
          buttonLabel: 'ファイルを選択',
          allowedExtensions: video
              ? const ['mp4', 'mov']
              : const ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
          fileType: FileType.custom,
          onUpload: (file) => _edit(file: file),
        ),
        const SizedBox(height: 24),
        Text(
          '共有${widget.kind.label}一覧',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text('他の講師が登録した教材も編集できます。停用中の教材も表示されます。'),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onSubmitted: (_) => _load(page: 1),
          decoration: InputDecoration(
            labelText: 'タイトルで検索',
            suffixIcon: IconButton(
              tooltip: '検索',
              onPressed: () => _load(page: 1),
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final entry in const {-1: 'すべて', 0: '公開中', 1: '停用中'}.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: (_status ?? -1) == entry.key,
                onSelected: (_) {
                  setState(() => _status = entry.key == -1 ? null : entry.key);
                  unawaited(_load(page: 1));
                },
              ),
            IconButton(
              tooltip: '一覧を再読み込み',
              onPressed: _loading ? null : () => _load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_loading)
          const LinearProgressIndicator()
        else if (_error != null)
          _InlineNotice(
            tone: _NoticeTone.warning,
            title: '教材一覧を取得できませんでした',
            message: _error!,
          )
        else if (_items.isEmpty)
          const Text('該当する教材がありません。')
        else
          for (final item in _items)
            Card(
              child: ListTile(
                isThreeLine: true,
                title: Text(_asString(item['title'])),
                subtitle: Text(
                  [
                    '${_asInt(item['status']) == 0 ? '公開中' : '停用中'} · '
                        '${_asString(item['programmingLanguage'])} · '
                        '第${item['chapterNo']}章',
                    _asList(item['teachers'])
                        .map(
                          (teacher) => _responsibleTeacherLabel(
                            ResourceTeacher.fromJson(_asMap(teacher)),
                          ),
                        )
                        .join('、'),
                  ].join('\n'),
                ),
                trailing: IconButton(
                  tooltip: '詳細を取得して編集',
                  onPressed: _asInt(item['id']) == null
                      ? null
                      : () => _edit(id: _asInt(item['id'])),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _loading || _page <= 1
                  ? null
                  : () => _load(page: _page - 1),
              child: const Text('前へ'),
            ),
            Text('$_page ページ / 全 $_total 件'),
            OutlinedButton(
              onPressed: _loading || _page * 20 >= _total
                  ? null
                  : () => _load(page: _page + 1),
              child: const Text('次へ'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeacherMaterialEditor extends StatefulWidget {
  const _TeacherMaterialEditor({
    required this.kind,
    required this.classrooms,
    this.id,
    this.newFile,
  });
  final _TeacherMaterialKind kind;
  final List<SchoolClassroom> classrooms;
  final int? id;
  final PlatformFile? newFile;

  @override
  State<_TeacherMaterialEditor> createState() => _TeacherMaterialEditorState();
}

class _TeacherMaterialEditorState extends State<_TeacherMaterialEditor> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _language = TextEditingController();
  final _chapter = TextEditingController();
  final _sort = TextEditingController();
  final _duration = TextEditingController();
  final _cover = TextEditingController();
  Map<String, dynamic>? _original;
  Set<int> _teacherIds = {};
  List<ResourceTeacher> _teachers = const [];
  int? _classroomId;
  int _status = 0;
  PlatformFile? _replacement;
  Map<String, dynamic>? _uploadedFile;
  bool _uploadingCover = false;
  bool _loading = false;
  bool _saving = false;
  bool _conflict = false;
  String? _error;
  int _formRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.id == null) {
      _apply({
        'title': widget.newFile?.name ?? '',
        'chapterNo': 1,
        'sort': 0,
        'durationSeconds': 0,
        'status': 0,
        'teacherAccountIds': _currentResponsibleTeacherIds().toList(),
      });
      _teachers = _currentResponsibleTeachers();
      _replacement = widget.newFile;
    } else {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _language,
      _chapter,
      _sort,
      _duration,
      _cover,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _apply(Map<String, dynamic> data) {
    _original = Map.of(data);
    _title.text = _asString(data['title']);
    _description.text = _asString(data['description']);
    _language.text = _asString(data['programmingLanguage']);
    _chapter.text = '${_asInt(data['chapterNo']) ?? 1}';
    _sort.text = '${_asInt(data['sort']) ?? 0}';
    _duration.text = '${_asInt(data['durationSeconds']) ?? 0}';
    // teacher-get signs coverUrl as well as playUrl. Only store its permanent URL.
    _cover.text = _permanentMaterialUrl(_asString(data['coverUrl']));
    _classroomId = _asInt(data['classroomId']);
    _status = _asInt(data['status']) ?? 0;
    _teacherIds = _asList(
      data['teacherAccountIds'],
    ).map(_asInt).whereType<int>().toSet();
    _teachers = _asList(
      data['teachers'],
    ).map((item) => ResourceTeacher.fromJson(_asMap(item))).toList();
    _replacement = null;
    _uploadedFile = null;
    _conflict = false;
    _formRevision++;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ItClassApi.instance._teacherMaterial(
        widget.kind,
        widget.id!,
      );
      if (_asInt(data['id']) != widget.id ||
          _asInt(data['version']) == null ||
          ![0, 1].contains(_asInt(data['status']))) {
        throw const ApiException('教材の編集情報が不完全です。再取得してください。');
      }
      if (!mounted) return;
      setState(() => _apply(data));
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadAfterConflict() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('最新の内容を読み込みますか？'),
        content: const Text(
          'この画面の未保存の変更は破棄されます。最新の内容を確認し、必要な変更を入力してから保存してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('戻る'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('変更を破棄して再読み込み'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _load();
  }

  Future<void> _pickReplacement() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.kind.isVideo
            ? ['mp4', 'mov']
            : ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      setState(() {
        _replacement = result.files.single;
        _uploadedFile = null;
        if (widget.kind.isVideo) _duration.text = '0';
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'ファイルを選択できませんでした：${userFacingError(error)}');
      }
    }
  }

  Future<void> _chooseCover() async {
    if (_uploadingCover || _saving || _conflict) return;
    setState(() => _uploadingCover = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      final url = await ItClassApi.instance.uploadFile(
        result.files.single,
        directory: 'itclass/covers',
      );
      if (mounted) setState(() => _cover.text = url);
    } catch (error) {
      if (mounted) {
        setState(() => _error = '表紙画像を変更できませんでした：${userFacingError(error)}');
      }
    } finally {
      if (mounted) setState(() => _uploadingCover = false);
    }
  }

  Future<void> _save() async {
    if (_saving ||
        _uploadingCover ||
        _conflict ||
        _loading ||
        _original == null) {
      return;
    }
    if (!_form.currentState!.validate()) return;
    if (_teacherIds.isEmpty || _teacherIds.length > 100) {
      setState(() => _error = '担当講師を1〜100名選択してください。');
      return;
    }
    if (_replacement == null &&
        _asString(_original![widget.kind.urlField]).isEmpty) {
      setState(() => _error = '教材ファイルを選択してください。');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final file = _replacement;
      if (file != null && _uploadedFile == null) {
        final url = await ItClassApi.instance.uploadFile(
          file,
          directory: widget.kind.path,
        );
        // Cache a successful upload if the subsequent resource save fails.
        _uploadedFile = {
          widget.kind.urlField: _permanentMaterialUrl(url),
          widget.kind.pathField: _permanentMaterialUrl(url),
          'fileName': file.name,
          'fileSize': file.size,
          'contentType': _contentType(file),
        };
      }
      final original = _original!;
      final payload = <String, dynamic>{
        if (widget.id != null) 'id': widget.id,
        if (widget.id != null) 'version': original['version'],
        if (widget.id != null) 'status': _status,
        'classroomId': _classroomId,
        'programmingLanguage': _language.text.trim(),
        'teacherAccountIds': _teacherIds.toList(),
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'chapterNo': int.parse(_chapter.text.trim()),
        'sort': int.parse(_sort.text.trim()),
        widget.kind.urlField: original[widget.kind.urlField],
        widget.kind.pathField: original[widget.kind.pathField],
        'fileName': original['fileName'],
        'fileSize': original['fileSize'],
        'contentType': original['contentType'],
        if (widget.kind.isVideo) ...{
          'durationSeconds': int.parse(_duration.text.trim()),
          'coverUrl': _permanentMaterialUrl(_cover.text.trim()),
        },
        ...?_uploadedFile,
      };
      // Never copy playUrl/accessUrl, response-only teachers, or creator IDs.
      await ItClassApi.instance._saveTeacherMaterial(
        widget.kind,
        payload,
        creating: widget.id == null,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _conflict = error is ApiException && error.code == 1004002045;
        _error = _conflict
            ? '他の講師が内容を更新しました。最新の内容を再読み込みし、確認してから保存してください。'
            : userFacingError(error);
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _saving || _uploadingCover;
    final unknownClassroom =
        _classroomId != null &&
        !widget.classrooms.any((item) => item.id == _classroomId);
    return PopScope(
      canPop: !_saving && !_uploadingCover,
      child: AlertDialog(
        title: Text('${widget.kind.label}${widget.id == null ? 'を登録' : 'を編集'}'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading) const LinearProgressIndicator(),
                if (_error != null) ...[
                  _InlineNotice(
                    tone: _NoticeTone.warning,
                    title: _conflict ? '編集内容が競合しました' : '処理を完了できませんでした',
                    message: _error!,
                  ),
                  if (_conflict)
                    TextButton.icon(
                      onPressed: busy ? null : _reloadAfterConflict,
                      icon: const Icon(Icons.refresh),
                      label: const Text('最新の内容を再読み込み'),
                    )
                  else if (_original == null)
                    TextButton(
                      onPressed: busy ? null : _load,
                      child: const Text('再取得'),
                    ),
                  const SizedBox(height: 12),
                ],
                if (_original != null)
                  AbsorbPointer(
                    absorbing: busy || _conflict,
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _textField(
                            _title,
                            'タイトル',
                            maxLength: 128,
                            required: true,
                          ),
                          _textField(
                            _description,
                            '説明',
                            maxLength: 1000,
                            lines: 3,
                          ),
                          _textField(
                            _language,
                            'プログラミング言語（分類・任意）',
                            maxLength: 64,
                          ),
                          DropdownButtonFormField<int>(
                            key: ValueKey('classroom-$_formRevision'),
                            initialValue: _classroomId ?? -1,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: '教室（任意の分類）',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: -1,
                                child: Text('指定なし'),
                              ),
                              for (final classroom in widget.classrooms)
                                DropdownMenuItem(
                                  value: classroom.id,
                                  child: Text(classroom.name),
                                ),
                              if (unknownClassroom)
                                DropdownMenuItem(
                                  value: _classroomId,
                                  child: const Text('現在の分類（変更なし）'),
                                ),
                            ],
                            onChanged: (value) => setState(
                              () => _classroomId = value == -1 ? null : value,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _numberField(_chapter, '章番号', minimum: 1),
                          _numberField(_sort, '表示順'),
                          if (widget.kind.isVideo) ...[
                            _numberField(_duration, '動画の長さ（秒・0は未設定）'),
                            const Text('表紙画像（任意）'),
                            if (_cover.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Image.network(
                                  _cover.text,
                                  height: 90,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) =>
                                      const Text('画像を表示できませんでした。選び直してください。'),
                                ),
                              ),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: busy ? null : _chooseCover,
                                  icon: const Icon(Icons.image_outlined),
                                  label: Text(
                                    _uploadingCover ? 'アップロード中' : '表紙画像を選択',
                                  ),
                                ),
                                if (_cover.text.isNotEmpty)
                                  TextButton(
                                    onPressed: busy
                                        ? null
                                        : () => setState(_cover.clear),
                                    child: const Text('表紙画像を外す'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            'ファイル：${_replacement?.name ?? _original!['fileName'] ?? '未登録'}',
                          ),
                          if (_replacement == null) ...[
                            Text(
                              '${_original!['fileSize'] ?? 0} bytes · ${_original!['contentType'] ?? ''}',
                            ),
                          ],
                          OutlinedButton.icon(
                            onPressed: _pickReplacement,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('教材ファイルを選び直す'),
                          ),
                          if (widget.kind.isVideo &&
                              widget.id != null &&
                              _replacement != null)
                            const Text('動画を差し替えると、新しいファイルの学習進捗は0から始まります。'),
                          const SizedBox(height: 16),
                          _ResponsibleTeacherPicker(
                            selectedIds: _teacherIds,
                            existingTeachers: _teachers,
                            enabled: !busy && !_conflict,
                            onChanged: (ids) =>
                                setState(() => _teacherIds = ids),
                          ),
                          const SizedBox(height: 12),
                          if (widget.id != null)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('学生に公開'),
                              subtitle: Text(_status == 0 ? '公開中' : '停用中'),
                              value: _status == 0,
                              onChanged: (value) =>
                                  setState(() => _status = value ? 0 : 1),
                            )
                          else
                            const Text('保存が完了すると、すべての正常な学生に公開されます。'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving || _uploadingCover
                ? null
                : () => Navigator.pop(context, false),
            child: const Text('閉じる'),
          ),
          FilledButton.icon(
            onPressed: busy || _conflict || _original == null ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? '保存中' : '保存'),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    required int maxLength,
    bool required = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        maxLength: maxLength,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            required && (value ?? '').trim().isEmpty ? '入力してください。' : null,
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    int minimum = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        validator: (value) {
          final number = int.tryParse((value ?? '').trim());
          return number == null || number < minimum
              ? '$minimum 以上の整数を入力してください。'
              : null;
        },
      ),
    );
  }
}

String _permanentMaterialUrl(String value) {
  // The backend strips query strings from stored file URLs too. Avoid persisting
  // signed GET credentials, including the signed cover returned by teacher-get.
  return value.split('?').first.split('#').first;
}

// These editors deliberately preserve the existing question options/test cases
// and paper question ordering/scores. They are shared maintenance forms, not a
// second assessment builder.
enum _TeacherAssessmentKind {
  question('question', '問題'),
  paper('paper', '試験用紙'),
  exam('exam', '試験');

  const _TeacherAssessmentKind(this.path, this.label);
  final String path;
  final String label;

  List<String> get saveFields => [
    'id',
    'version',
    'title',
    'teacherAccountIds',
    ...switch (this) {
      question => [
        'programmingLanguage',
        'type',
        'difficulty',
        'content',
        'referenceAnswer',
        'acceptableAnswers',
        'analysis',
        'defaultScore',
        'status',
        'options',
        'testCases',
      ],
      paper => [
        'classroomId',
        'programmingLanguage',
        'description',
        'durationMinutes',
        'status',
        'questions',
      ],
      exam => [
        'paperId',
        'description',
        'durationMinutes',
        'passScore',
        'maxAttempts',
        'shuffleQuestions',
        'shuffleOptions',
        'resultPublishType',
        'showAnswer',
      ],
    },
  ];

  String statusLabel(int? status) => switch (this) {
    question => status == 0 ? '有効' : '停用中',
    paper => switch (status) {
      0 => '草稿',
      10 => '使用可能',
      _ => 'アーカイブ',
    },
    exam => switch (status) {
      0 => '草稿',
      10 => '公開中',
      _ => '終了',
    },
  };
}

extension _TeacherAssessmentApi on ItClassApi {
  Future<ApiPage<Map<String, dynamic>>> _assessmentPage(
    _TeacherAssessmentKind kind,
    int page,
    String title,
    bool mine, {
    List<String>? languages,
  }) async {
    if (languages != null && languages.isEmpty) {
      return const ApiPage(list: [], total: 0);
    }
    final data = await _get<Map<String, dynamic>>(
      '/school/exam-teacher/${kind.path}/page',
      query: {
        'pageNo': '$page',
        'pageSize': '20',
        if (title.isNotEmpty) 'title': title,
        if (mine && kind != _TeacherAssessmentKind.question) 'mine': 'true',
        if (languages != null) 'programmingLanguages': languages.join(','),
      },
    );
    return _page(data, (item) => item);
  }

  Future<Map<String, dynamic>> _assessmentDetail(
    _TeacherAssessmentKind kind,
    int id,
  ) => _get<Map<String, dynamic>>(
    '/school/exam-teacher/${kind.path}/get',
    query: {'id': '$id'},
  );

  Future<void> _saveAssessment(
    _TeacherAssessmentKind kind,
    Map<String, dynamic> payload,
  ) async {
    await _post<dynamic>(
      '/school/exam-teacher/${kind.path}/save',
      body: payload,
    );
  }

  Future<void> _closeSharedExam(int id) async {
    await _put<dynamic>(
      '/school/exam-teacher/exam/close',
      query: {'id': '$id'},
    );
  }
}

class _TeacherAssessmentManagement extends StatefulWidget {
  const _TeacherAssessmentManagement({super.key, required this.languages});
  final List<String> languages;
  @override
  State<_TeacherAssessmentManagement> createState() =>
      _TeacherAssessmentManagementState();
}

class _TeacherAssessmentManagementState
    extends State<_TeacherAssessmentManagement>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _search = TextEditingController();
  _TeacherAssessmentKind _kind = _TeacherAssessmentKind.exam;
  List<Map<String, dynamic>> _items = const [];
  int _page = 1;
  int _total = 0;
  int _request = 0;
  bool _loading = false;
  bool _mine = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _TeacherAssessmentManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languages.join(',') != widget.languages.join(',')) {
      unawaited(_load(page: 1));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    final request = ++_request;
    setState(() {
      _page = page ?? _page;
      _loading = true;
      _error = null;
    });
    try {
      final result = await ItClassApi.instance._assessmentPage(
        _kind,
        _page,
        _search.text.trim(),
        _mine,
        languages: widget.languages,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _items = result.list;
        _total = result.total;
      });
    } catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = userFacingError(error));
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _edit(int id) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TeacherAssessmentEditor(kind: _kind, id: id),
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('問題・試験用紙・試験', style: Theme.of(context).textTheme.titleLarge),
      if (_kind != _TeacherAssessmentKind.question)
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('自分が作成')),
            ButtonSegment(value: false, label: Text('すべて')),
          ],
          selected: {_mine},
          onSelectionChanged: (values) {
            setState(() => _mine = values.first);
            unawaited(_load(page: 1));
          },
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final kind in _TeacherAssessmentKind.values)
            ChoiceChip(
              label: Text(kind.label),
              selected: kind == _kind,
              onSelected: (_) {
                setState(() => _kind = kind);
                unawaited(_load(page: 1));
              },
            ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _search,
        onSubmitted: (_) => _load(page: 1),
        decoration: InputDecoration(
          labelText: 'タイトルで検索',
          suffixIcon: IconButton(
            tooltip: '検索・再読み込み',
            onPressed: () => _load(page: 1),
            icon: const Icon(Icons.search),
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (_loading)
        const LinearProgressIndicator()
      else if (_error != null)
        _InlineNotice(
          tone: _NoticeTone.warning,
          title: '取得に失敗しました',
          message: _error!,
        )
      else if (_items.isEmpty)
        const Text('該当するデータがありません。')
      else
        for (final item in _items)
          Card(
            child: ListTile(
              title: Text(_asString(item['title'])),
              subtitle: Text(
                '${_kind.statusLabel(_asInt(item['status']))}\n'
                '${_asList(item['teachers']).map((teacher) => _responsibleTeacherLabel(ResourceTeacher.fromJson(_asMap(teacher)))).join('、')}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_kind == _TeacherAssessmentKind.exam &&
                      _asInt(item['status']) == 10)
                    IconButton(
                      tooltip: '試しに受験',
                      icon: const Icon(Icons.play_arrow_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _TeacherExamTrialPage(
                            examId: _asInt(item['id'])!,
                          ),
                        ),
                      ),
                    ),
                  if (_kind == _TeacherAssessmentKind.question ||
                      item['editable'] == true)
                    IconButton(
                      tooltip: '最新の内容を取得して編集',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _asInt(item['id']) == null
                          ? null
                          : () => _edit(_asInt(item['id'])!),
                    )
                  else
                    const Icon(Icons.lock_outline),
                ],
              ),
            ),
          ),
      Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton(
            onPressed: _loading || _page <= 1
                ? null
                : () => _load(page: _page - 1),
            child: const Text('前へ'),
          ),
          Text('$_page ページ / 全 $_total 件'),
          OutlinedButton(
            onPressed: _loading || _page * 20 >= _total
                ? null
                : () => _load(page: _page + 1),
            child: const Text('次へ'),
          ),
        ],
      ),
    ],
  );
}

class _TeacherAssessmentEditor extends StatefulWidget {
  const _TeacherAssessmentEditor({required this.kind, required this.id});
  final _TeacherAssessmentKind kind;
  final int id;
  @override
  State<_TeacherAssessmentEditor> createState() =>
      _TeacherAssessmentEditorState();
}

class _TeacherAssessmentEditorState extends State<_TeacherAssessmentEditor> {
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  Map<String, dynamic>? _original;
  List<ResourceTeacher> _teachers = const [];
  Set<int> _teacherIds = {};
  bool _loading = true;
  bool _saving = false;
  bool _conflict = false;
  String? _error;
  int _status = 0;

  bool get _question => widget.kind == _TeacherAssessmentKind.question;
  bool get _exam => widget.kind == _TeacherAssessmentKind.exam;
  bool get _programmingQuestion => _question && _asInt(_original?['type']) == 6;
  Map<String, String> get _labels => {
    'title': 'タイトル',
    if (_question) ...{
      'programmingLanguage': _programmingQuestion
          ? 'プログラミング言語（必須）'
          : 'プログラミング言語（分類・任意）',
      'content': '問題文',
      'analysis': '解説',
    } else ...{
      'description': '説明',
      'durationMinutes': '制限時間（分・0は無制限）',
      if (_exam) ...{'maxAttempts': '受験可能回数（0は無制限）', 'passScore': '合格点'},
    },
  };

  @override
  void initState() {
    super.initState();
    for (final name in _labels.keys) {
      _fields[name] = TextEditingController();
    }
    unawaited(_load());
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ItClassApi.instance._assessmentDetail(
        widget.kind,
        widget.id,
      );
      if (_asInt(data['id']) != widget.id || _asInt(data['version']) == null) {
        throw const ApiException('編集情報が不完全です。再取得してください。');
      }
      if (widget.kind != _TeacherAssessmentKind.question &&
          data['editable'] != true) {
        throw const ApiException('編集できるのは作成した講師のみです。');
      }
      if (!mounted) return;
      setState(() {
        _original = data;
        for (final entry in _fields.entries) {
          entry.value.text =
              '${data[entry.key] ?? (_isNumber(entry.key) ? 0 : '')}';
        }
        _teacherIds = _asList(
          data['teacherAccountIds'],
        ).map(_asInt).whereType<int>().toSet();
        _teachers = _asList(
          data['teachers'],
        ).map((item) => ResourceTeacher.fromJson(_asMap(item))).toList();
        _status = _asInt(data['status']) ?? 0;
        _conflict = false;
      });
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isNumber(String field) =>
      ['durationMinutes', 'maxAttempts', 'passScore'].contains(field);

  Future<void> _reload() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('最新の内容を読み込みますか？'),
        content: const Text('未保存の変更は破棄されます。再読み込み後、必要な変更を入力して保存してください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('戻る'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('変更を破棄して再読み込み'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) await _load();
  }

  Future<void> _save() async {
    if (_saving ||
        _loading ||
        _conflict ||
        _original == null ||
        !_form.currentState!.validate()) {
      return;
    }
    if (_teacherIds.isEmpty) {
      setState(() => _error = '担当講師を1名以上選択してください。');
      return;
    }
    final payload = {
      for (final field in widget.kind.saveFields) field: _original![field],
    };
    for (final entry in _fields.entries) {
      payload[entry.key] = _isNumber(entry.key)
          ? num.parse(entry.value.text.trim())
          : entry.value.text.trim();
    }
    payload['teacherAccountIds'] = _teacherIds.toList();
    if (!_exam) payload['status'] = _status;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ItClassApi.instance._saveAssessment(widget.kind, payload);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _conflict = error is ApiException && error.code == 1004002045;
          _error = _conflict
              ? '他の講師が更新しました。最新の内容を再読み込みしてください。'
              : userFacingError(error);
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _closeExam() async {
    final close = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('試験を終了しますか？'),
        content: const Text('新しい受験を停止します。この画面の未保存の変更は保存されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('戻る'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('試験を終了'),
          ),
        ],
      ),
    );
    if (close != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await ItClassApi.instance._closeSharedExam(widget.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text('${widget.kind.label}を編集'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(),
              if (_error != null) ...[
                _InlineNotice(
                  tone: _NoticeTone.warning,
                  title: _conflict ? '編集内容が競合しました' : '処理できませんでした',
                  message: _error!,
                ),
                if (_conflict || _original == null)
                  TextButton(
                    onPressed: _loading || _saving
                        ? null
                        : (_conflict ? _reload : _load),
                    child: const Text('最新の内容を再読み込み'),
                  ),
              ],
              if (_original != null)
                AbsorbPointer(
                  absorbing: _loading || _saving || _conflict,
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.kind.statusLabel(_asInt(_original!['status'])),
                        ),
                        const SizedBox(height: 12),
                        for (final entry in _labels.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: _fields[entry.key],
                              decoration: InputDecoration(
                                labelText: entry.value,
                              ),
                              maxLines:
                                  [
                                    'content',
                                    'analysis',
                                    'description',
                                  ].contains(entry.key)
                                  ? 3
                                  : 1,
                              maxLength: entry.key == 'programmingLanguage'
                                  ? 64
                                  : null,
                              keyboardType: _isNumber(entry.key)
                                  ? TextInputType.number
                                  : TextInputType.multiline,
                              validator: (value) {
                                final text = (value ?? '').trim();
                                if (['title', 'content'].contains(entry.key) &&
                                    text.isEmpty) {
                                  return '入力してください。';
                                }
                                if (entry.key == 'programmingLanguage' &&
                                    _programmingQuestion &&
                                    text.isEmpty) {
                                  return 'プログラミング問題の言語を入力してください。';
                                }
                                if (_isNumber(entry.key)) {
                                  final number = num.tryParse(text);
                                  if (number == null ||
                                      !number.isFinite ||
                                      number < 0 ||
                                      (entry.key != 'passScore' &&
                                          int.tryParse(text) == null)) {
                                    return '0以上の${entry.key == 'passScore' ? '数値' : '整数'}を入力してください。';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        if (_question) ...[
                          const Text('選択肢・正解・採点設定は現在の内容を保持します。'),
                          for (final option in _asList(_original!['options']))
                            Text(
                              '${_asMap(option)['optionKey']}: ${_asMap(option)['content']}',
                            ),
                        ] else if (!_exam)
                          Text(
                            '出題順・配点を保持：${_asList(_original!['questions']).length}問 / ${_original!['totalScore']}点',
                          )
                        else ...[
                          Text(
                            '試験用紙：${_original!['paperTitle'] ?? _original!['paperId']}',
                          ),
                          if (_asInt(_original!['status']) == 20)
                            const Text('終了済みの試験は保存後も終了状態を保持します。'),
                          for (final setting in const {
                            'shuffleQuestions': '出題順をランダムにする',
                            'shuffleOptions': '選択肢をランダムにする',
                            'showAnswer': '結果に参考解答を表示',
                          }.entries)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(setting.value),
                              value: _original![setting.key] == true,
                              onChanged: (value) => setState(
                                () => _original![setting.key] = value,
                              ),
                            ),
                        ],
                        const SizedBox(height: 16),
                        _ResponsibleTeacherPicker(
                          selectedIds: _teacherIds,
                          existingTeachers: _teachers,
                          enabled: !_saving && !_loading && !_conflict,
                          onChanged: (ids) => setState(() => _teacherIds = ids),
                        ),
                        if (!_exam)
                          DropdownButtonFormField<int>(
                            key: ValueKey('status-${_original!['version']}'),
                            initialValue: _status,
                            decoration: const InputDecoration(labelText: '状態'),
                            items: [
                              for (final status
                                  in _question ? [0, 1] : [0, 10, 20])
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(widget.kind.statusLabel(status)),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (_exam && _asInt(_original?['status']) == 10)
          TextButton(
            onPressed: _saving || _loading || _conflict ? null : _closeExam,
            child: const Text('試験を終了'),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('閉じる'),
        ),
        FilledButton(
          onPressed: _saving || _loading || _conflict || _original == null
              ? null
              : _save,
          child: Text(_saving ? '保存中' : '保存'),
        ),
      ],
    ),
  );
}
