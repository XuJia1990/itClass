part of '../main.dart';

List<String> _uniqueLanguages(Iterable<String> values) {
  final result = <String, String>{};
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      result.putIfAbsent(value.trim().toUpperCase(), () => value.trim());
    }
  }
  return result.values.toList()
    ..sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
}

class _LearningLanguageFilter extends StatelessWidget {
  const _LearningLanguageFilter({
    required this.languages,
    required this.value,
    required this.onChanged,
    this.includeAll = true,
    this.decoration = const InputDecoration(labelText: '学習言語 / 教室'),
  });
  final List<String> languages;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool includeAll;
  final InputDecoration decoration;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey('language-filter-$value'),
    initialValue: value ?? (includeAll ? '' : languages.firstOrNull),
    isExpanded: true,
    decoration: decoration,
    hint: const Text('選択できる学習言語はありません'),
    items: [
      if (includeAll) const DropdownMenuItem(value: '', child: Text('すべて')),
      for (final language in _uniqueLanguages([...languages, ?value]))
        DropdownMenuItem(value: language, child: Text(language)),
    ],
    onChanged: !includeAll && languages.isEmpty
        ? null
        : (value) => onChanged(value == '' ? null : value),
  );
}

String _attemptStatus(dynamic value) => switch (_asInt(value)) {
  0 => '受験中',
  10 || 20 => '採点待ち',
  30 => '採点済み',
  _ => '未確認',
};

class _TeacherGradingWorkspace extends StatefulWidget {
  const _TeacherGradingWorkspace();
  @override
  State<_TeacherGradingWorkspace> createState() =>
      _TeacherGradingWorkspaceState();
}

class _TeacherGradingWorkspaceState extends State<_TeacherGradingWorkspace> {
  List<Map<String, dynamic>> _rows = [];
  List<SchoolClassroom> _classrooms = [];
  int _page = 1;
  int _total = 0;
  int? _status;
  String? _language;
  bool _loading = false;
  String? _error;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_loadClassrooms());
  }

  Future<void> _loadClassrooms() async {
    try {
      final rooms = await ItClassApi.instance.myClassrooms();
      if (mounted) setState(() => _classrooms = rooms);
    } catch (_) {
      /* The attempt list can still be refreshed independently. */
    }
  }

  Future<void> _load({int? page}) async {
    final generation = ++_generation;
    setState(() {
      _page = page ?? _page;
      _loading = true;
      _error = null;
    });
    try {
      final result = await ItClassApi.instance.teacherAttemptPage(
        pageNo: _page,
        status: _status,
        programmingLanguage: _language,
      );
      if (mounted && generation == _generation) {
        setState(() {
          _rows = result.list;
          _total = result.total;
        });
      }
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = userFacingError(error));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _open(Map<String, dynamic> row) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GradeAttemptDialog(
        attemptId: _asInt(row['id'])!,
        title:
            '${row['studentRealName'] ?? row['studentAccountNo'] ?? ''} · ${row['examTitle'] ?? ''}',
      ),
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _SectionHeader(
        icon: Icons.fact_check_outlined,
        title: '答案の採点',
        subtitle: '学生が提出した答案を確認・採点します。',
      ),
      const SizedBox(height: 24),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 540;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  SizedBox(
                    width: stacked ? constraints.maxWidth : 240,
                    child: _GradingFilterField(
                      label: '学習言語',
                      child: _LearningLanguageFilter(
                        decoration: const InputDecoration(),
                        languages: _classrooms
                            .map((room) => room.programmingLanguage)
                            .toList(),
                        value: _language,
                        onChanged: (value) {
                          setState(() => _language = value);
                          unawaited(_load(page: 1));
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: stacked ? constraints.maxWidth : 180,
                    child: _GradingFilterField(
                      label: '採点状況',
                      child: DropdownButtonFormField<int>(
                        initialValue: _status ?? -1,
                        isExpanded: true,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: -1, child: Text('すべて')),
                          DropdownMenuItem(value: 20, child: Text('採点待ち')),
                          DropdownMenuItem(value: 30, child: Text('採点済み')),
                        ],
                        onChanged: (value) {
                          setState(() => _status = value == -1 ? null : value);
                          unawaited(_load(page: 1));
                        },
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : () => _load(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(96, 48),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('更新'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 24),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null)
        _InlineNotice(
          tone: _NoticeTone.warning,
          title: '答案を取得できませんでした',
          message: _error!,
        ),
      if (!_loading && _rows.isEmpty && _error == null)
        const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 36,
                  color: _AppPalette.muted,
                ),
                SizedBox(height: 16),
                Text('該当する答案はありません。', textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text(
                  '学習言語や採点状況を変更すると、ほかの答案を確認できます。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _AppPalette.muted),
                ),
              ],
            ),
          ),
        ),
      for (final row in _rows)
        Card(
          child: ListTile(
            title: Text(
              '${row['studentRealName'] ?? row['studentAccountNo'] ?? ''} · ${row['examTitle'] ?? ''}',
            ),
            subtitle: Text(
              '${row['programmingLanguage'] ?? ''} · 第${row['attemptNo'] ?? 1}回 · ${_attemptStatus(row['status'])}\n${row['totalScore'] ?? '-'} / ${row['paperTotalScore'] ?? '-'}点',
            ),
            trailing: IconButton(
              tooltip: _asInt(row['status']) == 20 ? '採点する' : '答案を確認',
              icon: const Icon(Icons.edit_note),
              onPressed: _asInt(row['status']) == 0 ? null : () => _open(row),
            ),
          ),
        ),
      if (_total > 0 && _error == null)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: '前へ',
              onPressed: _loading || _page <= 1
                  ? null
                  : () => _load(page: _page - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_page / ${(_total / 20).ceil()}ページ · 全 $_total 件',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              tooltip: '次へ',
              onPressed: _loading || _page * 20 >= _total
                  ? null
                  : () => _load(page: _page + 1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
    ],
  );
}

class _GradingFilterField extends StatelessWidget {
  const _GradingFilterField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _AppPalette.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Semantics(label: label, child: child),
    ],
  );
}

class _GradeAttemptDialog extends StatefulWidget {
  const _GradeAttemptDialog({required this.attemptId, required this.title});
  final int attemptId;
  final String title;
  @override
  State<_GradeAttemptDialog> createState() => _GradeAttemptDialogState();
}

class _GradeAttemptDialogState extends State<_GradeAttemptDialog> {
  final _form = GlobalKey<FormState>();
  final _scores = <int, TextEditingController>{};
  final _comments = <int, TextEditingController>{};
  List<Map<String, dynamic>> _answers = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    for (final controller in [..._scores.values, ..._comments.values]) {
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
      final answers = await ItClassApi.instance.teacherAttemptAnswers(
        widget.attemptId,
      );
      if (!mounted) return;
      for (final controller in [..._scores.values, ..._comments.values]) {
        controller.dispose();
      }
      _scores.clear();
      _comments.clear();
      for (final answer in answers.where(
        (answer) => _asInt(answer['gradingStatus']) == 0,
      )) {
        final id = _asInt(answer['id'])!;
        _scores[id] = TextEditingController();
        _comments[id] = TextEditingController();
      }
      setState(() => _answers = answers);
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final entries = [
      for (final entry in _scores.entries)
        if (entry.value.text.trim().isNotEmpty)
          {
            'answerId': entry.key,
            'score': double.parse(entry.value.text),
            'comment': _comments[entry.key]!.text.trim(),
          },
    ];
    if (entries.isEmpty) {
      setState(() => _error = '点数を入力してください。');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ItClassApi.instance.gradeAttempt(widget.attemptId, entries);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: SizedBox(
      width: 820,
      height: MediaQuery.sizeOf(context).height * .85,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: '最新の答案を取得',
                  onPressed: _loading || _saving ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: _AppPalette.coral),
                ),
              ),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    for (var index = 0; index < _answers.length; index++)
                      _answer(index),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('閉じる'),
                ),
                const SizedBox(width: 12),
                if (_scores.isNotEmpty)
                  FilledButton.icon(
                    onPressed: _saving || _loading ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? '保存中…' : '採点を保存'),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Widget _answer(int index) {
    final answer = _answers[index];
    final id = _asInt(answer['id'])!;
    final pending = _scores.containsKey(id);
    final maxScore = double.tryParse('${answer['maxScore']}') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '第${index + 1}問 · ${answer['questionTitle'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText('${answer['questionContent'] ?? ''}'),
          const SizedBox(height: 8),
          Text('学生の回答', style: Theme.of(context).textTheme.labelLarge),
          SelectableText('${answer['answerContent'] ?? ''}'),
          const SizedBox(height: 8),
          Text('参考解答', style: Theme.of(context).textTheme.labelLarge),
          SelectableText('${answer['referenceAnswer'] ?? ''}'),
          if (pending) ...[
            TextFormField(
              controller: _scores[id],
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: '得点（0〜$maxScore）'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final score = double.tryParse(value);
                return score == null ||
                        !score.isFinite ||
                        score < 0 ||
                        score > maxScore
                    ? '0〜$maxScore の範囲で入力してください。'
                    : null;
              },
            ),
            TextFormField(
              controller: _comments[id],
              enabled: !_saving,
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: '先生コメント'),
            ),
          ] else ...[
            Text('得点 ${answer['score'] ?? 0} / $maxScore'),
            SelectableText('${answer['graderComment'] ?? ''}'),
          ],
          const Divider(),
        ],
      ),
    );
  }
}

class _StudentExamHistoryWorkspace extends StatefulWidget {
  const _StudentExamHistoryWorkspace({super.key, this.language});
  final String? language;
  @override
  State<_StudentExamHistoryWorkspace> createState() =>
      _StudentExamHistoryWorkspaceState();
}

class _StudentExamHistoryWorkspaceState
    extends State<_StudentExamHistoryWorkspace> {
  List<Map<String, dynamic>> _rows = [];
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _page = page ?? _page;
      _loading = true;
      _error = null;
    });
    try {
      final result = await ItClassApi.instance.studentAttemptPage(
        pageNo: _page,
        programmingLanguage: widget.language,
      );
      if (mounted) {
        setState(() {
          _rows = result.list;
          _total = result.total;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _details(int id) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _StudentResultDialog(attemptId: id),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          const Expanded(
            child: Text('成績履歴', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            tooltip: '更新',
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: _AppPalette.coral)),
      if (!_loading && _rows.isEmpty && _error == null)
        const Text('受験履歴はありません。'),
      for (final row in _rows)
        Card(
          child: ListTile(
            title: Text('${row['examTitle'] ?? ''}'),
            subtitle: Text(
              '${row['programmingLanguage'] ?? ''} · 第${row['attemptNo'] ?? 1}回 · ${_attemptStatus(row['status'])}\n${_asInt(row['status']) == 30 ? '${row['totalScore']} / ${row['paperTotalScore']}点' : '最終得点は採点完了後に表示されます。'}',
            ),
            trailing: IconButton(
              tooltip: '採点結果を表示',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: _asInt(row['status']) == 30
                  ? () => _details(_asInt(row['id'])!)
                  : null,
            ),
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: '前へ',
            onPressed: _loading || _page <= 1
                ? null
                : () => _load(page: _page - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_page · 全 $_total 件'),
          IconButton(
            tooltip: '次へ',
            onPressed: _loading || _page * 20 >= _total
                ? null
                : () => _load(page: _page + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    ],
  );
}

class _StudentResultDialog extends StatefulWidget {
  const _StudentResultDialog({required this.attemptId});
  final int attemptId;
  @override
  State<_StudentResultDialog> createState() => _StudentResultDialogState();
}

class _StudentResultDialogState extends State<_StudentResultDialog> {
  late final Future<Map<String, dynamic>> _result = ItClassApi.instance
      .examResultDetails(widget.attemptId);
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('採点結果'),
    content: SizedBox(
      width: 680,
      height: MediaQuery.sizeOf(context).height * .65,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _result,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(userFacingError(snapshot.error!));
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            children: [
              Text('${data['examTitle']}'),
              Text(
                '${data['totalScore']} / ${data['paperTotalScore']}点 · ${data['passed'] == true ? '合格' : '不合格'}',
              ),
              for (final item in _asList(data['answers'])) ...[
                const Divider(),
                Text(
                  '${_asMap(item)['questionTitle'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText('${_asMap(item)['questionContent'] ?? ''}'),
                Text(
                  '得点：${_asMap(item)['score'] ?? 0} / ${_asMap(item)['maxScore'] ?? 0}',
                ),
                SelectableText('あなたの回答：${_asMap(item)['answerContent'] ?? ''}'),
                if (data['answersVisible'] == true) ...[
                  SelectableText(
                    '参考解答：${_asMap(item)['referenceAnswer'] ?? ''}',
                  ),
                  SelectableText('${_asMap(item)['analysis'] ?? ''}'),
                ],
                if (_asString(_asMap(item)['graderComment']).isNotEmpty)
                  SelectableText('先生コメント：${_asMap(item)['graderComment']}'),
              ],
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('閉じる'),
      ),
    ],
  );
}

class _TeacherExamTrialPage extends StatefulWidget {
  const _TeacherExamTrialPage({required this.examId});
  final int examId;
  @override
  State<_TeacherExamTrialPage> createState() => _TeacherExamTrialPageState();
}

class _TeacherExamTrialPageState extends State<_TeacherExamTrialPage> {
  ExamAttemptPayload? _attempt;
  ExamResult? _result;
  final _answers = <int, String>{};
  final _saved = <int, String>{};
  final _saving = <int>{};
  bool _busy = false;
  bool _submitted = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final attempt = await ItClassApi.instance.startExam(widget.examId);
      if (mounted) {
        setState(() {
          _attempt = attempt;
          _submitted = false;
          _result = null;
          _answers.clear();
          _saved.clear();
          for (var i = 0; i < attempt.questions.length; i++) {
            final answer = attempt.questions[i].savedAnswer;
            if (answer.isNotEmpty) {
              _answers[i] = answer;
              _saved[i] = answer;
            }
          }
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(int index) async {
    if (_attempt == null || _saving.contains(index) || _submitted) return;
    final answer = _answers[index];
    if (answer == null) return;
    setState(() => _saving.add(index));
    try {
      await ItClassApi.instance.saveExamAnswer(
        attemptId: _attempt!.attemptId,
        paperQuestionId: _attempt!.questions[index].paperQuestionId!,
        answerContent: answer,
      );
      if (mounted) setState(() => _saved[index] = answer);
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _saving.remove(index));
    }
  }

  Future<void> _refreshResult() async {
    try {
      final result = await ItClassApi.instance.examResult(_attempt!.attemptId);
      if (mounted) {
        setState(() {
          _result = result;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    }
  }

  Future<void> _submit() async {
    if (_busy || _submitted || _attempt == null || _saving.isNotEmpty) return;
    setState(() => _busy = true);
    try {
      await ItClassApi.instance.submitExam(
        attemptId: _attempt!.attemptId,
        questions: _attempt!.questions,
        selectedAnswers: const {},
        writtenAnswers: _answers,
      );
      if (!mounted) return;
      setState(() => _submitted = true);
      await _refreshResult();
    } catch (error) {
      if (mounted) setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selfGrade() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _GradeAttemptDialog(
        attemptId: _attempt!.attemptId,
        title: '試行答案の自己採点',
      ),
    );
    if (changed == true && mounted) await _refreshResult();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('試しに受験（学生の成績集計対象外）')),
    body: _attempt == null
        ? Center(
            child: _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      TextButton(
                        onPressed: _busy ? null : _start,
                        child: const Text('再試行'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          )
        : Column(
            children: [
              if (_submitted && _result == null)
                TextButton.icon(
                  onPressed: _selfGrade,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('記述答案を自己採点'),
                ),
              Expanded(
                child: _StudentExamWorkspace(
                  title: _attempt!.examTitle,
                  limitsLabel: '講師の試行',
                  questions: _attempt!.questions,
                  answers: _answers,
                  savedAnswers: _saved,
                  savingAnswers: _saving,
                  deadline: _attempt!.deadlineTime,
                  submitting: _busy,
                  submitted: _submitted,
                  result: _result,
                  error: _error,
                  onChanged: (index, answer) =>
                      setState(() => _answers[index] = answer),
                  onSave: (index) => unawaited(_save(index)),
                  onSubmit: () => unawaited(_submit()),
                  onRefreshResult: () => unawaited(_refreshResult()),
                  onRetake: () => unawaited(_start()),
                ),
              ),
            ],
          ),
  );
}
